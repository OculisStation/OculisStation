#ifdef DMEOW_BURN_BUILD

// one button, two arms, no bookkeeping for whoever pressed it.
//
// lighting corners fail to collect carrying references no DM code can find, and
// the thing that keeps going wrong when you check this by hand is timing:
// SSgarbage sits on an item for GC_CHECK_QUEUE (five minutes) before it even
// looks, so a reading taken just after flipping the JIT is mostly corners from
// before the flip.
//
// so per arm: set hooks, wait until SSgarbage holds no corners at all, fresh burn
// room, burn for a fixed window, count only corners queued inside it. every
// corner counted was born and died under one setting.

GLOBAL_DATUM(dmeow_corner_leak_run, /datum/dmeow_corner_leak_run)

/datum/dmeow_corner_leak_run
	/// long enough to queue a few hundred corners, short enough that they're all
	/// still queued when the audit runs. the five minute cutoff is the ceiling.
	var/churn_seconds = 120
	/// gives up rather than hanging forever. a drain after a full churn window
	/// costs GC_CHECK_QUEUE plus however long the backlog takes.
	var/drain_timeout_seconds = 480
	/// echo progress here too, on top of the world log.
	var/client/watcher
	/// one per finished arm, in the order they ran.
	var/list/arms = list()

/datum/dmeow_corner_leak_run/proc/announce(text)
	log_world("dmeow corner leak A/B: [text]")
	if(watcher)
		to_chat(watcher, "dmeow corner leak A/B: [text]")

/datum/dmeow_corner_leak_run/proc/abort(reason)
	announce("ABORTED - [reason]")
	// leave the JIT how a round normally runs, whatever arm we died in.
	dmeow_set_hooks(TRUE)
	if(GLOB.dmeow_standalone_burn)
		dmeow_toggle_standalone_burn()
	GLOB.dmeow_corner_leak_run = null

/datum/dmeow_corner_leak_run/proc/execute()
	if(!dmeow_loaded)
		abort("dmeow is not loaded, so there is nothing to compare against")
		return
	if(GLOB.dmeow_perf_session)
		abort("a profiling run owns the burn room - stop that first")
		return
	if(GLOB.dmeow_standalone_burn)
		abort("a burn room is already up - this run builds its own, stop that one first")
		return

	announce("starting. two arms, [churn_seconds]s of burning each, plus a drain between them that can take several minutes. nothing else should touch the burn room or the JIT until it reports.")

	// JIT off first: the drain before arm one is short when the queue starts empty,
	// so the expensive drain happens once, between arms.
	for(var/hooks_on in list(FALSE, TRUE))
		if(!run_arm(hooks_on))
			return

	report()

/datum/dmeow_corner_leak_run/proc/run_arm(hooks_on)
	var/label = hooks_on ? "JIT on" : "JIT off"
	dmeow_set_hooks(hooks_on)
	announce("[label]: hooks set, waiting for SSgarbage to let go of every corner queued so far")

	if(!drain_corner_queue())
		abort("[label]: SSgarbage still holds [queued_corner_count()] corner(s) after [drain_timeout_seconds]s, so this arm would measure the previous one")
		return FALSE

	var/status = dmeow_toggle_standalone_burn()
	if(!GLOB.dmeow_standalone_burn)
		abort("[label]: could not start the burn room - [status]")
		return FALSE

	var/arm_start = world.time
	announce("[label]: queue is clear, burning for [churn_seconds]s")
	sleep(churn_seconds SECONDS)

	// before the room comes down and well inside the five minute cutoff, so every
	// corner queued during the window is still there to read.
	var/list/audited = audit_corner_refcounts(arm_start)
	dmeow_toggle_standalone_burn()

	var/list/arm = summarize(label, audited)
	arms += list(arm)
	announce("[label]: [arm["corners"]] corner(s) queued during the window, unaccounted references worst [arm["worst"]], median [arm["median"]], mean [arm["mean"]]")
	return TRUE

/// waits until no lighting corner is left anywhere in SSgarbage's queues. FALSE
/// if it ran out of patience first.
/datum/dmeow_corner_leak_run/proc/drain_corner_queue()
	var/deadline = world.time + (drain_timeout_seconds SECONDS)
	var/last_announced = -1
	while(world.time < deadline)
		var/remaining = queued_corner_count()
		if(!remaining)
			return TRUE
		// only speak up when the number moves, so a long drain doesn't
		// bury the arm's own lines.
		if(remaining != last_announced)
			announce("  draining, [remaining] corner(s) still queued")
			last_announced = remaining
		sleep(10 SECONDS)
	return !queued_corner_count()

/// how many lighting corners SSgarbage is sitting on, at any level.
/proc/queued_corner_count()
	. = 0
	for(var/list/queue as anything in SSgarbage.queues)
		for(var/list/entry as anything in queue)
			if(istype(entry[GC_QUEUE_ITEM_REF], /datum/lighting_corner))
				.++
		CHECK_TICK

/datum/dmeow_corner_leak_run/proc/summarize(label, list/audited)
	if(!length(audited))
		return list("arm" = label, "corners" = 0, "worst" = 0, "median" = 0, "mean" = 0)
	var/total = 0
	for(var/list/row as anything in audited)
		total += row["unaccounted"]
	return list(
		"arm" = label,
		"corners" = length(audited),
		"worst" = audited[1]["unaccounted"],
		"median" = audited[round(length(audited) / 2) + 1]["unaccounted"],
		"mean" = round(total / length(audited), 0.01),
	)

/datum/dmeow_corner_leak_run/proc/report()
	announce("--- result ---")
	for(var/list/arm as anything in arms)
		announce("[arm["arm"]]: [arm["corners"]] corners, unaccounted references worst [arm["worst"]], median [arm["median"]], mean [arm["mean"]]")

	var/list/off_arm = arms[1]
	var/list/on_arm = arms[2]
	announce("median unaccounted references: [off_arm["median"]] with the JIT off, [on_arm["median"]] with it on")

	if(!off_arm["corners"] || !on_arm["corners"])
		announce("one arm queued no corners at all, so there is nothing to compare - lengthen churn_seconds or check the burn room came up")
	else if(on_arm["median"] > off_arm["median"])
		announce("the JIT adds references. bisect from here: raise the compile threshold or narrow the auto-tier, then run this again")
	else
		announce("the JIT does not add references - whatever holds these corners is there without it, so stop looking inside dmeow")

	announce("hooks left enabled, burn room torn down")
	dmeow_set_hooks(TRUE)
	GLOB.dmeow_corner_leak_run = null

ADMIN_VERB(dmeow_corner_leak_ab, R_DEBUG, "dmeow corner leak A/B", "Measure lighting corner reference leaks with the JIT off and then on, draining SSgarbage between the two.", ADMIN_CATEGORY_DEBUG)
	if(GLOB.dmeow_corner_leak_run)
		to_chat(user, "a corner leak A/B run is already going")
		return
	var/datum/dmeow_corner_leak_run/run = new()
	run.watcher = user
	GLOB.dmeow_corner_leak_run = run
	INVOKE_ASYNC(run, TYPE_PROC_REF(/datum/dmeow_corner_leak_run, execute))

#endif

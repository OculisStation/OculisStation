#ifdef DMEOW_BURN_BUILD

/// global and not on the panel datum, so closing the window doesn't strand the
/// flip timer.
GLOBAL_DATUM(dmeow_perf_session, /datum/dmeow_perf_session)

/// flips the JIT on and off on a fixed schedule so both arms see the same
/// workload, marking the report at every flip.
///
/// the old shape (interpreter for 90s, then the JIT for the rest) never
/// overlapped its arms in time, so "interpreter is 2x slower" was really "the
/// first 90s of a round are 2x busier".
/datum/dmeow_perf_session
	var/threshold
	var/sample_rate
	/// compile-and-settle before measuring. everything sampled during it is binned.
	var/warmup_seconds
	var/window_seconds
	var/cycles

	/// "idle" | "warmup" | "interleave" | "done". the tgui panel compares against
	/// these strings, so they're not free to rename.
	var/phase = "idle"
	/// even = JIT on, odd = JIT off. the panel mirrors that to label the arm.
	var/window_index = 0
	var/started_at = 0
	var/phase_ends_at = 0
	var/timer_id
	var/datum/dmeow_load/load
	/// filled in by finish(); the panel reads this instead of re-collecting.
	var/list/summary
	/// one row per SSair fire during the interleave, written out by finish().
	var/list/turf_rows = list()
	/// rows refused once turf_rows hit the cap. non-zero means the rows no longer
	/// sum to the round's turf count, so the cross-check is off the table.
	var/turf_rows_dropped = 0
	/// fires once at the end of finish(). the unattended runner shuts the server
	/// down with it; a panel-driven run leaves it null.
	var/datum/callback/on_finish

	/// headless runner only. a panel-driven run shares this datum on a live
	/// server, where deleting the crew would be rude.
	var/quiet_station = FALSE
	var/mobs_deleted = 0
	/// area.type -> count of active turfs outside the room, taken once at the end
	/// of warmup. empty means the station settled.
	var/list/freeze_census
	/// active turfs outside the room at the start of this pass. refreshed on a
	/// fresh pass only, same as SSair.queue_at_pass_start.
	var/foreign_at_pass_start = 0

/datum/dmeow_perf_session/New(threshold, sample_rate, warmup_seconds, window_seconds, cycles, datum/dmeow_load/load = null)
	. = ..()
	src.threshold = threshold
	src.sample_rate = sample_rate
	src.warmup_seconds = warmup_seconds
	src.window_seconds = window_seconds
	src.cycles = cycles
	src.load = load

/datum/dmeow_perf_session/Destroy()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	if(load)
		load.stop()
		QDEL_NULL(load)
	return ..()

/datum/dmeow_perf_session/proc/set_phase_timer(seconds, datum/callback/next)
	if(timer_id)
		deltimer(timer_id)
	phase_ends_at = world.time + seconds SECONDS
	timer_id = addtimer(next, seconds SECONDS, TIMER_STOPPABLE)

/// profiling has to be up before counting, or the hot procs promote before the
/// profiler exists and warmup measures nothing.
/datum/dmeow_perf_session/proc/begin()
	dmeow_perf_reset()
	dmeow_perf_start(sample_rate)
	dmeow_sample_rate = sample_rate
	started_at = world.time

	dmeow_set_hooks(TRUE)
	dmeow_enable_counting(threshold)
	dmeow_counting_threshold = threshold
	phase = "warmup"
	if(load)
		load.start()
	set_phase_timer(warmup_seconds, CALLBACK(src, PROC_REF(freeze)))

/// counted before the timed region in air/fire(), not inside it - turf_delta has
/// to stay the cost of process_active_turfs and nothing else.
///
/// gated on the interleave so the loop never runs during warmup, the one stretch
/// where the auto-tier could promote it. otherwise it'd go native in one arm and
/// interpreted in the other, inside SSair's budget.
/datum/dmeow_perf_session/proc/snapshot_foreign_turfs()
	if(phase != "interleave")
		return
	var/datum/dmeow_load/atmos_room/room = load
	foreign_at_pass_start = istype(room) ? room.foreign_active_turfs() : 0

/// end of warmup. freeze the compiled set, then bin everything so far -
/// roundstart, mapload, lighting init, every LLVM compile stall.
///
/// the disable_counting isn't tidiness. turning native dispatch off doesn't turn
/// the auto-tier observer off, so compiled procs drop to the interpreter, get
/// spotted, and get recompiled inside every single interpreter window.
/datum/dmeow_perf_session/proc/freeze()
	timer_id = null
	// has to happen while phase is still "warmup", or record_turf_row() starts
	// writing rows for a round we're about to refuse to measure.
	if(quiet_station && !station_is_quiet())
		return
	dmeow_disable_counting()
	dmeow_counting_threshold = 0
	dmeow_perf_reset()
	window_index = 0
	phase = "interleave"
	dmeow_set_hooks(TRUE)
	mark_window(TRUE)
	set_phase_timer(window_seconds, CALLBACK(src, PROC_REF(flip)))

/// TRUE when nothing outside the room is active at the end of warmup, otherwise
/// names the areas and tears the round down. refusing rather than warming up
/// longer on purpose: a station that hasn't settled in 180s has something
/// feeding it, and a longer warmup would just hide what.
/datum/dmeow_perf_session/proc/station_is_quiet()
	var/datum/dmeow_load/atmos_room/room = load
	if(!istype(room))
		return TRUE
	freeze_census = room.foreign_census()
	var/total = 0
	var/list/parts = list()
	for(var/key in freeze_census)
		total += freeze_census[key]
		parts += "[key]=[freeze_census[key]]"
	if(!total)
		log_world("DMEOW_BURN: station quiet at end of warmup")
		return TRUE

	log_world("DMEOW_BURN: [total] station turfs still active at end of warmup: [parts.Join(", ")]")
	dmeow_debug_flush()
	dmeow_perf_session_stop()
	dmeow_shutdown()
	SSticker.delay_end = FALSE
	shutdown()
	return FALSE

/datum/dmeow_perf_session/proc/flip()
	timer_id = null
	window_index++
	if(window_index >= cycles * 2)
		finish()
		return
	var/hooks_on = !dmeow_hooks_enabled
	dmeow_set_hooks(hooks_on)
	mark_window(hooks_on)
	set_phase_timer(window_seconds, CALLBACK(src, PROC_REF(flip)))

/// the "on"/"off" prefix is a contract - dmeow_window_arms() splits on the ":"
/// and dmeow_window_pairs() matches those exact strings. reword it and every
/// row's pair count quietly goes to zero.
///
/// SSair.times_fired rides along because SSair is MC_TICK_CHECK bounded and
/// SS_BACKGROUND, so "burn for 15 seconds" does a wildly variable amount of work.
/// a starved window should be visible, not averaged in.
/datum/dmeow_perf_session/proc/mark_window(hooks_on)
	dmeow_perf_mark("[hooks_on ? "on" : "off"]:[SSair.times_fired]")

/// one row per SSair fire that reached the active-turf phase, called from
/// air/fire() while that phase's timing is still in hand.
///
/// gated on phase and not window_index, because window_index is 0 during warmup
/// as well as during the first interleave window. riding the window mark instead
/// isn't an option - dmeow_perf_mark() *opens* a window, so a mark per fire would
/// leave hundreds of them.
/datum/dmeow_perf_session/proc/record_turf_row(entry_part, pass_fresh, turf_delta)
	if(phase != "interleave")
		return
	if(length(turf_rows) >= DMEOW_TURF_ROW_LIMIT)
		turf_rows_dropped++
		return
	UNTYPED_LIST_ADD(turf_rows, list(
		"window" = window_index,
		"run" = SSair.fire_runs,
		"times_fired" = SSair.times_fired,
		"entry_part" = entry_part,
		"fresh" = pass_fresh,
		"turfs" = SSair.turfs_processed_last,
		"ticks" = turf_delta,
		// what's left in the queue, not state != SS_RUNNING. MC_TICK_CHECK sits
		// after the last turf, so a pass that drained the queue can still pause on
		// it and would read as a bail.
		"remaining" = length(SSair.currentrun),
		"queue_at_start" = SSair.queue_at_pass_start,
		// how much of that queue wasn't the room. queue_at_start is station-wide,
		// so alone it can't say whether the arms diverged on the fixture or the
		// station.
		"foreign_at_start" = foreign_at_pass_start,
		"hotspots" = length(SSair.hotspots),
		"excited_groups" = length(SSair.excited_groups),
		"tick_allocation" = SSair.tick_allocation_last,
		"reseeds" = load ? load.reseeds : 0,
		"reseed_ticks" = load ? load.reseed_ticks : 0,
		"room_hotspots" = load ? load.interior_hotspots : 0,
	))

/datum/dmeow_perf_session/proc/finish()
	timer_id = null
	phase = "done"
	// stop sampling before writing, or the last window keeps hoovering up whatever
	// the server does next and a second collect comes out dirtier.
	dmeow_perf_stop()
	dmeow_sample_rate = 0
	// put the server back how it normally runs, whichever arm we landed on.
	dmeow_set_hooks(TRUE)
	// describe() before stop(), or the room's already handed its reservation back
	// and the only thing left to say about it is "idle".
	var/load_description = load?.describe()
	if(load)
		load.stop()
	summary = dmeow_perf_collect()
	var/announcement = "A/B run finished but the profiler returned no report"
	if(summary)
		var/turf_file = dmeow_turf_rows_write(src, summary["file"], load_description)
		announcement = "A/B run finished, wrote [summary["file"]] and [turf_file] ([summary["compared"]] procs comparable)"
	message_admins("dmeow: [announcement]")
	world.log << "dmeow: [announcement]"
	on_finish?.Invoke()

/datum/dmeow_perf_session/proc/seconds_left()
	if(!phase_ends_at || phase == "done")
		return 0
	return max(0, round((phase_ends_at - world.time) / 10))

/proc/dmeow_perf_session_stop()
	if(!GLOB.dmeow_perf_session)
		return
	dmeow_perf_stop()
	dmeow_disable_counting()
	dmeow_sample_rate = 0
	dmeow_counting_threshold = 0
	QDEL_NULL(GLOB.dmeow_perf_session)

#endif

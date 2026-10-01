ADMIN_VERB(dmeow_panel, R_DEBUG, "dmeow (JIT) panel", "Arm, profile and inspect the dmeow JIT.", ADMIN_CATEGORY_DEBUG)
	var/datum/dmeow_panel/panel = new()
	panel.ui_interact(user.mob)

/// control panel for dmeow. only caches the last explicit refresh - every live
/// read locks the DLL, so none of them ride the autoupdate tick.
/datum/dmeow_panel
	var/status_text
	var/list/losses
	var/list/wins
	var/list/self_losses
	var/list/self_wins
	var/list/below_floor
	var/list/self_below_floor
	var/compared = 0
	var/self_compared = 0
	var/below_floor_count = 0
	var/self_below_floor_count = 0
	var/insufficient = 0
	var/self_insufficient = 0
	var/total_calls = 0
	var/reported_calls = 0
	var/list/census
	var/timer_source
	var/resolution_ns = 0
	var/timer_anomalies = 0
	var/last_report_file
	/// last thing a button did, echoed into the window so nobody has to dig through
	/// chat to see whether a compile took.
	var/last_result
	var/asm_proc_path
	var/asm_text

/datum/dmeow_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DmeowPanel")
		ui.open()

/datum/dmeow_panel/ui_state(mob/user)
	return ADMIN_STATE(R_DEBUG)

/datum/dmeow_panel/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/dmeow_panel/ui_static_data(mob/user)
	var/list/data = list(
		"default_threshold" = DMEOW_PERF_DEFAULT_THRESHOLD,
		"default_sample_rate" = DMEOW_PERF_DEFAULT_SAMPLE_RATE,
		"default_warmup" = DMEOW_PERF_DEFAULT_WARMUP,
		"default_window" = DMEOW_PERF_DEFAULT_WINDOW,
		"default_cycles" = DMEOW_PERF_DEFAULT_CYCLES,
		"min_samples" = DMEOW_PERF_MIN_SAMPLES,
		"min_overlap" = DMEOW_PERF_MIN_OVERLAP_PCT,
		"reseed_period" = DMEOW_BURN_RESEED_PERIOD,
		"asm_proc_path" = asm_proc_path,
		"asm_text" = asm_text,
		"profiling_available" = FALSE,
	)
#ifdef DMEOW_BURN_BUILD
	data["profiling_available"] = TRUE
#endif
	return data

/datum/dmeow_panel/ui_data(mob/user)
	var/list/data = list(
		"loaded" = dmeow_loaded,
		"armed" = dmeow_armed,
		"hooks_enabled" = dmeow_hooks_enabled,
		"counting_threshold" = dmeow_counting_threshold,
		"sample_rate" = dmeow_sample_rate,
		"status_text" = status_text,
		"losses" = losses,
		"wins" = wins,
		"self_losses" = self_losses,
		"self_wins" = self_wins,
		"below_floor" = below_floor,
		"self_below_floor" = self_below_floor,
		"compared" = compared,
		"self_compared" = self_compared,
		"below_floor_count" = below_floor_count,
		"self_below_floor_count" = self_below_floor_count,
		"insufficient" = insufficient,
		"self_insufficient" = self_insufficient,
		"total_calls" = total_calls,
		"reported_calls" = reported_calls,
		"census" = census,
		"timer_source" = timer_source,
		"resolution_ns" = resolution_ns,
		"timer_anomalies" = timer_anomalies,
		"last_report_file" = last_report_file,
		"last_result" = last_result,
	)
#ifdef DMEOW_BURN_BUILD
	var/datum/dmeow_perf_session/session = GLOB.dmeow_perf_session
	data["session_active"] = !!session
	data["session_phase"] = session ? session.phase : null
	data["session_seconds"] = session ? round((world.time - session.started_at) / 10) : 0
	data["phase_seconds_left"] = session ? session.seconds_left() : 0
	data["window_index"] = session ? session.window_index : 0
	data["window_total"] = session ? session.cycles * 2 : 0
	data["window_seconds"] = session ? session.window_seconds : 0
	data["load_status"] = session?.load ? session.load.describe() : null
#endif
	return data

/datum/dmeow_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	// ui_state gates opening the window, not reaching this proc.
	if(!check_rights(R_DEBUG))
		return
	if(action == "load")
		if(!dmeow_init())
			last_result = "dmeow failed to load - see world log"
			return TRUE
		last_result = "dmeow loaded"
#ifndef DMEOW_BURN_BUILD
		// an A/B run sets its own threshold, so only turn promotion on outside burn builds
		last_result = dmeow_rearm()
#endif
		return TRUE
	if(!dmeow_loaded)
		last_result = "dmeow is not loaded"
		return TRUE

	switch(action)
		if("refresh_status")
			status_text = "[dmeow_deopt_status()]\n[dmeow_debug_status()]"
			return TRUE
		if("toggle_hooks")
			// one click mid-run swaps the arm label on every window after
			// it, with nothing in the report to say it happened.
#ifdef DMEOW_BURN_BUILD
			if(GLOB.dmeow_perf_session)
				last_result = "cannot flip hooks by hand during a profiling run - it would mislabel every window after this one"
				return TRUE
#endif
			dmeow_hooks_enabled = !!dmeow_toggle_hooks()
			last_result = "hooks [dmeow_hooks_enabled ? "enabled" : "disabled"]"
			message_admins("dmeow: [last_result]")
			world.log << "dmeow: [last_result]"
			return TRUE
#ifdef DMEOW_BURN_BUILD
		if("perf_start")
			return start_session(params)
		if("perf_manual_start")
			return start_manual_tracking(params)
		if("perf_manual_stop")
			if(GLOB.dmeow_perf_session)
				last_result = "an A/B run owns the profiler - stop that run first"
				return TRUE
			if(!dmeow_sample_rate)
				last_result = "manual tracking is already stopped"
				return TRUE
			dmeow_perf_stop()
			dmeow_sample_rate = 0
			last_result = "manual tracking stopped - samples kept; use Dump report to save them"
			message_admins("dmeow: [last_result]")
			world.log << "dmeow: [last_result]"
			return TRUE
		if("perf_collect")
			return collect_report()
		if("perf_stop")
			if(!GLOB.dmeow_perf_session)
				last_result = "no A/B run is in progress"
				return TRUE
			// a finished run already wrote its report with sampling off. collecting
			// again just folds in whatever the server did since.
			if(GLOB.dmeow_perf_session?.phase == "done")
				adopt_summary(GLOB.dmeow_perf_session.summary)
			else
				collect_report()
			dmeow_perf_session_stop()
			last_result = "run stopped, final report written"
			message_admins("dmeow: [last_result] ([last_report_file])")
			return TRUE
		if("burn_room")
			return toggle_burn_room()
#endif
		if("compile")
			return compile_one(params["proc_name"])
		if("compile_atmos")
			return compile_atmos_targets()
		if("bytecode")
			return dump_bytecode(params["proc_name"], usr)
		if("dump_asm")
			return dump_asm(params["proc_name"])
		if("analysis")
			return dump_analysis()
		if("census")
			return dump_compile_census()
		if("eligible")
			return dump_eligible()
		if("debug_flush")
			last_result = "debug log flushed to [dmeow_debug_flush()]"
			return TRUE
		if("debug_marker")
			var/marker = params["text"]
			if(!marker)
				return FALSE
			dmeow_debug_marker(marker)
			last_result = "marker written: [marker]"
			return TRUE

#ifdef DMEOW_BURN_BUILD
/// starts a fresh recording without changing how the round runs.
/datum/dmeow_panel/proc/start_manual_tracking(list/params)
	if(GLOB.dmeow_perf_session)
		last_result = "an A/B run owns the profiler - stop that run first"
		return TRUE
	if(dmeow_sample_rate)
		last_result = "manual tracking is already running"
		return TRUE

	var/sample_rate = params["sample_rate"]
	if(!isnum(sample_rate) || sample_rate < 1 || sample_rate > 1000)
		last_result = "sampling must be between 1 and 1000 calls"
		return TRUE
	sample_rate = round(sample_rate)
	dmeow_perf_reset()
	dmeow_perf_start(sample_rate)
	dmeow_sample_rate = sample_rate
	last_result = "manual tracking started: fresh samples, 1-in-[sample_rate] sampling"
	message_admins("dmeow: [last_result]")
	world.log << "dmeow: [last_result]"
	return TRUE

/datum/dmeow_panel/proc/start_session(list/params)
	if(GLOB.dmeow_perf_session)
		last_result = "a profiling run is already in progress"
		return TRUE
	if(dmeow_sample_rate)
		last_result = "manual tracking is running - stop it before starting an A/B run"
		return TRUE
	if(!dmeow_armed)
		last_result = "the JIT is disabled - a run would only measure the interpreter"
		return TRUE

	var/threshold = max(round(params["threshold"]), 5)
	var/sample_rate = max(round(params["sample_rate"]), 1)
	var/warmup = max(round(params["warmup"]), 0)
	var/window = max(round(params["window"]), 1)
	var/cycles = max(round(params["cycles"]), 1)
	// the burn room re-seeds on a fixed period, so a window that isn't a whole
	// number of periods hands each arm a different amount of work.
	var/use_burn_room = !!params["burn_room"]
	if(use_burn_room && (window % DMEOW_BURN_RESEED_PERIOD))
		last_result = "window must be a multiple of [DMEOW_BURN_RESEED_PERIOD]s when the burn room is driving the load"
		return TRUE
	// past this the DLL merges further windows into the last and drops the per-proc
	// arm totals, and the report still reads as normal. refuse up front rather than
	// hand back something that looks like an answer.
	if(cycles * 2 > DMEOW_PERF_MAX_WINDOWS)
		last_result = "[cycles] cycles is [cycles * 2] windows, over the [DMEOW_PERF_MAX_WINDOWS] the DLL keeps - use [round(DMEOW_PERF_MAX_WINDOWS / 2)] or fewer"
		return TRUE

	var/datum/dmeow_load/load = use_burn_room ? new /datum/dmeow_load/atmos_room/burn() : null
	GLOB.dmeow_perf_session = new(threshold, sample_rate, warmup, window, cycles, load)
	GLOB.dmeow_perf_session.begin()

	last_result = "A/B run started: [warmup]s warmup, then [cycles] x ([window]s JIT + [window]s interpreter), 1-in-[sample_rate] sampling, threshold [threshold][use_burn_room ? ", burn room driving" : ""]"
	message_admins("dmeow: [last_result]")
	world.log << "dmeow: [last_result]"
	return TRUE

/datum/dmeow_panel/proc/collect_report()
	return adopt_summary(dmeow_perf_collect())

/datum/dmeow_panel/proc/adopt_summary(list/summary)
	if(!summary)
		last_result = "no report - this dmeow DLL was built without perf-report, or the profiler returned nothing"
		return TRUE

	losses = summary["losses"]
	wins = summary["wins"]
	self_losses = summary["self_losses"]
	self_wins = summary["self_wins"]
	below_floor = summary["below_floor"]
	self_below_floor = summary["self_below_floor"]
	compared = summary["compared"]
	self_compared = summary["self_compared"]
	below_floor_count = summary["below_floor_count"]
	self_below_floor_count = summary["self_below_floor_count"]
	insufficient = summary["insufficient"]
	self_insufficient = summary["self_insufficient"]
	total_calls = summary["total_calls"]
	reported_calls = summary["reported_calls"]
	census = summary["census"]
	timer_source = summary["timer_source"]
	resolution_ns = summary["resolution_ns"]
	timer_anomalies = summary["timer_anomalies"]
	last_report_file = summary["file"]
	last_result = "wrote [last_report_file] ([compared] comparable, [below_floor_count] under the [resolution_ns]ns clock floor, [insufficient] without two usable arms)"
	world.log << "dmeow: [last_result]"
	return TRUE

/datum/dmeow_panel/proc/toggle_burn_room()
	last_result = dmeow_toggle_standalone_burn()
	return TRUE
#endif

/datum/dmeow_panel/proc/compile_one(proc_name)
	if(!proc_name)
		return FALSE
	if(dmeow_compile(proc_name))
		last_result = "compiled [proc_name]"
	else
		last_result = "FAILED to compile [proc_name]"
	world.log << "dmeow: [last_result]"
	return TRUE

/datum/dmeow_panel/proc/compile_atmos_targets()
	var/compiled = 0
	var/failed = 0
	for(var/proc_name in dmeow_atmos_target_procs())
		if(dmeow_compile(proc_name))
			world.log << "dmeow: compiled [proc_name]"
			compiled++
		else
			world.log << "dmeow: failed to compile [proc_name]"
			failed++

	last_result = "atmos targets: [compiled] compiled, [failed] failed - see [GLOB.log_directory]/dmeow_debug.dmeowlog"
	message_admins("dmeow: [last_result]")
	world.log << "dmeow: [last_result]"
	return TRUE

/datum/dmeow_panel/proc/dump_bytecode(proc_name, mob/user)
	if(!proc_name)
		return FALSE
	var/bytecode = dmeow_dump_bytecode(proc_name)
	world.log << "\ndmeow: dumped bytecode\n[bytecode]\n"
	to_chat(user, fieldset_block("bytecode for [proc_name]", "[bytecode]", "boxed_message"))
	last_result = "dumped bytecode for [proc_name] to chat + world log"
	return TRUE

/datum/dmeow_panel/proc/dump_asm(proc_name)
	if(!proc_name)
		return FALSE
	asm_proc_path = proc_name
	asm_text = dmeow_proc_asm(proc_name)
	last_result = "dumped assembly for [proc_name]"
	update_static_data_for_all_viewers()
	return TRUE

/datum/dmeow_panel/proc/dump_analysis()
	var/analysis = dmeow_analyze_procs()
	var/filename = "[GLOB.log_directory]/dmeow/analysis/[rustg_unix_timestamp()].txt"
	var/analysis_file = file(filename)
	analysis_file << analysis
	last_result = "wrote proc analysis to [filename]"
	message_admins("dmeow: [last_result]")
	world.log << "dmeow: [last_result]"
	return TRUE

/datum/dmeow_panel/proc/dump_compile_census()
	var/census = dmeow_compile_census()
	var/filename = "[GLOB.log_directory]/dmeow/census/[rustg_unix_timestamp()].txt"
	var/census_file = file(filename)
	census_file << census
	last_result = "wrote compile census to [filename]"
	message_admins("dmeow: [last_result]")
	world.log << "dmeow: [last_result]"
	return TRUE

/datum/dmeow_panel/proc/dump_eligible()
	var/list/eligible_procs = dmeow_list_eligible()
	fdel("eligible_procs.txt")
	rustg_file_write(json_encode(eligible_procs, JSON_PRETTY_PRINT), "eligible_procs.txt")
	last_result = "[length(eligible_procs)] eligible procs written to eligible_procs.txt"
	message_admins("dmeow: [last_result]")
	return TRUE

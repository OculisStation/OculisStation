// stubs the JIT swaps out at runtime. the CRASH() is so a call before
// dmeow_init() finishes blows up instead of quietly purring back a null.
/* This comment bypasses grep checks */ /var/__dmeow
#define DMEOW_DLL (world.system_type == MS_WINDOWS ? "dmeow" : (__dmeow ||= __detect_auxtools("dmeow")))

/proc/dmeow_compile(proc_name)
	CRASH("dmeow not loaded")

/proc/dmeow_compile_override(proc_name, override_id)
	CRASH("dmeow not loaded")

/proc/dmeow_dump_bytecode(proc_name)
	CRASH("dmeow not loaded")

/// the optimized x86 a proc compiles down to. does not register anything, so the
/// proc keeps running interpreted. failures come back as `;` comment lines.
/proc/dmeow_proc_asm(proc_name)
	CRASH("dmeow not loaded")

/// the machine code that actually got installed, read back from where it landed.
/// compiles and registers the proc if it isn't compiled yet, unlike dmeow_proc_asm.
/proc/dmeow_proc_native_asm(proc_name)
	CRASH("dmeow not loaded")

/proc/dmeow_toggle_hooks()
	CRASH("dmeow not loaded")

/proc/dmeow_enable_counting(threshold)
	CRASH("dmeow not loaded")

/proc/dmeow_disable_counting()
	CRASH("dmeow not loaded")

/// waits until every proc queued for a background build has been built and had
/// its native code installed. returns how many results this call installed, or
/// -1 if it gave up waiting.
/proc/dmeow_compile_wait()
	CRASH("dmeow not loaded")

/// replaces the background compile threads, returning how many are running.
/// 0 means builds happen on the game thread, the way dmeow worked before
/// background compiling existed.
/proc/dmeow_set_compile_threads(threads)
	CRASH("dmeow not loaded")

/// TRUE also compiles procs that bail back to the interpreter part-way; FALSE
/// (the default) only ones the JIT handles whole. round-level, not per-proc.
/// returns the previous setting.
/proc/dmeow_set_auto_tier(partial)
	CRASH("dmeow not loaded")

/// TRUE only if the JIT actually armed. dmeow stays loaded when it refuses, so
/// the status hooks keep answering while every dmeow_compile() returns 0. check
/// this before believing a benchmark.
/proc/dmeow_jit_ready()
	CRASH("dmeow not loaded")

/proc/dmeow_deopt_status()
	CRASH("dmeow not loaded")

/// Times every proc's first early_samples calls, then one in sample_rate.
/proc/dmeow_perf_start(sample_rate, early_samples = 0)
	CRASH("dmeow not loaded")

/proc/dmeow_perf_stop()
	CRASH("dmeow not loaded")

/proc/dmeow_perf_reset()
	CRASH("dmeow not loaded")

/// opens a new A/B window in the report under this label and hands back its
/// index. first call after a reset is window 0.
/proc/dmeow_perf_mark(label)
	CRASH("dmeow not loaded")

// next four are only hooked by DLLs built with the extra features on. no-ops
// rather than CRASH(), because the release build leaves them unhooked.

/// the raw perf report JSON. null unless the DLL was built with perf-report on.
/proc/dmeow_perf_report(limit)
	return null

/// hands back the four attribution counter buckets as JSON, and resets them.
/// null unless the DLL was built with perf-attribution on.
/proc/dmeow_attr_counters()
	return null

/// times the snapshot build paths against the dmeow_list_get wrapper on a list.
/// null unless the DLL was built with perf-attribution on.
/proc/dmeow_perf_microbench(list)
	return null

/// shoves the next dmeow_iter_load onto the get_assoc_element fallback.
/// null unless the DLL was built with debug assertions on.
/proc/dmeow_force_iter_fallback_once()
	return null

/proc/dmeow_list_eligible()
	CRASH("dmeow not loaded")

/proc/dmeow_analyze_procs()
	CRASH("dmeow not loaded")

/// tries to compile every eligible proc and reports what got turned down, grouped
/// by cause. nothing runs, but it does sit on the server for as long as it takes.
/// pass TRUE *positionally* (a hooked proc's named args don't resolve like DM's
/// own) to also save the verdicts into the compile cache.
/proc/dmeow_compile_census(prime = FALSE)
	CRASH("dmeow not loaded")

/proc/dmeow_debug_status()
	CRASH("dmeow not loaded")

/proc/dmeow_debug_flush()
	CRASH("dmeow not loaded")

/proc/dmeow_debug_marker(text)
	CRASH("dmeow not loaded")

/// merges this run's compile verdicts into the on-disk compile cache. also
/// fires on dmeow_shutdown(), so calling this too is safe - it just re-merges
/// the same data.
/proc/dmeow_cache_save()
	CRASH("dmeow not loaded")

/// JSON status for the compile cache: whether one loaded this run, whether
/// the file exists, per-bucket counts, and how many classify/compile-failed
/// checks this run answered from the cache instead of redoing the work.
/proc/dmeow_cache_status()
	CRASH("dmeow not loaded")

// nothing calls the stubs below, they're for dmeow's own DM test world. still
// mandatory: auxtools hooks every #[hook] proc at init and one missing path
// kills the load, so a Rust-side hook with no stub here gets you "dmeow failed
// to load" and not one other clue why.

/proc/dmeow_deopt_count()
	CRASH("dmeow not loaded")

/proc/dmeow_sleep_unsafe(proc_name)
	CRASH("dmeow not loaded")

/proc/dmeow_sleep_no_caller_count()
	CRASH("dmeow not loaded")

/proc/dmeow_sleep_watch_spans()
	CRASH("dmeow not loaded")

/proc/dmeow_atom_exists_native(tag, id)
	CRASH("dmeow not loaded")

/proc/dmeow_atom_exists_byond(tag, id)
	CRASH("dmeow not loaded")

/proc/dmeow_atom_liveness_bound(tag)
	CRASH("dmeow not loaded")

/proc/dmeow_assoc_tree_shape(target)
	CRASH("dmeow not loaded")

/proc/dmeow_stackmap_shadow_ok()
	CRASH("dmeow not loaded")

/* bypass linters idk */ var/static/dmeow_loaded = FALSE
/// cached at init - can't change afterwards, so there's no sense paying a
/// call_ext on every panel update.
/* bypass linters idk */ var/static/dmeow_armed = FALSE
/// no getters on the dmeow side, so mirror them here. only DM ever changes them.
/* bypass linters idk */ var/static/dmeow_hooks_enabled = TRUE
/* bypass linters idk */ var/static/dmeow_counting_threshold = 0
/* bypass linters idk */ var/static/dmeow_sample_rate = 0

/proc/dmeow_init()
	fdel("dmeow_debug.jsonl")
	// has to land before auxtools_init, since init already writes events. SetupLogs()
	// runs before every dmeow_init() caller, and DMEOW_DEBUG_LOG still wins over this.
	if(GLOB.log_directory)
		var/debug_log = call_ext(DMEOW_DLL, "dmeow_set_debug_log")("[GLOB.log_directory]/dmeow_debug.dmeowlog")
		if(debug_log)
			SEND_TEXT(world.log, "dmeow debug log: [debug_log]")
	var/result = call_ext(DMEOW_DLL, "auxtools_init")()
	if(result != "SUCCESS")
		SEND_TEXT(world.log, "dmeow auxtools_init failed: [result]")
		return FALSE
	dmeow_loaded = TRUE
	dmeow_hooks_enabled = TRUE

	// the DLL stays loaded on purpose when the JIT refuses, so status hooks keep
	// answering. downside: nothing says so unless we ask, and every benchmark
	// then quietly measures the interpreter.
	dmeow_armed = !!dmeow_jit_ready()
	if(!dmeow_armed)
		world.log << "dmeow loaded, but THE JIT IS DISABLED - nothing will compile. Status:\n[dmeow_deopt_status()]"
		return TRUE

	world.log << "dmeow loaded OK, JIT armed"
	return TRUE

/proc/dmeow_shutdown()
	if(dmeow_loaded)
		call_ext(DMEOW_DLL, "auxtools_shutdown")()
		dmeow_loaded = FALSE
		dmeow_armed = FALSE

/// dmeow_toggle_hooks() is a toggle, not a setter, so landing on a known state
/// means reading it back and flipping again. every A/B flip goes through here - a
/// stray toggle elsewhere swaps the arm label on every window after it.
/proc/dmeow_set_hooks(enabled)
	var/state = !!dmeow_toggle_hooks()
	if(state != !!enabled)
		state = !!dmeow_toggle_hooks()
	dmeow_hooks_enabled = state
	return state

/// the atmos leaf procs worth force-compiling, instead of waiting on them to
/// promote by themselves.
/proc/dmeow_atmos_target_procs()
	return list(
		"/datum/gas_mixture/proc/heat_capacity",
		"/datum/gas_mixture/turf/heat_capacity",
		"/datum/gas_mixture/proc/total_moles",
		"/datum/gas_mixture/proc/return_pressure",
		"/turf/open/process_cell",
		"/datum/gas_mixture/proc/share",
	)

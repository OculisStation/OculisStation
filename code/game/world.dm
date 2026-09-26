#define RESTART_COUNTER_PATH "data/round_counter.txt"
/// Load byond-tracy. If USE_BYOND_TRACY is defined, then this is ignored and byond-tracy is always loaded.
#define USE_TRACY_PARAMETER "tracy"
/// Force the log directory to be something specific in the data/logs folder
#define OVERRIDE_LOG_DIRECTORY_PARAMETER "log-directory"
/// Prevent the master controller from starting automatically
#define NO_INIT_PARAMETER "no-init"
/// Load dmeow, try to compile every proc, write the report, and exit.
#define DMEOW_CENSUS_PARAMETER "dmeow-census"
/// Skip the lobby, force-compile the atmos targets, run the standard burn-room
/// A/B round unattended, write the report, and exit.
#define DMEOW_BURN_PARAMETER "dmeow-burn"
/// Read every air proc interpreted, force-compile them, read again, and diff the
/// two exactly. Answers whether the JIT changes any air-code number.
#define DMEOW_EQUIV_PARAMETER "dmeow-equiv"
/// Immediately setup dmeow on world init.
#define DMEOW_START_PARAMATER "dmeow"

GLOBAL_VAR(restart_counter)

/**
 * WORLD INITIALIZATION
 * THIS IS THE INIT ORDER:
 *
 * BYOND =>
 * - (secret init native) =>
 *   - world.Genesis() =>
 *     - world.init_byond_tracy()
 *     - (Start native profiling)
 *     - world.init_debugger()
 *     - Master =>
 *       - config *unloaded
 *       - (all subsystems) PreInit()
 *       - GLOB =>
 *         - make_datum_reference_lists()
 *   - (/static variable inits, reverse declaration order)
 * - (all pre-mapped atoms) /atom/New()
 * - world.New() =>
 *   - config.Load()
 *   - world.InitTgs() =>
 *     - TgsNew() *may sleep
 *     - GLOB.rev_data.load_tgs_info() *may sleep
 *   - world.ConfigLoaded() =>
 *     - SSdbcore.InitializeRound()
 *     - world.SetupLogs()
 *     - load_admins()
 *     - ...
 *   - Master.Initialize() =>
 *     - (all subsystems) Initialize()
 *     - Master.StartProcessing() =>
 *       - Master.Loop() =>
 *         - Failsafe
 *   - world.RunUnattendedFunctions()
 *
 * Now listen up because I want to make something clear:
 * If something is not in this list it should almost definitely be handled by a subsystem Initialize()ing
 * If whatever it is that needs doing doesn't fit in a subsystem you probably aren't trying hard enough tbhfam
 *
 * GOT IT MEMORIZED?
 * - Dominion/Cyberboss
 *
 * Where to put init shit quick guide:
 * If you need it to happen before the mc is created: world/Genesis.
 * If you need it to happen last: world/New(),
 * Otherwise, in a subsystem preinit or init. Subsystems can set an init priority.
 */

/**
 * THIS !!!SINGLE!!! PROC IS WHERE ANY FORM OF INIITIALIZATION THAT CAN'T BE PERFORMED IN SUBSYSTEMS OR WORLD/NEW IS DONE
 * NOWHERE THE FUCK ELSE
 * I DON'T CARE HOW MANY LAYERS OF DEBUG/PROFILE/TRACE WE HAVE, YOU JUST HAVE TO DEAL WITH THIS PROC EXISTING
 * I'M NOT EVEN GOING TO TELL YOU WHERE IT'S CALLED FROM BECAUSE I'M DECLARING THAT FORBIDDEN KNOWLEDGE
 * SO HELP ME GOD IF I FIND ABSTRACTION LAYERS OVER THIS!
 */
/world/proc/Genesis(tracy_initialized = FALSE)
	RETURN_TYPE(/datum/controller/master)

	if(!tracy_initialized)
		Tracy = new
#ifdef USE_BYOND_TRACY
		if(Tracy.enable("USE_BYOND_TRACY defined"))
			Genesis(tracy_initialized = TRUE)
			return
#else
		var/tracy_enable_reason
		if(USE_TRACY_PARAMETER in params)
			tracy_enable_reason = "world.params"
		if(fexists(TRACY_ENABLE_PATH))
			tracy_enable_reason ||= "enabled for round"
			SEND_TEXT(world.log, "[TRACY_ENABLE_PATH] exists, initializing byond-tracy!")
			fdel(TRACY_ENABLE_PATH)
		if(!isnull(tracy_enable_reason) && Tracy.enable(tracy_enable_reason))
			Genesis(tracy_initialized = TRUE)
			return
#endif

	Profile(PROFILE_RESTART)
	Profile(PROFILE_RESTART, type = "sendmaps")

	// Write everything to this log file until we get to SetupLogs() later
	_initialize_log_files("data/logs/config_error.[GUID()].log")

	// Init the debugger first so we can debug Master
	Debugger = new

	// Create the logger
	logger = new

	// THAT'S IT, WE'RE DONE, THE. FUCKING. END.
	Master = new

/**
 * World creation
 *
 * Here is where a round itself is actually begun and setup.
 * * db connection setup
 * * config loaded from files
 * * loads admins
 * * Sets up the dynamic menu system
 * * and most importantly, calls initialize on the master subsystem, starting the game loop that causes the rest of the game to begin processing and setting up
 *
 *
 * Nothing happens until something moves. ~Albert Einstein
 *
 * For clarity, this proc gets triggered later in the initialization pipeline, it is not the first thing to happen, as it might seem.
 *
 * Initialization Pipeline:
 * Global vars are new()'ed, (including config, glob, and the master controller will also new and preinit all subsystems when it gets new()ed)
 * Compiled in maps are loaded (mainly centcom). all areas/turfs/objs/mobs(ATOMs) in these maps will be new()ed
 * world/New() (You are here)
 * Once world/New() returns, client's can connect.
 * 1 second sleep
 * Master Controller initialization.
 * Subsystem initialization.
 * Non-compiled-in maps are maploaded, all atoms are new()ed
 * All atoms in both compiled and uncompiled maps are initialized()
 */
/world/New()
	log_world("World loaded at [server_timestamp()]!")

	// First possible sleep()
	InitTgs()

	config.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

	ConfigLoaded()

#ifndef UNIT_TESTS
	immediately_init_dmeow()
#endif

	if(DMEOW_CENSUS_PARAMETER in params)
		run_dmeow_compile_census()
		return

	if(NO_INIT_PARAMETER in params)
		return

#ifdef UNIT_TESTS
	if(DMEOW_START_PARAMATER in params)
		immediately_init_dmeow()
#endif

	Master.Initialize(10, FALSE, TRUE)

	RunUnattendedFunctions()

/// no dmeow_perf_start() here on purpose. it wraps every proc call in a
/// begin/end pair that takes the profiler's lock, and a normal round never reads
/// the result - the shipping DLL doesn't even build dmeow_perf_report(). the
/// panel's "start manual tracking" button turns it on when someone actually
/// wants numbers.
/world/proc/immediately_init_dmeow()
	SEND_TEXT(world.log, "[DMEOW_START_PARAMATER] set, immediately initializing dmeow")
	if(!dmeow_init())
		SEND_TEXT(world.log, "failed to initialize dmeow :(")
		return
	SEND_TEXT(world.log, "dmeow loaded, yay!")
	if(!dmeow_set_hooks(TRUE))
		SEND_TEXT(world.log, "failed to enable dmeow hooks :(")
		return
	dmeow_enable_counting(DMEOW_PERF_DEFAULT_THRESHOLD)
	dmeow_counting_threshold = DMEOW_PERF_DEFAULT_THRESHOLD
	// not under unit tests: the suite runs on a fresh data/ every time, so it
	// would record a capture on every single run and never skip.
	#ifndef UNIT_TESTS
	SEND_TEXT(world.log, "dmeow tracy: [dmeow_tracy_autostart()]")
	#endif

/// Initializes TGS and loads the returned revising info into GLOB.revdata
/world/proc/InitTgs()
	TgsNew(new /datum/tgs_event_handler/impl, TGS_SECURITY_TRUSTED)
	GLOB.revdata.load_tgs_info()

/// Runs after config is loaded but before Master is initialized
/world/proc/ConfigLoaded()
	// Everything in here is prioritized in a very specific way.
	// If you need to add to it, ask yourself hard if what your adding is in the right spot
	// (i.e. basically nothing should be added before load_admins() in here)

	// Try to set round ID
	SSdbcore.InitializeRound()

	SetupLogs()

	load_admins(initial = TRUE)

	load_poll_data()

	// Initialize RETA system - code/modules/reta/reta_system.dm
	reta_init_config()

	if(fexists(RESTART_COUNTER_PATH))
		GLOB.restart_counter = text2num(trim(file2text(RESTART_COUNTER_PATH)))
		fdel(RESTART_COUNTER_PATH)

/**
 * Headless dmeow compile sweep: load the DLL, try to compile every eligible
 * proc, write the report, exit.
 *
 * Deliberately runs *instead of* `Master.Initialize`. Proc bytecode is present
 * the moment the .dmb loads, and the sweep never executes any of the code it
 * compiles, so a full round buys the measurement nothing and costs minutes.
 *
 * Primes the compile cache while it's at it - this sweep already touches
 * every proc BYOND has, so it's the natural place to fill in the file a real
 * round would otherwise have to re-learn from scratch.
 *
 * Writes to `data/dmeow/census/` and also to stdout, so a script that only has
 * the console can still read the answer.
 */
/world/proc/run_dmeow_compile_census()
	if(!dmeow_init())
		log_world("DMEOW_CENSUS: dmeow failed to load, nothing measured")
		shutdown()
		return

	var/report = dmeow_compile_census(TRUE)
	var/filename = "data/dmeow/census/headless_[rustg_unix_timestamp()].txt"
	var/census_file = file(filename)
	census_file << report
	log_world("DMEOW_CENSUS: wrote [filename]")
	log_world(report)
	dmeow_shutdown()
	shutdown()

/// Runs after the call to Master.Initialize, but before the delay kicks in. Used to turn the world execution into some single function then exit
/world/proc/RunUnattendedFunctions()
	#ifdef UNIT_TESTS
	HandleTestRun()
	#endif

	#ifdef AUTOWIKI
	setup_autowiki()
	#endif

	#ifdef PERFORMANCE_TESTS
	queue_performance_tests()
	#endif

	#ifdef DMEOW_BURN_BUILD
	if(DMEOW_BURN_PARAMETER in params)
		queue_dmeow_burn_run()

	if(DMEOW_EQUIV_PARAMETER in params)
		queue_dmeow_equiv_run()
	#endif

/world/proc/HandleTestRun()
	//trigger things to run the whole process
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	CONFIG_SET(number/round_end_countdown, 0)
	var/datum/callback/cb
#ifdef UNIT_TESTS
	cb = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(RunUnitTests))
#else
	cb = VARSET_CALLBACK(SSticker, force_ending, ADMIN_FORCE_END_ROUND)
#endif
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), cb, 10 SECONDS))

/world/proc/queue_performance_tests()
	//trigger things to run the whole process
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	var/datum/callback/cb = CALLBACK(src, PROC_REF(run_performance_tests))
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), cb, 10 SECONDS))

/// Stub proc intended to be filled with code that does some test, profiles it, and logs that test.
/// Intended to be used with line by line macros, but you should live your truth
/world/proc/run_performance_tests()
	// In case we do somethin that could otherwise end the round
	SSticker.delay_end = TRUE
	// Your code goes here

	// Logging goes here
	// (sample line by line) stat_tracking_export_to_csv_later("file_name.csv", GLOB.cost_list, GLOB.count_list)
	SSticker.delay_end = FALSE
	shutdown()

#ifdef DMEOW_BURN_BUILD

/world/proc/queue_dmeow_burn_run()
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	// _addtimer() runs QDELETED() on the callback's object before it queues it,
	// and world isn't a /datum - CALLBACK(src, ...) here would runtime on
	// world.gc_destroyed. route through a GLOBAL_PROC wrapper instead, same as
	// HandleTestRun()'s UNIT_TESTS branch.
	var/datum/callback/cb = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(dmeow_burn_kickoff))
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), cb, 10 SECONDS))

/// world isn't a /datum, so a timer-bound callback can't target a /world/proc
/// directly (see queue_dmeow_burn_run()). this is the GLOBAL_PROC indirection.
/proc/dmeow_burn_kickoff()
	world.run_dmeow_burn()

/// same shape as queue_dmeow_burn_run(), for the air-equivalence probe. its
/// kickoff wrapper lives next to the probe in equiv_probe.dm.
/world/proc/queue_dmeow_equiv_run()
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	var/datum/callback/cb = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(dmeow_equiv_kickoff))
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), cb, 10 SECONDS))

/// reads a burn-round param as a number, falling back to default_value if the
/// param is missing or not a number.
/world/proc/dmeow_burn_param(key, default_value)
	var/raw = params[key]
	if(!raw)
		return default_value
	var/num = text2num(raw)
	return isnull(num) ? default_value : num

/**
 * standard burn-room A/B round, unattended. every abort logs one DMEOW_BURN:
 * line and calls shutdown() instead of running out the clock on a round that
 * measured nothing.
 */
/world/proc/run_dmeow_burn()
	SSticker.delay_end = TRUE

	var/warmup = dmeow_burn_param("dmeow-warmup", DMEOW_PERF_DEFAULT_WARMUP)
	var/window = dmeow_burn_param("dmeow-window", DMEOW_PERF_DEFAULT_WINDOW)
	var/cycles = dmeow_burn_param("dmeow-cycles", DMEOW_PERF_DEFAULT_CYCLES)
	var/threshold = dmeow_burn_param("dmeow-threshold", DMEOW_PERF_DEFAULT_THRESHOLD)
	var/sample_rate = dmeow_burn_param("dmeow-sample-rate", DMEOW_PERF_DEFAULT_SAMPLE_RATE)

	// past this the DLL merges every further window into the last one and drops
	// the per-proc arm totals, and the report still looks normal - so refuse
	// rather than measure something that reads fine and is not what was asked
	// for.
	if(cycles * 2 > DMEOW_PERF_MAX_WINDOWS)
		log_world("DMEOW_BURN: [cycles] cycles is [cycles * 2] windows, over the [DMEOW_PERF_MAX_WINDOWS] the DLL keeps - use [round(DMEOW_PERF_MAX_WINDOWS / 2)] or fewer")
		shutdown()
		return

	// both rooms re-seed on the same period - it lives on the shared
	// atmos_room parent - so a window that isn't a whole number of periods
	// hands each arm a different amount of work whichever load is picked.
	if(window % DMEOW_BURN_RESEED_PERIOD)
		log_world("DMEOW_BURN: window must be a multiple of [DMEOW_BURN_RESEED_PERIOD]s to match the room's reseed period, got [window]s")
		shutdown()
		return

	// an unrecognised name aborts rather than falling back to the burn room -
	// a typo would otherwise quietly measure the wrong workload for a whole run.
	var/load_name = params["dmeow-load"] || "burn"
	var/load_type = dmeow_load_type(load_name)
	if(!load_type)
		log_world("DMEOW_BURN: unknown load '[load_name]' - expected 'burn', 'gradient' or 'path'")
		shutdown()
		return

	// a size the map can't reserve fails in atmos_room/start(), which is checked
	// below, so there's nothing to validate here.
	var/room_size = dmeow_burn_param("dmeow-room-size", DMEOW_BURN_ROOM_SIZE)

	if(!dmeow_init())
		log_world("DMEOW_BURN: dmeow failed to load, nothing measured")
		shutdown()
		return

	// the DLL stays loaded even when the JIT refuses to arm, so every hook keeps
	// answering and a run here would silently measure the interpreter in both
	// arms while looking like a normal report.
	if(!dmeow_armed)
		log_world("DMEOW_BURN: dmeow loaded but the JIT is disabled - a run would only measure the interpreter")
		dmeow_shutdown()
		shutdown()
		return

	for(var/proc_name in dmeow_atmos_target_procs())
		log_world("DMEOW_BURN: [dmeow_compile(proc_name) ? "compiled" : "FAILED to compile"] [proc_name]")

	// every breathing mob churns turfs outside the room for the whole round:
	// breathe() calls remove_air() then assume_air() on its own turf, both of
	// which re-activate it, the exhaled CO2 wakes the nearest scrubber and the
	// missing pressure wakes the vent. none of that is the fixture, and it lands
	// in the same /turf/open/process_cell bucket the room does. headless only -
	// the admin panel builds the same session on a live server.
	// The burn build loads CentCom_minimal and no space levels, so the world is
	// only as big as runtimestation needs - 53x60, where a reservation level
	// offers world.maxx - 2 * SHUTTLE_TRANSIT_BORDER and a 40x40 room wants 42
	// plus a cordon. Growing the world here rather than at compile time because
	// BYOND fixes world bounds from the compiled-in maps and ignores a code
	// value below them. The reservation levels that already exist keep their old
	// size, but request_turf_block_reservation() adds a fresh one sized off
	// world.maxx when they cannot fit the room, which is the path this relies on.
	var/wanted = room_size + DMEOW_BURN_WORLD_MARGIN
	if(world.maxx < wanted || world.maxy < wanted)
		log_world("DMEOW_BURN: growing world from [world.maxx]x[world.maxy] to fit a [room_size]x[room_size] room")
		world.increase_max_x(max(world.maxx, wanted))
		world.increase_max_y(max(world.maxy, wanted))

	var/mobs_deleted = 0
	for(var/mob/living/breather as anything in GLOB.mob_living_list)
		if(breather.client)
			continue
		qdel(breather)
		mobs_deleted++
	log_world("DMEOW_BURN: deleted [mobs_deleted] clientless living mobs")

	var/datum/dmeow_load/atmos_room/load = new load_type(room_size)
	GLOB.dmeow_perf_session = new(threshold, sample_rate, warmup, window, cycles, load)
	GLOB.dmeow_perf_session.on_finish = CALLBACK(src, PROC_REF(finish_dmeow_burn))
	GLOB.dmeow_perf_session.quiet_station = TRUE
	GLOB.dmeow_perf_session.mobs_deleted = mobs_deleted
	GLOB.dmeow_perf_session.begin()

	// atmos_room/start() records a failure and returns FALSE instead of
	// stopping the session, so a full report can come out of a round with an
	// empty room in it unless this is checked explicitly.
	if(load.failure)
		log_world("DMEOW_BURN: [load_name] room failed to start - [load.failure]")
		dmeow_perf_session_stop()
		dmeow_shutdown()
		shutdown()
		return

	log_world("DMEOW_BURN: run started on a [room_size]x[room_size] [load_name] room, [warmup]s warmup then [cycles] x ([window]s JIT + [window]s interpreter), seed [num2text(Master.random_seed, 12)]")

/// on_finish callback from the perf session - finish() already collected the
/// report, so this only has to read it, flush the debug log, and shut down.
/world/proc/finish_dmeow_burn()
	var/list/summary = GLOB.dmeow_perf_session?.summary
	if(summary)
		log_world("DMEOW_BURN: wrote [summary["file"]] ([summary["compared"]] procs comparable)")
	else
		log_world("DMEOW_BURN: run finished but the profiler returned no report")

	// flush before shutdown, or the tail of the run is missing from the JSONL.
	dmeow_debug_flush()
	dmeow_perf_session_stop()
	dmeow_shutdown()
	SSticker.delay_end = FALSE
	shutdown()

#endif

/// Returns a list of data about the world state, don't clutter
/world/proc/get_world_state_for_logging()
	var/data = list()
	data["tick_usage"] = world.tick_usage
	data["tick_lag"] = world.tick_lag
	data["time"] = world.time
	data["timestamp"] = rustg_unix_timestamp()
	return data

/world/proc/SetupLogs()
	var/override_dir = params[OVERRIDE_LOG_DIRECTORY_PARAMETER]
	if(!override_dir)
		var/realtime = world.timeofday
		var/texttime = time2text(realtime, "YYYY/MM/DD", TIMEZONE_UTC)
		GLOB.log_directory = "data/logs/[texttime]/round-"
		GLOB.picture_logging_prefix = "L_[time2text(realtime, "YYYYMMDD", TIMEZONE_UTC)]_"
		GLOB.picture_log_directory = "data/picture_logs/[texttime]/round-"
		if(GLOB.round_id)
			GLOB.log_directory += "[GLOB.round_id]"
			GLOB.picture_logging_prefix += "R_[GLOB.round_id]_"
			GLOB.picture_log_directory += "[GLOB.round_id]"
		else
			var/timestamp = replacetext(server_timestamp(), ":", ".")
			GLOB.log_directory += "[timestamp]"
			GLOB.picture_log_directory += "[timestamp]"
			GLOB.picture_logging_prefix += "T_[timestamp]_"
	else
		GLOB.log_directory = "data/logs/[override_dir]"
		GLOB.picture_logging_prefix = "O_[override_dir]_"
		GLOB.picture_log_directory = "data/picture_logs/[override_dir]"

	logger.init_logging()

	if(Tracy.trace_path)
		rustg_file_write("[Tracy.trace_path]", "[GLOB.log_directory]/tracy.loc")

	var/latest_changelog = file("[global.config.directory]/../html/changelogs/archive/" + time2text(world.timeofday, "YYYY-MM", TIMEZONE_UTC) + ".yml")
	GLOB.changelog_hash = fexists(latest_changelog) ? md5(latest_changelog) : 0 //for telling if the changelog has changed recently

	if(GLOB.round_id)
		log_game("Round ID: [GLOB.round_id]")

	// This was printed early in startup to the world log and config_error.log,
	// but those are both private, so let's put the commit info in the runtime
	// log which is ultimately public.
	log_runtime(GLOB.revdata.get_log_message())

#ifndef USE_CUSTOM_ERROR_HANDLER
	world.log = file("[GLOB.log_directory]/dd.log")
#else
	if (TgsAvailable()) // why
		world.log = file("[GLOB.log_directory]/dd.log") //not all runtimes trigger world/Error, so this is the only way to ensure we can see all of them.
#endif

/// The world.time we last ran maptick, used for stupid reasons
GLOBAL_VAR_INIT(last_maptick_time, 0)
/world/Tick()
	// We need a hook for if maptick has happen yet
	GLOB.last_maptick_time = world.time

/world/Topic(T, addr, master, key)
	TGS_TOPIC //redirect to server tools if necessary

	var/static/list/topic_handlers = TopicHandlers()

	var/list/input = params2list(T)
	var/datum/world_topic/handler
	for(var/I in topic_handlers)
		if(I in input)
			handler = topic_handlers[I]
			break

	if((!handler || initial(handler.log)) && config && CONFIG_GET(flag/log_world_topic))
		log_topic("\"[T]\", from:[addr], master:[master], key:[key]")

	if(!handler)
		return

	handler = new handler()
	return handler.TryRun(input)

/world/proc/AnnouncePR(announcement, list/payload)
	var/static/list/PRcounts = list() //PR id -> number of times announced this round
	var/id = "[payload["pull_request"]["id"]]"
	if(!PRcounts[id])
		PRcounts[id] = 1
	else
		++PRcounts[id]
		if(PRcounts[id] > CONFIG_GET(number/pr_announcements_per_round))
			return

	var/final_composed = span_announce("PR: [announcement]")
	for(var/client/C in GLOB.clients)
		C.AnnouncePR(final_composed)

/world/proc/FinishTestRun()
	set waitfor = FALSE
	var/list/fail_reasons
	if(GLOB)
		if(GLOB.total_runtimes != 0)
			fail_reasons = list("Total runtimes: [GLOB.total_runtimes]")
#ifdef UNIT_TESTS
		if(GLOB.failed_any_test)
			LAZYADD(fail_reasons, "Unit Tests failed!")
#endif
		if(!GLOB.log_directory)
			LAZYADD(fail_reasons, "Missing GLOB.log_directory!")
	else
		fail_reasons = list("Missing GLOB!")
	if(!fail_reasons)
		text2file("Success!", "[GLOB.log_directory]/clean_run.lk")
	else
		log_world("Test run failed!\n[fail_reasons.Join("\n")]")
	sleep(0) //yes, 0, this'll let Reboot finish and prevent byond memes
	qdel(src) //shut it down

/// Returns TRUE if the world should do a TGS hard reboot.
/world/proc/check_hard_reboot()
	if(!TgsAvailable())
		return FALSE
	// byond-tracy can't clean up itself, and thus we should always hard reboot if its enabled, to avoid an infinitely growing trace.
	if(Tracy?.enabled)
		return TRUE
	// duh
	if(dmeow_armed)
		return TRUE
	var/ruhr = CONFIG_GET(number/rounds_until_hard_restart)
	switch(ruhr)
		if(-1)
			return FALSE
		if(0)
			return TRUE
		else
			if(GLOB.restart_counter >= ruhr)
				return TRUE
			else
				text2file("[++GLOB.restart_counter]", RESTART_COUNTER_PATH)
				return FALSE

/world/Reboot(reason = 0, fast_track = FALSE)
	if (reason || fast_track) //special reboot, do none of the normal stuff
		if (usr)
			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools")
		to_chat(world, span_boldannounce("Rebooting World immediately due to host request."))
	else
		to_chat(world, span_boldannounce("Rebooting world..."))
		Master.Shutdown() //run SS shutdowns

	#ifdef UNIT_TESTS
	FinishTestRun()
	return
	#else
	if(check_hard_reboot())
		log_world("World hard rebooted at [server_timestamp()]")
		SSplexora.notify_shutdown(PLEXORA_SHUTDOWN_KILLDD) // OCULIS ADDITION
		shutdown_logging() // See comment below.
		QDEL_NULL(Tracy)
		QDEL_NULL(Debugger)
		dmeow_shutdown()
		TgsEndProcess()
		return ..()

	log_world("World rebooted at [server_timestamp()]")
	SSplexora.notify_shutdown() // OCULIS ADDITION

	shutdown_logging() // Past this point, no logging procs can be used, at risk of data loss.
	QDEL_NULL(Tracy)
	QDEL_NULL(Debugger)
	dmeow_shutdown()

	TgsReboot() // TGS can decide to kill us right here, so it's important to do it last

	..()
	#endif

/world/Del()
	QDEL_NULL(Tracy)
	QDEL_NULL(Debugger)
	dmeow_shutdown()
	. = ..()

/* NOVA EDIT REMOVAL - OVERRIDDEN
/world/proc/update_status()

	var/list/features = list()

	if(LAZYACCESS(SSlag_switch.measures, DISABLE_NON_OBSJOBS))
		features += "closed"

	var/new_status = ""
	var/hostedby
	if(config)
		var/server_name = CONFIG_GET(string/servername)
		if (server_name)
			new_status += "<b>[server_name]</b> "
		if(CONFIG_GET(flag/allow_respawn))
			features += "respawn" // show "respawn" regardless of "respawn as char" or "free respawn"
		if(!CONFIG_GET(flag/allow_ai))
			features += "AI disabled"
		hostedby = CONFIG_GET(string/hostedby)

	if (CONFIG_GET(flag/station_name_in_hub_entry))
		new_status += " &#8212; <b>[station_name()]</b>"

	var/players = GLOB.clients.len

	game_state = (CONFIG_GET(number/extreme_popcap) && players >= CONFIG_GET(number/extreme_popcap)) //tells the hub if we are full

	if (!host && hostedby)
		features += "hosted by <b>[hostedby]</b>"

	if(length(features))
		new_status += ": [jointext(features, ", ")]"

	if(!SSticker || SSticker?.current_state == GAME_STATE_STARTUP)
		new_status += "<br><b>STARTING</b>"
	else if(SSticker)
		if(SSticker.current_state == GAME_STATE_PREGAME && SSticker.GetTimeLeft() > 0)
			new_status += "<br>Starting: <b>[round((SSticker.GetTimeLeft())/10)]</b>"
		else if(SSticker.current_state == GAME_STATE_SETTING_UP)
			new_status += "<br>Starting: <b>Now</b>"
		else if(SSticker.IsRoundInProgress())
			new_status += "<br>Time: <b>[round_timestamp("hh:mm")]</b>"
			if(SSshuttle?.emergency && SSshuttle?.emergency?.mode != (SHUTTLE_IDLE || SHUTTLE_ENDGAME))
				new_status += " | Shuttle: <b>[SSshuttle.emergency.getModeStr()] [SSshuttle.emergency.getTimerStr()]</b>"
		else if(SSticker.current_state == GAME_STATE_FINISHED)
			new_status += "<br><b>RESTARTING</b>"
	if(SSmapping.current_map)
		new_status += "<br>Map: <b>[SSmapping.current_map.map_path == CUSTOM_MAP_PATH ? "Uncharted Territory" : SSmapping.current_map.map_name]</b>"
	if(SSmap_vote.next_map_config)
		new_status += "[SSmapping.current_map ? " | " : "<br>"]Next: <b>[SSmap_vote.next_map_config.map_path == CUSTOM_MAP_PATH ? "Uncharted Territory" : SSmap_vote.next_map_config.map_name]</b>"

	status = new_status
*/

/world/proc/update_hub_visibility(new_visibility)
	if(new_visibility == GLOB.hub_visibility)
		return
	GLOB.hub_visibility = new_visibility
	if(GLOB.hub_visibility)
		hub_password = "kMZy3U5jJHSiBQjr"
	else
		hub_password = "SORRYNOPASSWORD"

/**
 * Handles increasing the world's maxx var and initializing the new turfs and assigning them to the global area.
 * If map_load_z_cutoff is passed in, it will only load turfs up to that z level, inclusive.
 * This is because maploading will handle the turfs it loads itself.
 */
/world/proc/increase_max_x(new_maxx, map_load_z_cutoff = maxz)
	if(new_maxx <= maxx)
		return
	var/old_max = world.maxx
	maxx = new_maxx
	if(!map_load_z_cutoff)
		return
	var/area/global_area = GLOB.areas_by_type[world.area] // We're guaranteed to be touching the global area, so we'll just do this
	LISTASSERTLEN(global_area.turfs_by_zlevel, map_load_z_cutoff, list())
	for (var/zlevel in 1 to map_load_z_cutoff)
		var/list/to_add = block(
			old_max + 1, 1, zlevel,
			maxx, maxy, zlevel
		)

		global_area.turfs_by_zlevel[zlevel] += to_add

/world/proc/increase_max_y(new_maxy, map_load_z_cutoff = maxz)
	if(new_maxy <= maxy)
		return
	var/old_maxy = maxy
	maxy = new_maxy
	if(!map_load_z_cutoff)
		return
	var/area/global_area = GLOB.areas_by_type[world.area] // We're guaranteed to be touching the global area, so we'll just do this
	LISTASSERTLEN(global_area.turfs_by_zlevel, map_load_z_cutoff, list())
	for (var/zlevel in 1 to map_load_z_cutoff)
		var/list/to_add = block(
			1, old_maxy + 1, zlevel,
			maxx, maxy, zlevel
		)
		global_area.turfs_by_zlevel[zlevel] += to_add

/world/proc/incrementMaxZ()
	maxz++
	SSmobs.MaxZChanged()
	SSai_controllers.on_max_z_changed()

/world/proc/change_fps(new_value = 20)
	if(new_value <= 0)
		CRASH("change_fps() called with [new_value] new_value.")
	if(fps == new_value)
		return //No change required.

	fps = new_value
	on_tickrate_change()


/world/proc/change_tick_lag(new_value = 0.5)
	if(new_value <= 0)
		CRASH("change_tick_lag() called with [new_value] new_value.")
	if(tick_lag == new_value)
		return //No change required.

	tick_lag = new_value
	on_tickrate_change()


/world/proc/on_tickrate_change()
	SStimer?.reset_buckets()
#ifndef DISABLE_DREAMLUAU
	DREAMLUAU_SET_EXECUTION_LIMIT_MILLIS(tick_lag * 100)
#endif

/world/Profile(command, type, format)
	if((command & PROFILE_STOP) || !global.config?.loaded || !CONFIG_GET(flag/forbid_all_profiling))
		. = ..()

#undef DMEOW_EQUIV_PARAMETER
#undef DMEOW_START_PARAMATER
#undef DMEOW_BURN_PARAMETER
#undef DMEOW_CENSUS_PARAMETER
#undef NO_INIT_PARAMETER
#undef OVERRIDE_LOG_DIRECTORY_PARAMETER
#undef USE_TRACY_PARAMETER
#undef RESTART_COUNTER_PATH

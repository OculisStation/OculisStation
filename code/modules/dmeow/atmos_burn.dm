// measurement tooling - out of a normal round entirely. the kill switch lives in
// killswitch.dm, which is always compiled.
#ifdef DMEOW_BURN_BUILD

/// fake workload an A/B run can point at, so both arms measure the same thing
/// instead of whatever the round happened to be doing.
/datum/dmeow_load
	var/name = "load"
	var/reseeds = 0
	/// what the last re-seed cost, in TICK_USAGE_REAL. runs on a timer outside
	/// SSair and some of that path compiles, so it's a stall that only lands in
	/// one arm.
	var/reseed_ticks = 0
	/// most of our turfs on fire at once, sampled each re-seed. SSair.hotspots is
	/// station-wide so it can't answer "did *this* room catch".
	var/interior_hotspots = 0

/datum/dmeow_load/proc/start()
	return

/datum/dmeow_load/proc/stop()
	return

/datum/dmeow_load/proc/describe()
	return name

/// sealed reserved room, air re-seeded on a fixed period. the period has to
/// divide the A/B window exactly, or a room that runs itself down puts back the
/// time-varying workload the interleave exists to kill.
/datum/dmeow_load/atmos_room
	/// interior edge in turfs. the reservation is two wider, for walls.
	var/size = DMEOW_BURN_ROOM_SIZE
	var/reseed_period = DMEOW_BURN_RESEED_PERIOD
	var/datum/turf_reservation/reservation
	var/list/turf/open/interior = list()
	var/reseed_timer
	var/failure

/datum/dmeow_load/atmos_room/New(room_size)
	. = ..()
	if(room_size)
		size = room_size

/datum/dmeow_load/atmos_room/Destroy()
	stop()
	return ..()

/datum/dmeow_load/atmos_room/describe()
	if(failure)
		return "[name]: FAILED - [failure]"
	if(!reservation)
		return "[name]: idle"
	return "[name]: [length(interior)] turfs, [reseeds] re-seeds, every [reseed_period]s"

/datum/dmeow_load/atmos_room/start()
	if(reservation)
		return TRUE
	failure = null
	// turf_type_override makes the whole block plating up front, so building the
	// room is one ring of ChangeTurf instead of one call per cell.
	reservation = SSmapping.request_turf_block_reservation(
		size + 2,
		size + 2,
		turf_type_override = /turf/open/floor/plating,
	)
	if(!reservation)
		failure = "no reserved space available"
		world.log << "dmeow: [name] failed - [failure]"
		return FALSE

	build_room()
	seed()
	reseed_timer = addtimer(CALLBACK(src, PROC_REF(seed)), reseed_period SECONDS, TIMER_STOPPABLE | TIMER_LOOP)
	world.log << "dmeow: [name] up, [length(interior)] turfs, re-seeding every [reseed_period]s"
	return TRUE

/datum/dmeow_load/atmos_room/proc/build_room()
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	var/turf/top_right = reservation.top_right_turfs[1]
	for(var/turf/candidate as anything in block(bottom_left, top_right))
		if(candidate.x == bottom_left.x || candidate.x == top_right.x || candidate.y == bottom_left.y || candidate.y == top_right.y)
			candidate.ChangeTurf(/turf/closed/indestructible)
			continue
		interior += candidate

/// subtypes decide what goes in.
/datum/dmeow_load/atmos_room/proc/seed()
	return

/// bounding box and not `cell in interior` - that's a linear scan of ~1600
/// entries, asked once per active turf per SSair fire. box and not "same z"
/// because the reserved z holds other reservations too.
/datum/dmeow_load/atmos_room/proc/contains(turf/cell)
	if(!reservation)
		return FALSE
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	var/turf/top_right = reservation.top_right_turfs[1]
	return cell.z == bottom_left.z \
		&& cell.x >= bottom_left.x && cell.x <= top_right.x \
		&& cell.y >= bottom_left.y && cell.y <= top_right.y

/// active turfs that aren't ours. wants to be 0 - anything else is the station
/// getting measured alongside the fixture, and queue_at_start can't tell the two
/// apart because it's the station-wide queue length.
/datum/dmeow_load/atmos_room/proc/foreign_active_turfs()
	if(!reservation)
		return 0
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	var/turf/top_right = reservation.top_right_turfs[1]
	var/room_z = bottom_left.z
	var/min_x = bottom_left.x
	var/max_x = top_right.x
	var/min_y = bottom_left.y
	var/max_y = top_right.y
	var/foreign = 0
	for(var/turf/cell as anything in SSair.active_turfs)
		if(cell.z == room_z && cell.x >= min_x && cell.x <= max_x && cell.y >= min_y && cell.y <= max_y)
			continue
		foreign++
	return foreign

/// same set by area, for the log line naming what's keeping the station awake.
/datum/dmeow_load/atmos_room/proc/foreign_census()
	var/list/census = list()
	for(var/turf/cell as anything in SSair.active_turfs)
		if(contains(cell))
			continue
		var/area/where = get_area(cell)
		var/key = "[where?.type]"
		census[key] = (census[key] || 0) + 1
	return census

/datum/dmeow_load/atmos_room/stop()
	if(reseed_timer)
		deltimer(reseed_timer)
		reseed_timer = null
	for(var/turf/open/cell as anything in interior)
		if(cell.active_hotspot)
			qdel(cell.active_hotspot)
		SSair.remove_from_active(cell)
	interior.Cut()
	// Release() disconnects every turf from atmos and kills the excited group.
	// that's the bit a hand-rolled teardown always forgets.
	QDEL_NULL(reservation)
	return TRUE

/// the room stuffed with plasma and oxygen and set on fire. BURNMIX_ATMOS sits
/// at 370K, ~3K under FIRE_MINIMUM_TEMPERATURE_TO_EXIST, so it needs lighting
/// rather than catching on its own.
/datum/dmeow_load/atmos_room/burn
	name = "atmos burn room"
	var/list/turf/open/ignition_points = list()

/// a grid rather than the four interior corners - corners never reach the middle
/// of a 40x40 room inside one re-seed. at size 10 it's still 4 points, but inset,
/// so re-baseline 10x10 before comparing against a bigger room.
/datum/dmeow_load/atmos_room/burn/build_room()
	. = ..()
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	var/first = round(DMEOW_IGNITION_SPACING / 2)
	for(var/x_offset = first, x_offset < size, x_offset += DMEOW_IGNITION_SPACING)
		for(var/y_offset = first, y_offset < size, y_offset += DMEOW_IGNITION_SPACING)
			var/turf/open/point = locate(bottom_left.x + 1 + x_offset, bottom_left.y + 1 + y_offset, bottom_left.z)
			if(point)
				ignition_points += point

/// copy_from and not merge, so every re-seed lands on exactly the same mixture.
/datum/dmeow_load/atmos_room/burn/seed()
	if(!reservation)
		return
	var/timer = TICK_USAGE_REAL
	var/datum/gas_mixture/burn_mix = SSair.parse_gas_string(BURNMIX_ATMOS, /datum/gas_mixture/turf)
	var/lit = 0
	for(var/turf/open/cell as anything in interior)
		if(cell.active_hotspot)
			lit++
		cell.air.copy_from(burn_mix)
		cell.archive()
		SSair.add_to_active(cell)
	interior_hotspots = max(interior_hotspots, lit)
	// volume 100 turns into one CELL_VOLUME of hotspot, same as a normal igniter.
	for(var/turf/open/point as anything in ignition_points)
		point.hotspot_expose(1000, 100, TRUE)
	reseeds++
	reseed_ticks = TICK_USAGE_REAL - timer

/datum/dmeow_load/atmos_room/burn/stop()
	. = ..()
	ignition_points.Cut()

/// same room with no fire: hot dense nitrogen one half, cold thin the other.
/// nothing in reactions.dm fires without a second gas, so it moves gas and heat
/// hard and can't catch. that's the point - no hotspots means no count to
/// diverge, so both arms provably chew the same turfs and only time differs.
/// half-and-half and not a checkerboard, because one front keeps moving gas for
/// longer.
/datum/dmeow_load/atmos_room/gradient
	name = "atmos gradient room"

/datum/dmeow_load/atmos_room/gradient/seed()
	if(!reservation)
		return
	var/timer = TICK_USAGE_REAL
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	var/turf/top_right = reservation.top_right_turfs[1]
	var/midpoint = (bottom_left.x + top_right.x) / 2
	var/datum/gas_mixture/hot_mix = SSair.parse_gas_string(DMEOW_GRADIENT_HOT, /datum/gas_mixture/turf)
	var/datum/gas_mixture/cold_mix = SSair.parse_gas_string(DMEOW_GRADIENT_COLD, /datum/gas_mixture/turf)
	var/lit = 0
	for(var/turf/open/cell as anything in interior)
		if(cell.active_hotspot)
			lit++
		cell.air.copy_from(cell.x < midpoint ? hot_mix : cold_mix)
		cell.archive()
		SSair.add_to_active(cell)
	// running max - a hotspot that flared and died between two re-seeds still
	// means the mix can burn and the room's lost its reason to exist.
	interior_hotspots = max(interior_hotspots, lit)
	reseeds++
	reseed_ticks = TICK_USAGE_REAL - timer

/// same sealed room, no gas work at all: a fixed maze of walls and railings, and
/// every re-seed asks LinkBlockedWithAccess for each open turf and its eight
/// neighbours. the burn runner deletes clientless mobs, so nothing else in a
/// headless round calls it. fixed synchronous loop, so both arms make exactly the
/// same number of calls however fast either one is.
/datum/dmeow_load/atmos_room/path_maze
	name = "pathing maze room"
	/// calls made by the last re-seed. same every time once the maze is built.
	var/checks_per_seed = 0

/datum/dmeow_load/atmos_room/path_maze/build_room()
	. = ..()
	var/list/turf/open/maze_floor = list()
	for(var/turf/open/cell as anything in interior)
		// sparse wall grid, so plenty of neighbours are dense and the proc's early
		// density exit gets its share of calls too.
		if(cell.x % 4 == 0 && cell.y % 3 == 0)
			cell.ChangeTurf(/turf/closed/indestructible)
			continue
		maze_floor += cell
		// railings face all four ways so the source-side border check both hits and
		// misses. these are the obj-in-turf loops the JIT change was about.
		if((cell.x + cell.y) % 5 == 0)
			var/obj/structure/railing/rail = new(cell)
			rail.setDir(GLOB.cardinals[(cell.x % 4) + 1])
		// non-dense clutter, which the destination loop has to look at and skip.
		if((cell.x * cell.y) % 7 == 0)
			new /obj/item/stack/rods(cell)
	interior = maze_floor

/datum/dmeow_load/atmos_room/path_maze/seed()
	if(!reservation)
		return
	var/timer = TICK_USAGE_REAL
	var/datum/can_pass_info/pass_info = new(null, null, FALSE)
	var/checks = 0
	for(var/turf/open/cell as anything in interior)
		for(var/step_dir in GLOB.alldirs)
			var/turf/next = get_step(cell, step_dir)
			if(!next || !contains(next))
				continue
			cell.LinkBlockedWithAccess(next, pass_info)
			checks++
	checks_per_seed = checks
	reseeds++
	reseed_ticks = TICK_USAGE_REAL - timer

/datum/dmeow_load/atmos_room/path_maze/describe()
	if(failure || !reservation)
		return ..()
	return "[..()], [checks_per_seed] step checks per re-seed"

/// world param value -> load type. unknown name returns null so the caller can
/// abort - falling back to the burn room would quietly measure the wrong
/// workload for a whole round.
/proc/dmeow_load_type(load_name)
	switch(load_name)
		if("burn")
			return /datum/dmeow_load/atmos_room/burn
		if("gradient")
			return /datum/dmeow_load/atmos_room/gradient
		if("path")
			return /datum/dmeow_load/atmos_room/path_maze
	return null

/// standalone burn, for poking at the load without a whole A/B run.
GLOBAL_DATUM(dmeow_standalone_burn, /datum/dmeow_load/atmos_room/burn)

/// the verb and the panel button share this so the "a run already owns one"
/// guard can't go missing from one of them - two burn rooms at once wreck the
/// measurement.
/proc/dmeow_toggle_standalone_burn()
	if(GLOB.dmeow_perf_session?.load)
		return "the running profiling session owns the burn room"
	if(GLOB.dmeow_standalone_burn)
		QDEL_NULL(GLOB.dmeow_standalone_burn)
		return "burn room torn down"

	GLOB.dmeow_standalone_burn = new /datum/dmeow_load/atmos_room/burn()
	if(GLOB.dmeow_standalone_burn.start())
		return GLOB.dmeow_standalone_burn.describe()
	// describe() before the qdel, it's the only place the reason lives.
	var/failure = GLOB.dmeow_standalone_burn.describe()
	QDEL_NULL(GLOB.dmeow_standalone_burn)
	return failure

ADMIN_VERB(dmeow_burn_room, R_DEBUG, "dmeow burn room", "Toggle a sealed plasma fire for JIT load testing.", ADMIN_CATEGORY_DEBUG)
	message_admins("dmeow: [dmeow_toggle_standalone_burn()]")

#endif

#ifdef DMEOW_BURN_BUILD

/// the sealed room split into four zones that never connect, each shaped for a
/// different kind of search, and every re-seed runs a fixed set of JPS searches
/// (bots and basic mobs) and oculis A* searches (the Navigate verb) through them.
/// searches run to completion inside the timer, so both arms do identical work.
/// nothing else in a headless round pathfinds - the burn runner deletes the mobs.
///
/// zones, in zone-local coords 1..39 (column and row 40 are the divider wall):
/// doors (bottom left), pillared hall (bottom right), maze (top left), clutter
/// (top right).
/datum/dmeow_load/atmos_room/pathfind
	name = "pathfinding room"
	/// zone pitch, divider included. the room has to be exactly two zones wide.
	var/zone = 40
	/// door grid pitch, walls included. 8 in a zone gives a 5x5 grid of 7x7 rooms.
	var/cell = 8
	/// door grid cell centers, one per room.
	var/list/turf/open/room_centers = list()
	var/list/turf/open/hall_floor = list()
	/// maze cell centers only, so a route never starts inside a wall gap.
	var/list/turf/open/maze_cells = list()
	/// clutter floor with no table on it.
	var/list/turf/open/clutter_floor = list()
	/// clutter's bottom row, backing onto the hall's divider wall.
	var/list/turf/open/clutter_edge = list()
	/// zone-local "x,y" index -> TRUE for every open maze spot. built before any
	/// turf changes, since the carve has to see the whole grid.
	var/list/maze_open
	/// our own generator and not rand(): anything else rolling during init would
	/// shift rand() and move the maze with it, and rounds wouldn't compare.
	var/lcg_state = 12345
	/// the thing doing the pathing. shapes can_pass_info, and A* starts from
	/// wherever it stands.
	var/obj/item/pen/requester
	var/list/datum/dmeow_path_scenario/scenarios = list()
	/// re-seeds inside the timed part, per arm. both non-zero with no mismatch
	/// logged is the claim that the JIT and the interpreter found the same paths.
	var/timed_seeds_jit = 0
	var/timed_seeds_interp = 0

/datum/dmeow_load/atmos_room/pathfind/start()
	if(size != zone * 2)
		failure = "needs --room-size=[zone * 2], got [size]"
		world.log << "dmeow: [name] failed - [failure]"
		return FALSE
	return ..()

/datum/dmeow_load/atmos_room/pathfind/stop()
	QDEL_LIST(scenarios)
	QDEL_NULL(requester)
	room_centers.Cut()
	hall_floor.Cut()
	maze_cells.Cut()
	clutter_floor.Cut()
	clutter_edge.Cut()
	return ..()

/// 1..count
/datum/dmeow_load/atmos_room/pathfind/proc/lcg_pick(count)
	// ZX81's constants: every product stays under 2^24, so float maths is exact
	lcg_state = (lcg_state * 75 + 74) % 65537
	return (lcg_state % count) + 1

/datum/dmeow_load/atmos_room/pathfind/build_room()
	. = ..()
	// the reservation's area needs power for airlock and windoor CanAStarPass to
	// get past hasPower(). has to happen before the machines spawn so they
	// Initialize powered.
	var/area/powered_area = GLOB.areas_by_type[/area/misc/testroom] || new /area/misc/testroom
	set_turfs_to_area(block(reservation.bottom_left_turfs[1], reservation.top_right_turfs[1]), powered_area)
	carve_maze()

	var/turf/origin = reservation.bottom_left_turfs[1]
	var/list/turf/open/floor = list()
	var/door_count = 0
	for(var/turf/open/spot as anything in interior)
		var/zone_x = round((spot.x - origin.x - 1) / zone)
		var/zone_y = round((spot.y - origin.y - 1) / zone)
		var/local_x = spot.x - origin.x - zone_x * zone
		var/local_y = spot.y - origin.y - zone_y * zone
		var/stays_open = FALSE
		if(local_x != zone && local_y != zone)
			switch(zone_x + zone_y * 2)
				if(0)
					stays_open = build_doors_spot(spot, local_x, local_y, door_count)
					if(stays_open && (local_x % cell == 0 || local_y % cell == 0))
						door_count++
				if(1)
					stays_open = build_hall_spot(spot, local_x, local_y)
				if(2)
					stays_open = build_maze_spot(spot, local_x, local_y)
				if(3)
					stays_open = build_clutter_spot(spot, local_x, local_y)
		if(!stays_open)
			spot.ChangeTurf(/turf/closed/indestructible)
			continue
		floor += spot
	interior = floor
	maze_open = null
	// a pen and not rods: A* hops the requester onto every start, and a stack
	// merges into the junk rods on the clutter floor and deletes itself
	requester = new /obj/item/pen(room_centers[1])
	make_scenarios()

/// doorway at the middle of each wall segment, walls everywhere else.
/datum/dmeow_load/atmos_room/pathfind/proc/build_doors_spot(turf/open/spot, local_x, local_y, door_index)
	var/on_wall_x = local_x % cell == 0
	var/on_wall_y = local_y % cell == 0
	if(!on_wall_x && !on_wall_y)
		if(local_x % cell == cell / 2 && local_y % cell == cell / 2)
			room_centers += spot
		furnish(spot, local_x % cell, local_y % cell)
		return TRUE
	var/along = on_wall_x ? local_y % cell : local_x % cell
	if(on_wall_x && on_wall_y || along != cell / 2)
		return FALSE
	place_door(spot, on_wall_x ? EAST : NORTH, door_index)
	return TRUE

/// door kind rotates on the doorway's position, so every kind shows up on
/// every route and the id cards disagree about which ones are open.
/datum/dmeow_load/atmos_room/pathfind/proc/place_door(turf/open/doorway, facing, door_index)
	switch(door_index % 6)
		if(0)
			new /obj/machinery/door/airlock(doorway)
		if(1)
			var/obj/machinery/door/airlock/engineering/locked_door = new(doorway)
			locked_door.req_access = list(ACCESS_ENGINEERING)
		if(2)
			var/obj/machinery/door/airlock/medical/locked_door = new(doorway)
			locked_door.req_access = list(ACCESS_MEDICAL)
		if(3)
			var/obj/machinery/door/window/windoor = new(doorway)
			windoor.setDir(facing)
			windoor.req_access = list(ACCESS_SECURITY)
		if(4)
			// open firedoor: directional, but skipped for being non-dense
			var/obj/machinery/door/firedoor/border_only/firedoor = new(doorway)
			firedoor.setDir(facing)
		if(5)
			return

/// same clutter in every room: a table row, a directional window, a railing, and
/// non-dense junk the destination loop has to look at and skip.
/datum/dmeow_load/atmos_room/pathfind/proc/furnish(turf/open/spot, room_x, room_y)
	if(room_y == 2 && room_x >= 2 && room_x <= 3)
		new /obj/structure/table(spot)
	else if(room_x == 6 && room_y == 3)
		var/obj/structure/window/pane = new(spot)
		pane.setDir(WEST)
	else if(room_x == 3 && room_y == 6)
		var/obj/structure/railing/rail = new(spot)
		rail.setDir(SOUTH)
	else if((room_x * room_y) % 5 == 0)
		new /obj/item/stack/rods(spot)

/// bare floor and a pillar every 5 tiles. JPS's lateral scans run until they hit
/// something, so this is where they run longest.
/datum/dmeow_load/atmos_room/pathfind/proc/build_hall_spot(turf/open/spot, local_x, local_y)
	if(local_x % 5 == 0 && local_y % 5 == 0)
		return FALSE
	hall_floor += spot
	return TRUE

/datum/dmeow_load/atmos_room/pathfind/proc/build_maze_spot(turf/open/spot, local_x, local_y)
	if(!maze_open["[local_x],[local_y]"])
		return FALSE
	if(local_x % 2 && local_y % 2)
		maze_cells += spot
	return TRUE

/// depth-first carve over the odd coords, then a few extra walls knocked out.
/// a perfect maze has exactly one route between any two cells, which is not
/// what a station looks like and gives A* nothing to choose between.
/datum/dmeow_load/atmos_room/pathfind/proc/carve_maze()
	var/span = zone - 1
	var/static/list/offsets = list(list(0, 2), list(2, 0), list(0, -2), list(-2, 0))
	maze_open = list("1,1" = TRUE)
	var/list/stack = list(list(1, 1))
	while(length(stack))
		var/list/here = stack[length(stack)]
		var/list/choices = list()
		for(var/list/offset as anything in offsets)
			var/next_x = here[1] + offset[1]
			var/next_y = here[2] + offset[2]
			if(next_x < 1 || next_y < 1 || next_x > span || next_y > span || maze_open["[next_x],[next_y]"])
				continue
			choices += list(list(next_x, next_y))
		if(!length(choices))
			stack.len--
			continue
		var/list/next = choices[lcg_pick(length(choices))]
		maze_open["[next[1]],[next[2]]"] = TRUE
		maze_open["[(here[1] + next[1]) / 2],[(here[2] + next[2]) / 2]"] = TRUE
		stack += list(next)
	// one odd and one even coord is always a wall between two cells
	for(var/attempt in 1 to 60)
		var/gap_x = lcg_pick(span)
		var/gap_y = lcg_pick(span)
		if((gap_x + gap_y) % 2)
			maze_open["[gap_x],[gap_y]"] = TRUE

/// a messy room: table rows with gaps (dense, climbable, so A*'s slowdown
/// heuristic has something to weigh), directional windows and railings facing
/// every way, and non-dense junk on a third of the floor.
/datum/dmeow_load/atmos_room/pathfind/proc/build_clutter_spot(turf/open/spot, local_x, local_y)
	if(local_y % 6 == 3 && local_x % 8 >= 2 && local_x % 8 <= 5)
		new /obj/structure/table(spot)
		return TRUE
	if(local_y % 6 == 0 && local_x % 5 == 2)
		var/obj/structure/window/pane = new(spot)
		pane.setDir(GLOB.cardinals[(local_x % 4) + 1])
	else if((local_x + 2 * local_y) % 11 == 0)
		var/obj/structure/railing/rail = new(spot)
		rail.setDir(GLOB.cardinals[(local_y % 4) + 1])
	if((local_x * local_y) % 3 == 0)
		new /obj/item/stack/rods(spot)
	clutter_floor += spot
	if(local_y == 1)
		clutter_edge += spot
	return TRUE

/datum/dmeow_load/atmos_room/pathfind/proc/make_scenarios()
	var/static/list/id_cards = list(
		list(),
		list(ACCESS_ENGINEERING),
		list(ACCESS_ENGINEERING, ACCESS_MEDICAL, ACCESS_SECURITY),
	)
	var/list/all_access = id_cards[3]

	// route counts from here down keep one interpreted re-seed near 3s, inside
	// the 5s re-seed period. A* is most of it: ~58ms a search in the hall.

	// every card, from every third room to the room 7 along. a fixed stride, so
	// routes cross the whole grid instead of going next door.
	var/list/door_routes = list()
	var/room_count = length(room_centers)
	for(var/list/access as anything in id_cards)
		for(var/from_index = 1, from_index <= room_count, from_index += 3)
			door_routes += list(list(access, room_centers[from_index], room_centers[((from_index + 6) % room_count) + 1]))
	add_scenario(/datum/dmeow_path_scenario/doors, door_routes)

	var/list/hop_routes = list()
	for(var/turf/center as anything in room_centers)
		for(var/turf/neighbor in list(locate(center.x + cell, center.y, center.z), locate(center.x, center.y + cell, center.z)))
			if(neighbor in room_centers)
				hop_routes += list(list(all_access, center, neighbor))
	add_scenario(/datum/dmeow_path_scenario/hops, hop_routes)

	add_scenario(/datum/dmeow_path_scenario/hall, far_routes(hall_floor, 8, 20))
	add_scenario(/datum/dmeow_path_scenario/maze, far_routes(maze_cells, 6, 20))
	add_scenario(/datum/dmeow_path_scenario/clutter, far_routes(clutter_floor, 8, 10))

	// two tiles away and on the far side of the divider, so neither pathfinder
	// can rule it out by distance and both search everything they're allowed to
	var/list/walled_routes = list()
	for(var/edge_index = 2, edge_index <= length(clutter_edge), edge_index += 13)
		var/turf/start = clutter_edge[edge_index]
		walled_routes += list(list(list(), start, locate(start.x, start.y - 2, start.z)))
	add_scenario(/datum/dmeow_path_scenario/walled_off, walled_routes)

/datum/dmeow_load/atmos_room/pathfind/proc/add_scenario(scenario_type, list/routes)
	scenarios += new scenario_type(routes, requester, reservation.bottom_left_turfs[1])

/// no access, since only the door zone has doors.
/datum/dmeow_load/atmos_room/pathfind/proc/far_routes(list/turf/candidates, count, min_distance)
	. = list()
	while(length(.) < count)
		var/turf/start = candidates[lcg_pick(length(candidates))]
		var/turf/goal = candidates[lcg_pick(length(candidates))]
		if(get_dist(start, goal) >= min_distance)
			. += list(list(list(), start, goal))

/datum/dmeow_load/atmos_room/pathfind/seed()
	if(!reservation)
		return
	var/timer = TICK_USAGE_REAL
	if(GLOB.dmeow_perf_session?.phase == "interleave")
		if(dmeow_hooks_enabled)
			timed_seeds_jit++
		else
			timed_seeds_interp++
	for(var/datum/dmeow_path_scenario/scenario as anything in scenarios)
		scenario.run_routes(reseeds + 1)
	reseeds++
	reseed_ticks = TICK_USAGE_REAL - timer

/datum/dmeow_load/atmos_room/pathfind/describe()
	if(failure || !reservation)
		return ..()
	var/mismatches = 0
	var/list/lines = list("[..()], [timed_seeds_jit] timed re-seeds with the JIT on and [timed_seeds_interp] off")
	for(var/datum/dmeow_path_scenario/scenario as anything in scenarios)
		mismatches += scenario.mismatches
		lines += scenario.describe()
	lines[1] += ", [mismatches] path mismatches"
	return lines.Join("\n")

/// one scenario's routes and search settings. the subtypes exist only so the
/// report gets a row per scenario and pathfinder: a row is a proc, and DM can't
/// make procs at runtime, so each subtype re-declares both searches as a bare
/// ..() and that override's inclusive time is one whole search - setup, the
/// search, path cleanup and teardown.
/datum/dmeow_path_scenario
	var/name
	/// list(access, start turf, goal turf) per route
	var/list/routes
	var/atom/movable/requester
	/// paths are hashed relative to this, so the digest survives the room
	/// landing somewhere else next round
	var/turf/origin
	var/jps_range = 60
	/// maxnodes, same as the Navigate verb passes. 0 is unlimited.
	var/astar_range = 125
	var/min_distance = 0
	/// pathfinder -> md5 of every path from the last re-seed
	var/list/digests = list()
	/// pathfinder -> one line on the last re-seed, for describe()
	var/list/summaries = list()
	var/mismatches = 0
	/// distinct tiles the current batch's searches looked at, so a slow
	/// pathfinder can be told apart from one that just looks at more tiles
	var/touched = 0

/datum/dmeow_path_scenario/New(list/routes, atom/movable/requester, turf/origin)
	. = ..()
	src.routes = routes
	src.requester = requester
	src.origin = origin

/datum/dmeow_path_scenario/Destroy(force)
	routes = null
	requester = null
	origin = null
	return ..()

/datum/dmeow_path_scenario/proc/run_routes(reseed)
	var/list/paths = list()
	touched = 0
	var/timer = TICK_USAGE_REAL
	for(var/list/route as anything in routes)
		paths += list(jps_search(route))
	check_paths("JPS", paths, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), reseed)

	paths = list()
	touched = 0
	timer = TICK_USAGE_REAL
	for(var/list/route as anything in routes)
		paths += list(astar_search(route))
	check_paths("A*", paths, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), reseed)

/// the list a caller of get_path_to() would get, or null if start() refused.
/datum/dmeow_path_scenario/proc/jps_search(list/route)
	var/list/hand_around = list()
	var/datum/pathfind/jps/search = new()
	search.setup(requester, route[1], jps_range, TRUE, null, list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), hand_around)), route[3], min_distance, TRUE, DIAGONAL_REMOVE_CLUNKY)
	search.start = route[2]
	if(!search.start())
		qdel(search)
		return null
	while(!search.path && !search.open.is_empty())
		if(!search.search_step())
			break
	touched += length(search.found_turfs)
	search.finished()
	return hand_around[1]

/// A* always starts from the requester's turf, so it hops to the start first.
/// path and open are private to the datum, hence vars[].
/datum/dmeow_path_scenario/proc/astar_search(list/route)
	requester.abstract_move(route[2])
	var/list/hand_around = list()
	var/datum/pathfind/astar/search = new()
	// maxnodedepth too, or a 0 maxnodes falls back to setup()'s default depth of 30
	search.setup(requester, route[3], maxnodes = astar_range, maxnodedepth = astar_range, mintargetdist = min_distance, access = route[1], smooth_diagonals = FALSE, on_finish = list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), hand_around)))
	if(!search.start())
		qdel(search)
		return null
	while(!search.vars["path"] && length(search.vars["open"]))
		if(!search.search_step())
			break
	// closed also holds neighbours it only ruled out, same as found_turfs does
	touched += length(search.vars["closed"])
	search.finished()
	return hand_around[1]

/// logs the first digest, and loudly on any change after it. the arms swap
/// every window, so a change is the JIT and the interpreter disagreeing about
/// a path.
/datum/dmeow_path_scenario/proc/check_paths(pathfinder, list/paths, elapsed_ms, reseed)
	var/list/parts = list()
	var/found = 0
	var/steps = 0
	for(var/list/path as anything in paths)
		if(!length(path))
			parts += "-"
			continue
		found++
		steps += length(path)
		var/list/coords = list()
		for(var/turf/path_turf as anything in path)
			coords += "[path_turf.x - origin.x],[path_turf.y - origin.y]"
		parts += coords.Join(";")
	var/digest = md5(parts.Join("|"))
	summaries[pathfinder] = "[pathfinder] [found] found, [steps] steps, [touched] tiles touched, [round(elapsed_ms)] ms"
	var/previous = digests[pathfinder]
	digests[pathfinder] = digest
	if(previous == digest)
		return
	if(isnull(previous))
		world.log << "dmeow: pathfind [name] [pathfinder]: [found]/[length(paths)] found, [steps] steps, digest [digest]"
		return
	mismatches++
	world.log << "dmeow: PATH MISMATCH pathfind [name] [pathfinder] on re-seed [reseed] with the JIT [dmeow_hooks_enabled ? "on" : "off"]: [found]/[length(paths)] found, [steps] steps, digest [previous] -> [digest]"

/datum/dmeow_path_scenario/proc/describe()
	return "  [name]: [length(routes)] routes; [summaries["JPS"]]; [summaries["A*"]]; [mismatches] mismatches"

/// the door grid, every card, a route across the grid. a bot on a delivery.
/datum/dmeow_path_scenario/doors
	name = "doors"

/datum/dmeow_path_scenario/doors/jps_search(list/route)
	return ..()

/datum/dmeow_path_scenario/doors/astar_search(list/route)
	return ..()

/// the door grid, next room over, all access. short enough that setup and
/// teardown are most of the cost.
/datum/dmeow_path_scenario/hops
	name = "hops"
	jps_range = 30

/datum/dmeow_path_scenario/hops/jps_search(list/route)
	return ..()

/datum/dmeow_path_scenario/hops/astar_search(list/route)
	return ..()

/datum/dmeow_path_scenario/hall
	name = "hall"

/datum/dmeow_path_scenario/hall/jps_search(list/route)
	return ..()

/datum/dmeow_path_scenario/hall/astar_search(list/route)
	return ..()

/// maze routes run far past 60 steps, so both limits are lifted. no real caller
/// does this; it's here for the long winding search.
/datum/dmeow_path_scenario/maze
	name = "maze"
	jps_range = 400
	astar_range = 0

/datum/dmeow_path_scenario/maze/jps_search(list/route)
	return ..()

/datum/dmeow_path_scenario/maze/astar_search(list/route)
	return ..()

/// stop one tile short, like a mob closing in on a target.
/datum/dmeow_path_scenario/clutter
	name = "clutter"
	min_distance = 1

/datum/dmeow_path_scenario/clutter/jps_search(list/route)
	return ..()

/datum/dmeow_path_scenario/clutter/astar_search(list/route)
	return ..()

/// the target is behind a wall, so every search fails after trying everything
/// in reach. JPS gets get_path_to()'s default range.
/datum/dmeow_path_scenario/walled_off
	name = "walled_off"
	jps_range = 30

/datum/dmeow_path_scenario/walled_off/jps_search(list/route)
	return ..()

/datum/dmeow_path_scenario/walled_off/astar_search(list/route)
	return ..()

#endif

/turf/proc/reachable_turf_test(requester, turf/target, datum/can_pass_info/pass_info)
	if(!target || target.density)
		return FALSE
	if(!target.can_cross_safely(requester)) // dangerous turf! lava or openspace (or others in the future)
		return FALSE
	var/z_distance = abs(target.z - z)
	if(!z_distance) // standard check for same-z pathing
		return !LinkBlockedWithAccess(target, pass_info)
	if(z_distance != 1) // no single movement lets you move more than one z-level at a time (currently; update if this changes)
		return FALSE
	if(target.z > z) // going up stairs
		var/obj/structure/stairs/stairs = locate() in src
		if(stairs?.isTerminator() && target == get_step_multiz(src, stairs.dir | UP))
			return TRUE
	else if(isopenspaceturf(src)) // going down stairs
		var/turf/turf_below = GET_TURF_BELOW(src)
		if(!turf_below || target != turf_below)
			return FALSE
		var/obj/structure/stairs/stairs_below = locate() in turf_below
		if(stairs_below?.isTerminator())
			return TRUE
	return FALSE

/// Returns an additional distance factor based on slowdown and other factors.
/// A* adds this for both turfs of every step, see ASTAR_STEP_COST.
/turf/proc/get_heuristic_slowdown(mob/traverser, travel_dir)
	. = astar_weight
	var/area/current_area = loc
	if(current_area?.astar_weight)
		. += current_area.astar_weight

/// Helper function to compute 3D Manhattan distance.
/turf/proc/distance_3d(turf/other)
	if (!istype(other))
		return 0
	var/dx = abs(x - other.x)
	var/dy = abs(y - other.y)
	var/dz = abs(z - other.z) * 5 // Weight z-level differences higher
	return (dx + dy + dz)

/// Returns the 3D Manhattan between two objects.
/proc/get_dist_3d(atom/source, atom/target)
	var/turf/source_turf = get_turf(source)
	return source_turf.distance_3d(get_turf(target))

/turf/open/get_heuristic_slowdown(mob/traverser, travel_dir)
	. = ..()
	if(slowdown)
		. += slowdown * 10

	var/liquid_state = liquids?.liquid_state
	if(liquid_state)
		if(liquid_state == LIQUID_STATE_FULLTILE)
			. += 20
		else if(liquid_state == LIQUID_STATE_SHOULDERS)
			. += 10
		else if(liquid_state == LIQUID_STATE_WAIST)
			. += 5
		else if(liquid_state == LIQUID_STATE_ANKLES)
			. += 3
		else if(liquid_state == LIQUID_STATE_PUDDLE)
			. += 2

	// i don't like these, but they can be improved later ~Lucy
	// add cost from climbable obstacles
	for(var/obj/structure/some_object in src)
		if(some_object.density && HAS_TRAIT(some_object, TRAIT_CLIMBABLE))
			. += 2 // extra tile penalty
			break

	// door will have to be opened
	var/obj/machinery/door/door = locate() in src
	if(door?.density && !door.locked)
		. += 5 // try to avoid closed doors where possible

/turf/proc/reachable_turf_test(atom/movable/requester, turf/target, datum/can_pass_info/pass_info)
	if(!target || target.density)
		return FALSE
	if(!target.can_cross_safely(requester)) // lava, openspace, etc
		return FALSE
	var/z_distance = abs(target.z - z)
	if(!z_distance)
		return !LinkBlockedWithAccess(target, pass_info)
	if(z_distance != 1) // nothing moves more than one z-level at a time
		return FALSE
	if(target.z > z)
		var/obj/structure/stairs/stairs = locate() in src
		if(stairs?.isTerminator() && target == get_step_multiz(src, stairs.dir | UP))
			// same two checks stair_ascend does before it moves anyone
			return requester.can_z_move(UP, src, null, ZMOVE_ALLOW_BUCKLED) && !requester.can_z_move(DOWN, target, null, ZMOVE_FALL_FLAGS)
	else if(isopenspaceturf(src))
		var/turf/turf_below = GET_TURF_BELOW(src)
		if(!turf_below || target != turf_below)
			return FALSE
		var/obj/structure/stairs/stairs_below = locate() in turf_below
		if(stairs_below?.isTerminator())
			return TRUE
	return FALSE

/// Returns an additional distance factor based on slowdown and other factors.
/// A* adds this for both turfs of every step, see ASTAR_STEP_COST.
/turf/proc/get_heuristic_slowdown()
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

/turf/open/get_heuristic_slowdown()
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

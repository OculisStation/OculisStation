/// Initiates an A* pathfind. Returns true if we're good, FALSE if something's failed
/datum/controller/subsystem/pathfinder/proc/astar_pathfind(requester, end, maxnodes, maxnodedepth = 30, mintargetdist, list/access = list(), turf/exclude, simulated_only = TRUE, check_z_levels = TRUE, smooth_diagonals = TRUE, list/datum/callback/on_finish)
	var/datum/pathfind/astar/path = new()
	path.setup(requester, end, maxnodes, maxnodedepth, mintargetdist, access, exclude, simulated_only, check_z_levels, smooth_diagonals, on_finish)
	if(path.start())
		active_pathing += path
		return TRUE
	return FALSE

/proc/get_astar_path_to(atom/movable/requester, atom/end, maxnodes, maxnodedepth = 30, mintargetdist, list/access = list(), turf/exclude, simulated_only = TRUE, check_z_levels = TRUE, smooth_diagonals = TRUE)
	var/list/hand_around = list()
	// We're guaranteed that list will be the first list in pathfinding_finished's argset because of how callback handles the arguments list
	var/datum/callback/await = list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), hand_around))
	if(!SSpathfinder.astar_pathfind(requester, end, maxnodes, maxnodedepth, mintargetdist, access, exclude, simulated_only, check_z_levels, smooth_diagonals, await))
		return list()

	UNTIL(length(hand_around))
	var/list/return_val = hand_around[1]
	if(!islist(return_val) || (QDELETED(requester) || QDELETED(end))) // It's trash, just hand back empty to make it easy
		return list()
	return return_val

#define ATURF 1
#define TOTAL_COST_F 2
#define DIST_FROM_START_G 3
#define HEURISTIC_H 4
#define PREV_NODE 5
#define NODE_TURN 6
#define BLOCKED_FROM 7  // Available directions to explore FROM this node
#define SLOWDOWN 8 // the turf's get_heuristic_slowdown(), so it only gets worked out once per search

#define ASTAR_NODE(turf, dist_from_start, heuristic, prev_node, node_turn, blocked_from, slowdown) \
	list(turf, (dist_from_start + heuristic * (1 + PF_TIEBREAKER)), dist_from_start, heuristic, prev_node, node_turn, blocked_from, slowdown)

/// Cost of stepping between two neighboring turfs, given both their slowdowns.
#define ASTAR_STEP_COST(from, to, from_slowdown, to_slowdown) \
	(abs(from.x - to.x) + abs(from.y - to.y) + from_slowdown + to_slowdown + abs(from.z - to.z) * 5)

/// Lower bound on the cost to get within mintargetdist of the goal: every tile of distance is a step paying at least
/// ASTAR_MIN_TURF_WEIGHT on both ends. Counting the weights here is what stops A* from flooding everything in range.
#define ASTAR_HEURISTIC(from, to, mintargetdist) \
	max(0, (1 + 2 * ASTAR_MIN_TURF_WEIGHT) * (abs(from.x - to.x) + abs(from.y - to.y) - mintargetdist) + abs(from.z - to.z) * 5)

/// basically a specialized version of `BINARY_INSERT_DEFINE` for A*
#define ASTAR_OPEN_INSERT(open, node) \
	do { \
		var/__f = node[TOTAL_COST_F]; \
		var/__idx = 1; \
		if(length(open)) { \
			var/__left = 1; \
			var/__right = length(open); \
			var/__mid = (__left + __right) >> 1; \
			while(__left < __right) { \
				if(open[__mid][TOTAL_COST_F] >= __f) { \
					__left = __mid + 1; \
				} else { \
					__right = __mid; \
				}; \
				__mid = (__left + __right) >> 1; \
			}; \
			__idx = open[__mid][TOTAL_COST_F] < __f ? __mid : __mid + 1; \
		}; \
		open.Insert(__idx, null); \
		open[__idx] = node; \
	} while(FALSE)

#define ASTAR_CLOSE_ENOUGH_TO_END(end, checking_turf, mintargetdist) \
	(checking_turf == end || (mintargetdist && (get_dist_3d(checking_turf, end) <= mintargetdist)))

#define PF_TIEBREAKER 0.005
#define MASK_ODD 85
#define MASK_EVEN 170

/datum/pathfind/astar
	/// The movable we are pathing
	var/atom/movable/requester
	/// The turf we're trying to path to.
	var/turf/end
	/// The maximum number of nodes the returned path can be (0 = infinite)
	var/maxnodes
	/// The maximum number of nodes to search (default: 30, 0 = infinite)
	var/maxnodedepth
	/// Minimum distance to the target before path returns,
	/// could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
	var/mintargetdist
	/// Whether we should do multi-z pathing or not.
	var/check_z_levels
	/// Whether to smooth the path by replacing cardinal turns with diagonals
	var/smooth_diagonals = TRUE
	/// Binary sorted list of nodes (lowest weight at end for easy Pop).
	/// Can hold stale copies of a node that later found a better path; openc points at the live one.
	VAR_PRIVATE/list/open
	/// Turf -> node mapping for nodes in open list
	VAR_PRIVATE/list/openc
	/// turf -> bitmask of blocked directions
	VAR_PRIVATE/list/closed
	VAR_PRIVATE/list/path = null

/datum/pathfind/astar/Destroy(force)
	. = ..()
	requester = null
	end = null
	open = null
	openc = null
	closed = null
	path = null
	pass_info = null

/datum/pathfind/astar/proc/setup(atom/requester, atom/end, maxnodes, maxnodedepth = 30, mintargetdist, list/access = list(), turf/exclude, simulated_only = TRUE, check_z_levels = TRUE, smooth_diagonals = TRUE, list/datum/callback/on_finish)
	src.requester = requester
	src.end = get_turf(end)
	src.maxnodes = maxnodes
	src.maxnodedepth = maxnodes || maxnodedepth
	src.mintargetdist = mintargetdist
	src.avoid = exclude
	src.simulated_only = simulated_only
	src.pass_info = new(requester, access, multiz_checks = check_z_levels)
	src.check_z_levels = check_z_levels
	src.smooth_diagonals = smooth_diagonals
	src.on_finish = on_finish

/datum/pathfind/astar/start()
	start = get_turf(requester)
	. = ..()
	if(!.)
		return .
	if (!start || !end)
		. = FALSE
		CRASH("Invalid A* start or destination")
	if (start == end)
		return FALSE
	if (maxnodes && start.distance_3d(end) > maxnodes)
		return FALSE

	open = list()
	openc = new()
	closed = new()

	var/list/start_node = ASTAR_NODE(start, 0, start.distance_3d(end), null, 0, ALL_CARDINALS, start.get_heuristic_slowdown())
	ASTAR_OPEN_INSERT(open, start_node)
	openc[start] = start_node

	return TRUE

/datum/pathfind/astar/search_step()
	. = ..()
	if(!.)
		return .
	if(QDELETED(requester))
		return FALSE

	var/maxnodedepth = src.maxnodedepth
	var/mintargetdist = src.mintargetdist
	var/list/open = src.open
	var/list/openc = src.openc
	var/list/closed = src.closed
	var/turf/end = src.end
	var/turf/exclude = src.avoid
	var/datum/can_pass_info/can_pass_info = src.pass_info
	var/check_z_levels = src.check_z_levels
	var/atom/movable/our_movable

	var/list/cardinals = GLOB.cardinals

	while (requester && length(open) && !path)
		// Pop from end (highest priority in reverse sorted list)
		var/list/cur = open[length(open)]
		open.len--

		var/turf/cur_turf = cur[ATURF]
		if(openc[cur_turf] != cur) // stale copy, a better path to this turf already went in
			continue
		openc -= cur_turf
		closed[cur_turf] = ALL_CARDINALS

		// Destination check - must be exact match, or close enough on the same Z-level
		var/z_diff = abs(cur_turf.z - end.z)
		if (cur_turf == end || (mintargetdist && (!check_z_levels || !z_diff) && (abs(cur_turf.x - end.x) + abs(cur_turf.y - end.y) + z_diff * 5 <= mintargetdist)))
			path = list(cur_turf)
			var/list/prev = cur[PREV_NODE]
			while (prev)
				path.Add(prev[ATURF])
				prev = prev[PREV_NODE]
			break

		if(maxnodedepth && (cur[NODE_TURN] > maxnodedepth))
			if(TICK_CHECK)
				return TRUE
			continue

		// none of this depends on direction, so work it out once per node rather than per neighbor
		var/turf/fall_turf
		var/obj/structure/stairs/stairs
		if(isopenspaceturf(cur_turf))
			if(isnull(our_movable))
				our_movable = can_pass_info.requester_ref?.resolve() || FALSE
			if(our_movable && our_movable.can_z_move(DOWN, cur_turf, null, ZMOVE_FALL_FLAGS)) // don't use ?. as this can be false if it fails to resolve for some reason
				fall_turf = GET_TURF_BELOW(cur_turf)
		else
			stairs = locate() in cur_turf

		var/cur_slowdown = cur[SLOWDOWN]
		var/cur_g = cur[DIST_FROM_START_G]
		var/next_turn = cur[NODE_TURN] + 1

		for(var/dir_to_check in cardinals)
			if(!(cur[BLOCKED_FROM] & dir_to_check))
				continue

			var/turf/T
			if(fall_turf)
				T = fall_turf
			else if(stairs?.dir == dir_to_check && stairs.isTerminator())
				T = get_step_multiz(cur_turf, dir_to_check | UP) || get_step(cur_turf, dir_to_check)
			else
				T = get_step(cur_turf, dir_to_check)

			if(!T || T == exclude)
				continue

			var/reverse = REVERSE_DIR(dir_to_check)
			if(closed[T] & reverse)
				continue

			// can't ever walk into a dense turf, so don't bother testing its other sides later
			if(T.density)
				closed[T] = ALL_CARDINALS
				continue

			var/list/CN = openc[T]
			var/newg
			if(CN)
				newg = cur_g + ASTAR_STEP_COST(cur_turf, T, cur_slowdown, CN[SLOWDOWN])
				if(newg >= CN[DIST_FROM_START_G])
					continue

			if(!cur_turf.reachable_turf_test(requester, T, can_pass_info))
				closed[T] |= reverse
				continue

			if(CN)
				// a better path to something already open. the old copy stays in open and gets skipped when poopped,
				// which beats digging it out of the list
				var/list/better = ASTAR_NODE(T, newg, CN[HEURISTIC_H], cur, next_turn, CN[BLOCKED_FROM], CN[SLOWDOWN])
				ASTAR_OPEN_INSERT(open, better)
				openc[T] = better
				continue

			var/t_slowdown = T.get_heuristic_slowdown()
			newg = cur_g + ASTAR_STEP_COST(cur_turf, T, cur_slowdown, t_slowdown)
			CN = ASTAR_NODE(T, newg, ASTAR_HEURISTIC(T, end, mintargetdist), cur, next_turn, ALL_CARDINALS^reverse, t_slowdown)
			ASTAR_OPEN_INSERT(open, CN)
			openc[T] = CN

		if(TICK_CHECK)
			return TRUE

	return TRUE

/datum/pathfind/astar/finished()
	if(path)
		for(var/i = 1 to round(0.5 * length(path)))
			path.Swap(i, length(path) - i + 1)

		if(smooth_diagonals)
			path = smooth_path_diagonals(path)

	hand_back(path)
	openc = null
	closed = null
	return ..()

/datum/pathfind/astar/proc/smooth_path_diagonals(list/input_path)
	if(!input_path || length(input_path) < 3)
		return input_path

	var/list/smoothed = list()
	var/i = 1

	while(i <= length(input_path))
		var/turf/current = input_path[i]
		smoothed += current

		// need at least 2 more turfs to check for smoothing
		if(i + 2 > length(input_path))
			i++
			continue

		var/turf/next = input_path[i + 1]
		var/turf/after_next = input_path[i + 2]

		var/dir1 = get_dir(current, next)
		var/dir2 = get_dir(next, after_next)

		//if card and perp hen attempt to see if diagonal possible
		if(!ISDIAGONALDIR(dir1) && !ISDIAGONALDIR(dir2) && dir1 != dir2 && dir1 != REVERSE_DIR(dir2))
			var/diagonal_dir = dir1 | dir2
			var/turf/diagonal_target = get_step(current, diagonal_dir)
			if(diagonal_target == after_next)
				if(can_move_diagonal(current, after_next, pass_info))
					i += 2
					continue

		i++

	return smoothed

/datum/pathfind/astar/proc/can_move_diagonal(turf/from, turf/end, datum/can_pass_info/pass_info)
	if(!from || !end)
		return FALSE

	var/diagonal_dir = get_dir(from, end)
	if(!ISDIAGONALDIR(diagonal_dir))
		return FALSE

	var/dir1 = diagonal_dir & 3
	var/dir2 = diagonal_dir & 12

	var/turf/intermediate1 = get_step(from, dir1)
	var/turf/intermediate2 = get_step(from, dir2)

	if(intermediate1 && !intermediate1.density && from.reachable_turf_test(requester, intermediate1, pass_info))
		if(intermediate1.reachable_turf_test(requester, end, pass_info))
			return TRUE

	if(intermediate2 && !intermediate2.density && from.reachable_turf_test(requester, intermediate2, pass_info))
		if(intermediate2.reachable_turf_test(requester, end, pass_info))
			return TRUE

	return FALSE

#undef ATURF
#undef TOTAL_COST_F
#undef DIST_FROM_START_G
#undef HEURISTIC_H
#undef PREV_NODE
#undef NODE_TURN
#undef BLOCKED_FROM
#undef SLOWDOWN
#undef ASTAR_NODE
#undef ASTAR_STEP_COST
#undef ASTAR_HEURISTIC
#undef ASTAR_OPEN_INSERT
#undef ASTAR_CLOSE_ENOUGH_TO_END
#undef PF_TIEBREAKER
#undef MASK_ODD
#undef MASK_EVEN

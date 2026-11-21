/datum/ai_movement/basic_avoidance/adaptive
	/// What we swap to when walking straight gets us stuck
	var/datum/ai_movement/navmap_astar/fallback_type = /datum/ai_movement/navmap_astar

// walking straight never gets anyone up the stairs, it just parks us under them, so another floor means A* right away
/datum/ai_movement/basic_avoidance/adaptive/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance, delay_override)
	if(!on_same_floor(controller.pawn, current_movement_target))
		return swap_to_astar(controller, current_movement_target, min_distance, delay_override)
	. = ..()
	if(.)
		watch_target(current_movement_target)

/datum/ai_movement/basic_avoidance/adaptive/update_movement_target(datum/ai_controller/controller, atom/new_target)
	var/atom/old_target = moving_controllers[controller]
	. = ..()
	forget_target(old_target)
	if(!on_same_floor(controller.pawn, new_target))
		swap_to_astar(controller, new_target, controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE])
		return
	watch_target(new_target)

/datum/ai_movement/basic_avoidance/adaptive/stop_moving_towards(datum/ai_controller/controller)
	var/atom/old_target = moving_controllers[controller]
	. = ..()
	forget_target(old_target)

/datum/ai_movement/basic_avoidance/adaptive/post_move(datum/move_loop/source, succeeded)
	. = ..()
	var/datum/move_loop/has_target/dist_bound/loop = source
	var/datum/ai_controller/controller = source.extra_info
	// the target's covered by on_target_z_changed, this is for us falling down a hole or whatever
	if (!on_same_floor(loop.moving, loop.target))
		swap_to_astar(controller, loop.target, loop.distance)
		return
	if (succeeded != MOVELOOP_FAILURE)
		return
	if (get_dist(loop.moving, loop.target) <= loop.distance)
		return
	stop_moving_towards(controller)
	controller.change_ai_movement_type(fallback_type) // we failed? it's A* time

/datum/ai_movement/basic_avoidance/adaptive/proc/on_same_floor(atom/pawn, atom/target)
	var/turf/pawn_turf = get_turf(pawn)
	var/turf/target_turf = get_turf(target)
	return pawn_turf?.z == target_turf?.z

/// Hands this controller's walk over to the A* half, already headed for target.
/datum/ai_movement/basic_avoidance/adaptive/proc/swap_to_astar(datum/ai_controller/controller, atom/target, min_distance, delay_override)
	if(moving_controllers[controller])
		stop_moving_towards(controller)
	controller.change_ai_movement_type(fallback_type)
	return controller.ai_movement.start_moving_towards(controller, target, min_distance, delay_override)

// we're one datum shared by every slime, so one registration covers everyone walking at this target
/datum/ai_movement/basic_avoidance/adaptive/proc/watch_target(atom/target)
	if(ismovable(target))
		RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_target_z_changed), override = TRUE)

/datum/ai_movement/basic_avoidance/adaptive/proc/forget_target(atom/target)
	if(!ismovable(target))
		return
	for(var/datum/ai_controller/controller as anything in moving_controllers)
		if(moving_controllers[controller] == target)
			return
	UnregisterSignal(target, COMSIG_MOVABLE_Z_CHANGED)

/datum/ai_movement/basic_avoidance/adaptive/proc/on_target_z_changed(atom/movable/source)
	SIGNAL_HANDLER
	for(var/datum/ai_controller/controller as anything in moving_controllers)
		if(moving_controllers[controller] == source && !on_same_floor(controller.pawn, source))
			swap_to_astar(controller, source, controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE])

/datum/ai_movement/navmap_astar
	/// What we swap back to once we've caught up
	var/datum/ai_movement/basic_avoidance/adaptive/walk_type = /datum/ai_movement/basic_avoidance/adaptive

/datum/ai_movement/navmap_astar/post_move(datum/move_loop/source, succeeded)
	. = ..()
	if (succeeded != MOVELOOP_SUCCESS)
		return
	var/datum/move_loop/has_target/navmap_astar/loop = source
	if(length(loop.movement_path))
		return
	var/datum/ai_controller/controller = source.extra_info
	if (QDELETED(controller) || QDELETED(controller.pawn))
		return
	if (loop.target in view(6, controller.pawn))
		stop_moving_towards(controller)
		controller.change_ai_movement_type(walk_type) // we succeeded? it's basic time

/// Following a friend can mean a long trip across floors, so the A* half gets a much longer leash than a chase does
/datum/ai_movement/basic_avoidance/adaptive/follow
	fallback_type = /datum/ai_movement/navmap_astar/follow

/datum/ai_movement/navmap_astar/follow
	maximum_length = SLIME_SEEK_PATH_LENGTH
	walk_type = /datum/ai_movement/basic_avoidance/adaptive/follow

/**
 * Smart-pathing that can change z-levels, by stairs and by dropping through open space
 */
/datum/ai_movement/navmap_astar/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance, delay_override)
	. = ..()
	if(!.)
		return FALSE
	var/atom/movable/moving = controller.pawn
	var/delay = delay_override || controller.movement_delay
	var/list/found_path = controller.blackboard[BB_ASTAR_PATH_TO_USE]
	controller.clear_blackboard_key(BB_ASTAR_PATH_TO_USE)
	if(LAZYACCESS(found_path, length(found_path)) != get_turf(current_movement_target))
		found_path = null

	var/datum/move_loop/has_target/navmap_astar/loop = GLOB.move_manager.navmap_astar_move(moving,
		current_movement_target,
		delay,
		repath_delay = 0.5 SECONDS,
		max_path_length = maximum_length,
		minimum_distance = min_distance,
		access = controller.get_access(),
		initial_path = found_path,
		subsystem = SSai_movement,
		extra_info = controller,
	)

	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_JPS_REPATH, PROC_REF(repath_incoming))

	return loop

/datum/ai_movement/navmap_astar/update_movement_target(datum/ai_controller/controller, atom/new_target)
	. = ..()
	var/datum/move_loop/has_target/navmap_astar/loop = GLOB.move_manager.processing_on(controller.pawn, SSai_movement)
	if(loop)
		INVOKE_ASYNC(loop, TYPE_PROC_REF(/datum/move_loop/has_target/navmap_astar, recalculate_path))

/datum/ai_movement/navmap_astar/proc/repath_incoming(datum/move_loop/has_target/navmap_astar/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.extra_info

	source.access = controller.get_access()

/// move_to_target that only counts as arrived on the target's own floor.
/// get_dist() calls a tile one floor up 1 away, so without the z check we'd "arrive" on the top step and never climb
/datum/bt_node/ai_behavior/move_to_target/same_z

/datum/bt_node/ai_behavior/move_to_target/same_z/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	if(!(. & AI_BEHAVIOR_SUCCEEDED))
		return .
	var/turf/pawn_turf = get_turf(controller.pawn)
	var/turf/target_turf = get_turf(controller.blackboard[target_key])
	if(pawn_turf?.z == target_turf?.z)
		return .
	return AI_BEHAVIOR_INSTANT

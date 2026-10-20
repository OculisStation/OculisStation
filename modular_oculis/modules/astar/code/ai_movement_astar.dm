/**
 * Smart-pathing that can change z-levels, by stairs and by dropping through open space
 */
/datum/ai_movement/astar
	max_pathing_attempts = 20
	/// Longest path we'll search for, in steps
	var/maximum_length = AI_MAX_PATH_LENGTH

/datum/ai_movement/astar/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance, delay_override)
	. = ..()
	if(!.)
		return FALSE
	var/atom/movable/moving = controller.pawn
	var/delay = delay_override || controller.movement_delay

	var/datum/move_loop/has_target/jps/astar/loop = GLOB.move_manager.astar_move(moving,
		current_movement_target,
		delay,
		repath_delay = 0.5 SECONDS,
		max_path_length = maximum_length,
		minimum_distance = min_distance,
		access = controller.get_access(),
		subsystem = SSai_movement,
		extra_info = controller,
	)

	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_JPS_REPATH, PROC_REF(repath_incoming))

	return loop

/datum/ai_movement/astar/update_movement_target(datum/ai_controller/controller, atom/new_target)
	. = ..()
	var/datum/move_loop/has_target/jps/astar/loop = GLOB.move_manager.processing_on(controller.pawn, SSai_movement)
	if(loop)
		INVOKE_ASYNC(loop, TYPE_PROC_REF(/datum/move_loop/has_target/jps/astar, recalculate_path))

/datum/ai_movement/astar/proc/repath_incoming(datum/move_loop/has_target/jps/astar/source)
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

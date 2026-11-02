/datum/bt_node/decorator/pawn_contained_in_obj/check_condition(datum/ai_controller/controller)
	. = ..()
	var/mob/living/pawn = controller.pawn
	// nothing upstream ever clears this. pawn_buckled_to_obj shares the key, so hands off if it's theirs
	if(!. && controller.blackboard[target_key] != pawn.buckled)
		controller.clear_blackboard_key(target_key)

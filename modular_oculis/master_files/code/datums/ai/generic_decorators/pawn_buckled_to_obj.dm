/datum/bt_node/decorator/pawn_buckled_to_obj/check_condition(datum/ai_controller/controller)
	. = ..()
	var/mob/living/pawn = controller.pawn
	// pawn_contained_in_obj shares the key, so hands off if it's theirs
	if(!. && controller.blackboard[target_key] != pawn.loc)
		controller.clear_blackboard_key(target_key)

/datum/bt_node/ai_behavior/battle_screech/monkey/perform(seconds_per_tick, datum/ai_controller/controller)
	var/list/override_screeches = controller.blackboard[BB_MONKEY_BATTLE_SCREECHES]
	if(!length(override_screeches))
		return ..()
	INVOKE_ASYNC(controller.pawn, TYPE_PROC_REF(/mob, emote), pick(override_screeches))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// makes it so that slime - if a friend tries to peel the slime off someone, they immediately stop and feel bad about it.
/mob/living/basic/slime/on_attack_hand(mob/living/basic/slime/defender_slime, mob/living/attacker)
	if(!isliving(buckled) || attacker.combat_mode || !(attacker in ai_controller?.blackboard[BB_FRIENDS_LIST]))
		return ..()

	var/mob/living/spared = buckled
	attacker.visible_message(
		span_notice("[attacker] gently peels \the [name] off [spared]."),
		span_notice("You gently peel \the [name] off [spared]."),
	)
	stop_feeding(silent = TRUE)
	set_temporary_mood(SLIME_MOOD_SAD)
	manual_emote(pick(
		"blorbles apologetically at [spared].",
		"droops and stares at the floor.",
		"shrinks back from [spared], looking guilty.",
	))

	ai_controller.set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, spared, TRUE)
	ai_controller.remove_from_blackboard_lazylist_key(BB_BASIC_MOB_RETALIATE_LIST, spared)
	for(var/target_key in list(BB_SLIME_EAT_TARGET, BB_CURRENT_TARGET))
		if(ai_controller.blackboard[target_key] == spared)
			ai_controller.clear_blackboard_key(target_key)
	addtimer(CALLBACK(ai_controller, TYPE_PROC_REF(/datum/ai_controller, remove_from_blackboard_lazylist_key), BB_TEMPORARY_IGNORE_LIST, spared), 2 MINUTES)
	return COMPONENT_CANCEL_ATTACK_CHAIN // otherwise we'll like... either pet or shove the slime right after.

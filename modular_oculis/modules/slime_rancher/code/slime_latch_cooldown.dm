/// How long a slime that got forced off its meal has to wait before it can latch again
#define SLIME_LATCH_COOLDOWN (10 SECONDS)

/mob/living/basic/slime
	/// Runs after we get forced off a meal. We can't latch onto anything until it's over.
	COOLDOWN_DECLARE(latch_cooldown)

/mob/living/basic/slime/can_feed_on(mob/living/meal, silent = FALSE, check_adjacent = FALSE, check_friendship = FALSE)
	if(!COOLDOWN_FINISHED(src, latch_cooldown))
		if(!silent)
			balloon_alert(src, "still reeling!")
		return FALSE
	return ..()

/mob/living/basic/slime/discipline_slime()
	var/mob/living/victim = buckled
	if(isliving(victim))
		COOLDOWN_START(src, latch_cooldown, SLIME_LATCH_COOLDOWN)
		// a grudge skips can_feed_on(), so without this we'd just bite whoever we were eating instead of backing off
		var/datum/ai_controller/basic_controller/slime/controller = ai_controller
		if(controller)
			controller.ignore_target(victim, SLIME_LATCH_COOLDOWN)
			for(var/target_key in list(BB_SLIME_EAT_TARGET, BB_CURRENT_TARGET))
				if(controller.blackboard[target_key] == victim)
					controller.clear_blackboard_key(target_key)
	return ..()

#undef SLIME_LATCH_COOLDOWN

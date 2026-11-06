/mob/living/basic/slime
	generic_canpass = FALSE
	layer = MOB_BELOW_PIGGYBACK_LAYER
	var/list/datum/slime_mutation/mutation_progress
	/// Only goes after mobs smaller than us.
	var/cat_slime = FALSE
	/// How many damaging hits in a row a cat slime has put up with so far
	var/cat_patience_hits = 0
	var/cat_patience_last_hit = 0
	/// Cleans messes and pests instead of hunting.
	var/cleaner_slime = FALSE
	/// TRUE while our player is being asked whether someone can pick us up.
	var/pickup_prompt_open = FALSE

/mob/living/basic/slime/Initialize(mapload, new_type, new_life_stage)
	pet_commands |= /datum/pet_command/slime_split
	. = ..()
	AddElement(/datum/element/can_be_held)
	ADD_TRAIT(src, TRAIT_DOESNT_SQUASH, INNATE_TRAIT) // so we don't squash iceroaches and such. slimes are soft and squishy it makes sense.
	// TRAIT_NO_IMMOBILIZE is for slimes sitting on us - can_feed_on() refuses a slime that can't move, so they'd never leave for food
	ADD_TRAIT(src, TRAIT_NO_IMMOBILIZE, INNATE_TRAIT)
	AddElement(/datum/element/pet_bonus, "jiggle")
	AddElement(/datum/element/strippable, GLOB.strippable_slime_items)
	// on_attacked keeps the grudge list itself, bc a cat slime has to be able to say "nah" to a grudge
	RemoveElement(/datum/element/ai_retaliate)
	RegisterSignal(src, COMSIG_SLIME_LATCH_DRAINED, PROC_REF(on_ranch_drain))
	RegisterSignal(src, COMSIG_SLIME_CHECK_WANTED_ITEM, PROC_REF(on_check_wanted_pellet))
	RegisterSignal(src, COMSIG_ANIMAL_PET, PROC_REF(on_petted))
	RegisterSignal(src, COMSIG_SLIME_ATE_ITEM, PROC_REF(on_slime_happy_yay))
	RegisterSignal(src, COMSIG_LIVING_BEFRIENDED, PROC_REF(on_befriended))
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignals(src, list(COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_SLIME_ROAM_PLAYER), COMSIG_AI_BLACKBOARD_KEY_SET(BB_SLIME_ROAM_PLAYER)), PROC_REF(on_seek_changed))

/mob/living/basic/slime/Destroy()
	QDEL_LIST(mutation_progress)
	return ..()

/mob/living/basic/slime/mob_try_pickup(mob/living/user, instant = FALSE)
	if(isnull(client))
		if(!(user in ai_controller?.blackboard[BB_FRIENDS_LIST]))
			to_chat(user, span_notice("[src] doesn't trust you enough to let you pick them up"))
			balloon_alert(user, "not enough trust!")
			return FALSE
		return ..()

	if(pickup_prompt_open)
		return FALSE
	pickup_prompt_open = TRUE
	var/answer = tgui_alert(src, "[user] wants to pick you up. Let them?", "Pick up", list("Yes", "No"), timeout = 10 SECONDS)
	pickup_prompt_open = FALSE
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(answer != "Yes")
		balloon_alert(user, "doesn't want to be picked up!")
		return FALSE
	if(user.pulling != src)
		return FALSE
	return ..()

/// Not fighting, hunting, latched or getting hit, so people can walk through us.
/mob/living/basic/slime/proc/is_calm()
	if(is_latched() || combat_mode || was_recently_attacked())
		return FALSE
	return !ai_controller?.blackboard[BB_SLIME_RABID] && !ai_controller?.blackboard[BB_CURRENT_TARGET] && !ai_controller?.blackboard[BB_SLIME_EAT_TARGET]

/// Whether we and other can share a tile, which takes both sides being out of combat.
/mob/living/basic/slime/proc/can_slip_past(atom/movable/other)
	if(!isliving(other) || !is_calm())
		return FALSE
	var/mob/living/other_living = other
	if(isslime(other_living))
		var/mob/living/basic/slime/other_slime = other_living
		return other_slime.is_calm()
	return !other_living.combat_mode

/mob/living/basic/slime/CanAllowThrough(atom/movable/mover, border_dir)
	return ..() || can_slip_past(mover)

/mob/living/basic/slime/CanPassThrough(atom/blocker, movement_dir, blocker_opinion)
	return ..() || can_slip_past(blocker)

/mob/living/basic/slime/death(gibbed)
	. = ..()
	pending_ranch_mutation = null

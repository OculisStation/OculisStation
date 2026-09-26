/datum/action/innate/slime
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	transparent_when_unavailable = FALSE
	///Does the ability require a specific slime lifestage?
	var/life_stage_required
	///Does the ability requires the slime to hit max growth?
	var/needs_growth = FALSE
	///Does the ability cost nutrition?
	var/nutrition_cost = 0

/datum/action/innate/slime/create_button(mob/viewer)
	var/atom/movable/screen/movable/action_button/button = ..()
	button.maptext_x = 2
	return button

/datum/action/innate/slime/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/basic/slime/slime_owner = owner

	if(!isnull(life_stage_required) && slime_owner.life_stage != life_stage_required)
		return FALSE

	if(slime_owner.nutrition < nutrition_cost)
		return FALSE

	if(needs_growth && slime_owner.amount_grown < SLIME_EVOLUTION_THRESHOLD)
		return FALSE
	return TRUE

//Evolving

/datum/action/innate/slime/evolve
	name = "Evolve"
	button_icon_state = "slimegrow"
	desc = "This will let you evolve from baby to adult slime."
	life_stage_required = SLIME_LIFE_STAGE_BABY
	needs_growth = TRUE
	nutrition_cost = SLIME_EVOLUTION_COST

/datum/action/innate/slime/evolve/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()
	var/mob/living/basic/slime/slime_owner = owner
	if(!isnull(life_stage_required) && slime_owner.life_stage != life_stage_required)
		button.maptext = ""
		return
	button.maptext = MAPTEXT_TINY_UNICODE("[slime_owner.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]")

///Turns a baby slime into an adult slime
/datum/action/innate/slime/evolve/Activate()
	if(IS_UNCONSCIOUS_OR_CRIT(owner))
		if(owner.stat == DEAD)
			owner.balloon_alert(owner, "dead!")
		else if(IS_UNCONSCIOUS(owner))
			owner.balloon_alert(owner, "unconscious!")
		else
			owner.balloon_alert(owner, "in critical!")
		return FALSE

	var/mob/living/basic/slime/slime_owner = owner
	if(slime_owner.life_stage == SLIME_LIFE_STAGE_ADULT)
		slime_owner.balloon_alert(slime_owner, "already adult!")
		return
	if(slime_owner.amount_grown < SLIME_EVOLUTION_THRESHOLD)
		slime_owner.balloon_alert(slime_owner, "need to grow!")
		return
	if(slime_owner.nutrition < nutrition_cost)
		slime_owner.balloon_alert(slime_owner, "need food!")
		return

	slime_owner.adjust_nutrition(-nutrition_cost)

	slime_owner.set_life_stage(SLIME_LIFE_STAGE_ADULT)
	slime_owner.update_name()
	slime_owner.regenerate_icons()

	slime_owner.amount_grown = 0

//Reproduction

/datum/action/innate/slime/reproduce
	name = "Reproduce"
	button_icon_state = "slimesplit"
	desc = "This will make you split into four slimes."
	life_stage_required = SLIME_LIFE_STAGE_ADULT
	needs_growth = TRUE

/datum/action/innate/slime/reproduce/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()
	var/mob/living/basic/slime/slime_owner = owner
	if(!isnull(life_stage_required) && slime_owner.life_stage != life_stage_required)
		button.maptext = ""
		return
	button.maptext = MAPTEXT_TINY_UNICODE("[slime_owner.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]")

/datum/action/innate/slime/reproduce/Activate()
	var/mob/living/basic/slime/slime_owner = owner
	slime_owner.reproduce()

///Splits the slime into multiple children if possible
/mob/living/basic/slime/proc/reproduce(feedback = TRUE) // OCULIS EDIT CHANGE - SLIME_RANCHER - automatic retries stay quiet - ORIGINAL: /mob/living/basic/slime/proc/reproduce()

	if(IS_UNCONSCIOUS_OR_CRIT(src))
		// OCULIS EDIT ADDITION START - SLIME_RANCHER
		if(!feedback)
			return FALSE
		// OCULIS EDIT ADDITION END
		if(stat == DEAD)
			balloon_alert(src, "dead!")
		else if(IS_UNCONSCIOUS(src))
			balloon_alert(src, "unconscious!")
		else
			balloon_alert(src, "in critical!")
		return FALSE

	if(!isopenturf(loc) && feedback) // OCULIS EDIT CHANGE - SLIME_RANCHER - ORIGINAL: if(!isopenturf(loc))
		balloon_alert(src, "not here!")

	if(life_stage != SLIME_LIFE_STAGE_ADULT)
		if(feedback) // OCULIS EDIT ADDITION - SLIME_RANCHER
			balloon_alert(src, "not adult!")
		return

	if(amount_grown < SLIME_EVOLUTION_THRESHOLD)
		if(feedback) // OCULIS EDIT ADDITION - SLIME_RANCHER
			balloon_alert(src, "need growth!")
		return

	var/list/friends_list = list()
	for(var/mob/living/basic/slime/friend in loc)
		if(QDELETED(friend))
			continue
		if(friend == src)
			continue
		friends_list += friend

	overcrowded = length(friends_list) >= SLIME_OVERCROWD_AMOUNT
	if(overcrowded)
		if(feedback) // OCULIS EDIT ADDITION - SLIME_RANCHER
			balloon_alert(src, "overcrowded!")
		return

	// OCULIS EDIT ADDITION START - slime rancher rework - wind up first, split later
	if(!isopenturf(loc))
		if(feedback)
			balloon_alert(src, "not here!")
		return

	queued_mutation = get_random_mutation()
	apply_status_effect(/datum/status_effect/slime_reproducing, (queued_mutation == slime_type.type) ? SLIME_SPLIT_WINDUP : SLIME_MUTATE_WINDUP)

///Does the actual splitting or recoloring, once the wind-up has run its course
/mob/living/basic/slime/proc/finish_reproduce()
	var/mutation_target = queued_mutation
	queued_mutation = null

	if(life_stage != SLIME_LIFE_STAGE_ADULT)
		return

	if(mutation_target != slime_type.type)
		set_slime_type(mutation_target)
		set_life_stage(SLIME_LIFE_STAGE_BABY)
		set_nutrition(SLIME_STARTING_NUTRITION)
		update_name()
		regenerate_icons()
		amount_grown = 0
		mutator_used = FALSE
		return
	// OCULIS EDIT ADDITION END

	var/new_nutrition = floor(nutrition * 0.9)
	var/new_powerlevel = floor(powerlevel * 0.25)
	var/turf/drop_loc = drop_location()

	var/list/created_slimes = list(src)
	var/list/slime_friends = list()
	for(var/ally_ref in allies)
		var/mob/living/possible_friend = locate(ally_ref) in GLOB.mob_living_list
		if(QDELETED(possible_friend))
			continue
		slime_friends += possible_friend
	var/our_faction = get_faction()

	// OCULIS EDIT ADDITION
	var/split_amount = 1
	if(transformative_effect == SLIME_TYPE_GREY)
		split_amount = 2

	for(var/i in 1 to split_amount)
	// OCULIS EDIT NEW END
		var/mob/living/basic/slime/baby = new(drop_loc, slime_type.type) // OCULIS EDIT CHANGE - slime rancher, ORIGINAL: var/mob/living/basic/slime/baby = new(drop_loc, get_random_mutation())
		created_slimes += baby
		baby.add_faction(our_faction)
		for(var/slime_friend in slime_friends)
			baby.befriend(slime_friend)

		// OCULIS ADDITION START
		if(transformative_effect)
			baby.transformative_effect = transformative_effect
			baby.transform_effect()
			if(baby.spawner)
				baby.master = master
				baby.spawner.important_text = "Assist [master] at all costs."

			if(transformative_effect == SLIME_TYPE_CERULEAN)
				baby.set_life_stage(SLIME_LIFE_STAGE_ADULT)
				baby.update_name()
				baby.regenerate_icons()
				baby.set_nutrition(new_nutrition)

		baby.cores = max(cores, baby.cores) // hopefully won't cause issues
		// OCULIS ADDITION END
		SSblackbox.record_feedback("tally", "slime_babies_born", 1, baby.slime_type.colour)
		step_away(baby, src)

	set_nutrition(SLIME_STARTING_NUTRITION)
	for(var/mob/living/basic/slime/baby as anything in created_slimes)
		if(ckey) // Player slimes are more robust at spliting. Once an oversight of poor copypasta, now a feature!
			baby.set_nutrition(new_nutrition)
		baby.powerlevel = new_powerlevel
		var/atom/movable/screen/slime_power/power_hud = baby.hud_used?.screen_objects[HUD_MOB_SLIME_POWER]
		power_hud?.update_maptext()
		if(mutation_chance)
			baby.mutation_chance = clamp(mutation_chance + rand(-5, 5), 0, 100)
		else
			baby.mutation_chance = 0

//	set_life_stage(SLIME_LIFE_STAGE_BABY) // IRIS EDIT OLD -- Unique slimes
	// IRIS EDIT NEW START
	if(transformative_effect != SLIME_TYPE_CERULEAN)
		set_life_stage(SLIME_LIFE_STAGE_BABY)
		update_name()
		regenerate_icons()
	// IRIS EDIT NEW END
//	set_slime_type(get_random_mutation()) // OCULUS EDIT OLD -- Unique slimes and slime rancher
	amount_grown = 0
	mutator_used = FALSE

/mob/living/basic/slime/proc/get_random_mutation()
	if(mutation_chance >= 100)
		return /datum/slime_type/rainbow
	else if(prob(mutation_chance))
		return pick_weight(slime_type.mutations)
	else
		return slime_type.type

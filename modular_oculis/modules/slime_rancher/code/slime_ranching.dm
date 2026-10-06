/mob/living/basic/slime
	/// health actually drained while adult, banked toward the next extract/split/mutation
	var/ranch_progress = 0
	/// 0 = not primed, otherwise how much ranch_progress a split needs before it fires
	var/primed_split_cost = 0
	/// Slime type a ranch mutation already rolled, held onto until that mutation actually happens
	var/datum/slime_type/pending_ranch_mutation
	COOLDOWN_DECLARE(ranch_retry_cooldown)

/mob/living/basic/slime/proc/on_ranch_drain(datum/source, mob/living/meal, drained)
	SIGNAL_HANDLER
	set_temporary_mood(SLIME_MOOD_SMILE) // a mouthful of someone is still a mouthful, even for babies
	for(var/datum/slime_mutation/mutation as anything in mutation_progress)
		mutation.on_latch_drained(meal, drained)
	if(life_stage != SLIME_LIFE_STAGE_ADULT)
		return
	ranch_progress += drained
	try_ranch_outcome()

/// checks whether we've banked enough to split, mutate, or pop out an extract
/mob/living/basic/slime/proc/try_ranch_outcome()
	if(has_status_effect(/datum/status_effect/slime_reproducing))
		return

	if(primed_split_cost)
		if(ranch_progress < primed_split_cost || !COOLDOWN_FINISHED(src, ranch_retry_cooldown))
			return
		reproduce(feedback = FALSE)
		return

	if(pending_ranch_mutation) // Life picks it back up once we've let go of lunch
		return

	if(ranch_progress < SLIME_RANCH_EXTRACT_COST)
		return

	var/mutation_target = (transformative_effect != SLIME_TYPE_CERULEAN) ? get_unlocked_mutation_type(weight_new_types = TRUE) : null
	if(mutation_target && prob(mutation_chance))
		pending_ranch_mutation = mutation_target
		start_ranch_mutation()
		return

	ranch_progress -= SLIME_RANCH_EXTRACT_COST
	squish_out_extract()
	for(var/i in 1 to cores)
		var/obj/item/slime_extract/extract = new slime_type.core_type(drop_location())
		extract.fresh_from_slime = TRUE
		extract.pixel_x = extract.base_pixel_x + rand(-6, 6)
		extract.pixel_y = extract.base_pixel_y + rand(-6, 6)
	balloon_alert_to_viewers("produces an extract!")
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	EVLOG_TEXT(src, EVLOG_CATEGORY_SLIMES, "produced an extract via ranching ([ranch_progress] progress left over)")

/// Ranch progress from something other than a meal, like a grey slimic pylon. Never feeds a primed split.
/mob/living/basic/slime/proc/feed_passive_ranch_progress(amount)
	if(stat == DEAD || life_stage != SLIME_LIFE_STAGE_ADULT)
		return
	if(primed_split_cost || pending_ranch_mutation)
		return
	ranch_progress += amount
	try_ranch_outcome()

/// Starts the wind-up for the mutation we already rolled.
/mob/living/basic/slime/proc/start_ranch_mutation()
	queued_mutation = pending_ranch_mutation
	apply_status_effect(/datum/status_effect/slime_reproducing, SLIME_MUTATE_WINDUP)

/// Whether the stored mutation could wind up right now, ignoring whether we're still latched onto lunch.
/mob/living/basic/slime/proc/ranch_mutation_ready()
	// only ever gates stored mutations, never primed splits - a growth-blocked split that can't eat never grows, so it'd never unblock
	if(isnull(pending_ranch_mutation))
		return FALSE
	if(IS_UNCONSCIOUS_OR_CRIT(src) || HAS_TRAIT(src, TRAIT_STASIS))
		return FALSE
	if(has_status_effect(/datum/status_effect/slime_reproducing))
		return FALSE
	return COOLDOWN_FINISHED(src, ranch_retry_cooldown)

/mob/living/basic/slime/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(!.)
		return

	if(pending_ranch_mutation)
		if(ranch_mutation_ready() && !isliving(buckled))
			EVLOG_TEXT(src, EVLOG_CATEGORY_SLIMES, "resumes its stored [pending_ranch_mutation] mutation")
			start_ranch_mutation()
		return

	if(primed_split_cost && !HAS_TRAIT(src, TRAIT_STASIS))
		try_ranch_outcome()

/mob/living/basic/slime/can_feed_on(mob/living/meal, silent = FALSE, check_adjacent = FALSE, check_friendship = FALSE)
	if(ranch_mutation_ready())
		if(!silent)
			balloon_alert(src, "about to mutate!")
		return FALSE
	return ..()

/mob/living/basic/slime/proc/set_primed_split_cost(new_cost)
	primed_split_cost = new_cost
	if(new_cost)
		pending_ranch_mutation = null
	balloon_alert_to_viewers(new_cost ? "ready to split!" : "back to extracts")
	do_jitter_animation()
	refresh_wanted_targets() // so the AI starts (or stops) hunting down breeding pellets
	try_ranch_outcome() // if we already banked enough, split right away instead of waiting on the next drain

/mob/living/basic/slime/finish_reproduce()
	pending_ranch_mutation = null
	if(primed_split_cost)
		primed_split_cost = 0
		balloon_alert_to_viewers("back to extracts")
		refresh_wanted_targets()
	else if(queued_mutation != slime_type.type) // a ranch mutation, not a wild-slime split
		ranch_progress = max(ranch_progress - SLIME_RANCH_EXTRACT_COST, 0)
	// deliberately not calling set_primed_split_cost/try_ranch_outcome here - this runs inside
	// slime_reproducing/on_remove, before ..() reads queued_mutation, so starting a second windup
	// here would stomp it out from under the split/mutation that's about to actually happen
	return ..()

/mob/living/basic/slime/proc/on_check_wanted_pellet(mob/living/basic/slime/source, obj/item/meal)
	SIGNAL_HANDLER
	if(!primed_split_cost && istype(meal, /obj/item/slime_breeding_pellet))
		return COMPONENT_SLIME_WANTS_ITEM

/datum/pet_command/slime_split
	command_name = "Split"
	command_desc = "Prime (or unprime) your slime to split the next time it's fed enough."
	radial_icon_state = "breed"
	speech_commands = list("split", "breed", "multiply")

/datum/pet_command/slime_split/try_activate_command(mob/living/commander, radial_command)
	if(!pet_able_to_respond())
		return FALSE
	var/mob/living/basic/slime/parent = weak_parent.resolve()
	if(!istype(parent))
		return FALSE
	parent.set_primed_split_cost(parent.primed_split_cost ? 0 : SLIME_RANCH_COMMAND_SPLIT_COST)
	if(radial_command)
		var/manual_emote_text = generate_emote_command()
		commander.manual_emote(manual_emote_text)
	// deliberately skips set_command_active - toggling the split prime shouldn't cancel an active Follow/Stay
	return TRUE

/obj/item/slime_breeding_pellet
	name = "slime breeding pellet"
	desc = "A biomass pellet slimes go nuts for. Feed it to a slime, and it'll split the next time it's fed enough!"
	icon = 'modular_oculis/modules/slime_rancher/icons/biomass.dmi'
	icon_state = "pellet"
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON

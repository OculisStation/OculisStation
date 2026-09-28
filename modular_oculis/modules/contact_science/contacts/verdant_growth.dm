/mob/living/simple_animal/formic/verdant_growth
	name = "Verdant Growth"
	desc = "A grouping of green crystals, barely sticking out of a rocky shell. You swear you hear birds chirping inside."
	icon = 'modular_oculis/modules/contact_science/icons/verdant_growth.dmi'
	icon_state = "verdant"
	spoken_lang = /datum/language/terrum

	nanotrasen_id = "NT-ARDB-010"
	primary_hazard_labels = "Chronohazard, neurohazard"
	secondary_hazard_labels = "N/A"
	initial_line = "The songbirds sing. But, who sings for the songbirds?"
	hidden_description = "A spherical formation of basalt containing a green crystalline growth, all hovering off of the ground by ~3-5 inches. Golem translators have given varied results, but most say it speaks about songs and songbirds."

	dialogue_lines = list(
		"Will the songbirds be sung for only after their death?",
		"Who is to say the importance of a songbird if its rhythm will soon be replaced?",
		"After a thousand deaths, is the hand-me-down melody still the same?",
		"Is the soil the only memory of the song?",
		"Is a songbird more recognized for a louder song? Or, inversely, a quieter one?",
		"Who will remember you, songbird?",
		"And to think, I ever wanted to be somebody.",
		"I miss singing."
	)
	echoes = list(
		"are you singing yet",
		"what does the songbird mean"
	)

	var/accel_chance = 25
	var/accel_number = 2
	var/accel_range = 3
	var/num_trials = 5
	var/num_patterns = 5
	var/correct_pattern //var which stores the right answer
	var/listed_patterns = list()
	var/num_mistakes = 0 //number of mistakes you've made
	var/mistake_threshold = 3 //number of mistakes you can make before severe punishment
	var/brain_damage = 5 //amount of brain damage dealt on failing before the severe punishment
	var/trials_active = FALSE //whether or not the trial is happening
	var/list/pattern_prefixes = list(
		"diseased",
		"tragic",
		"radiant",
		"singing",
		"devouring",
		"merry",
		"enraged",
		"dead",
		"living"
	)
	var/list/pattern_suffixes = list(
		"corpse",
		"rabbit",
		"scarecrow",
		"weapon",
		"clock",
		"spiral",
		"heart",
		"chain",
		"face"
	)

	//stuff for the ghostrole
	var/notify_cooldown
	var/ask_delay = 120 SECONDS
	VAR_FINAL/mob/living/brain/brainmob = null //occupant

/mob/living/simple_animal/formic/verdant_growth/Initialize()
	. = ..()
	brainmob = new /mob/living/brain(src)
	request_ghost()

/mob/living/simple_animal/formic/verdant_growth/resonate_info()
	var/list/message = list()
	message += "Number of sins: [num_mistakes]"
	message += "Sin threshold: [mistake_threshold]"
	return message

/mob/living/simple_animal/formic/verdant_growth/proc/request_ghost()
	if(notify_cooldown <= world.time)
		notify_ghosts(
			"Verdant Growth appears in [get_area(src)]! Requesting a ghost to draw glyphs...",
			source = src,
			header = "Songbird",
			click_interact = TRUE,
			ghost_sound = 'sound/effects/ghost2.ogg',
			notify_flags = (GHOST_NOTIFY_IGNORE_MAPLOAD),
			notify_volume = 75,
		)
		notify_cooldown = world.time + ask_delay
		addtimer(CALLBACK(src, PROC_REF(check_success)), ask_delay)

/mob/living/simple_animal/formic/verdant_growth/proc/check_success()
	if(QDELETED(brainmob))
		return
	if(brainmob.client)
		visible_message("You feel a ringing frequency of anticipation emanating from [name] as it accepts a host!")
		trial_start()
	else
		visible_message("You feel a ringing frequency of disappointment emanating from [name] as it tries again to find a host...")

/mob/living/simple_animal/formic/verdant_growth/proc/is_occupied()
	if(brainmob.key)
		return TRUE
	return FALSE

/mob/living/simple_animal/formic/verdant_growth/attack_ghost(mob/user)
	activate(user)

/mob/living/simple_animal/formic/verdant_growth/proc/activate(mob/user)
	if(QDELETED(brainmob))
		return
	if(is_occupied() || QDELETED(src) || QDELETED(user))
		return
	var/posi_ask = tgui_alert(user, "Become a songbird? (This will DNR you. You will briefly play as a glyphing spirit before dissipating after the trial is finished.)", "Confirm", list("Yes","No"))
	if(posi_ask != "Yes" || QDELETED(src))
		return
	if(HAS_TRAIT(brainmob, TRAIT_SUICIDED)) //clear suicide status if the old occupant suicided.
		brainmob.set_suicide(FALSE)
	transfer_personality(user)

/mob/living/simple_animal/formic/verdant_growth/proc/transfer_personality(mob/candidate)
	if(QDELETED(brainmob))
		return
	if(is_occupied()) //Prevents hostile takeover if two ghosts get the prompt or link for the same brain.
		to_chat(candidate, span_warning("A songbird is already active within the [name]. Perhaps another time..."))
		return FALSE
	brainmob.PossessByPlayer(candidate.ckey)
	brainmob.grant_actions_by_list(list(/datum/action/cooldown/spell/pointed/songwriting))
	brainmob.grant_language(/datum/language/common, source = LANGUAGE_ATOM)
	brainmob.grant_language(/datum/language/terrum, source = LANGUAGE_ATOM)
	brainmob.set_stat(STABLE)
	brainmob.name = "[pick(pattern_prefixes)] songbird"
	to_chat(brainmob, span_notice("<font size='5'>You are a songbird. When you recieve a prompt in the chat, try to draw it with your songwriting ability (top-left).</font>"))
	check_success()
	return TRUE

/mob/living/simple_animal/formic/verdant_growth/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(!trials_active)
		request_ghost()
	if(prob(accel_chance)) //chronohazard, sometimes procs extra life ticks for nearby living mobs
		for(var/i in 1 to accel_number)
			for(var/mob/living/M in range(accel_range, src))
				M.Life(seconds_per_tick)

/mob/living/simple_animal/formic/verdant_growth/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "are you singing yet") //waiting dialogue
		if(last_response == "are you singing yet")
			langsay("The two-minute hand must tick.")
			return
		last_response = "are you singing yet"
		langsay("No. Let the songbirds come with patience...")
	if(successful_echo == "what does the songbird mean") //waiting dialogue
		if(last_response == "what does the songbird mean")
			langsay("The heart with a finite beating.")
			return
		last_response = "what does the songbird mean"
		langsay("Everything that will be nothing.")
	if(trials_active) //following response system only active once a ghost is incorporated
		if(successful_echo == correct_pattern) //advance
			advance_trial()
		else //fail
			fail_trial()

/mob/living/simple_animal/formic/verdant_growth/proc/trial_start()
	if(trials_active)
		return
	trials_active = TRUE
	new_symbols()
	langsay("Let us begin.")
	balloon_alert(last_speaker, "new echoes detected!")
	playsound(src, 'sound/effects/ghost2.ogg', 50, TRUE, -2, TRUE, FALSE)

/mob/living/simple_animal/formic/verdant_growth/proc/advance_trial()
	num_trials -= 1
	if(num_trials == 0)
		to_chat(brainmob, span_notice("[last_speaker] provided the correct answer. Your role is complete. Ejecting..."))
		langsay("Correct. Perhaps a songbird's melody carries long after its death... Thank you.")
		addtimer(CALLBACK(src, PROC_REF(reward)), 20)
	else
		to_chat(brainmob, span_notice("[last_speaker] provided the correct answer. Advancing..."))
		langsay("Correct. Next...")
		new_symbols()

/mob/living/simple_animal/formic/verdant_growth/proc/fail_trial()
	to_chat(brainmob, span_warning("[last_speaker] provided the wrong answer. Their clock ticks down."))
	langsay("Wrong.")
	num_mistakes += 1
	if(num_mistakes >= mistake_threshold)
		last_speaker.adjust_organ_loss(ORGAN_SLOT_BRAIN, brain_damage * 5, 80)
		to_chat(last_speaker, span_warning("Your brain feels like it's compressing under the weight of song..."))
	else
		last_speaker.adjust_organ_loss(ORGAN_SLOT_BRAIN, brain_damage, 80)
		to_chat(last_speaker, span_warning("You feel the pain of a tiny needle in your mind... or maybe, it's a songbird's beak?"))

/mob/living/simple_animal/formic/verdant_growth/proc/new_symbols()
	listed_patterns = list() //reset the list
	for(var/i in 1 to num_patterns)
		listed_patterns += "[pick(pattern_prefixes)] [pick(pattern_suffixes)]"
	echoes = listed_patterns
	correct_pattern = pick(listed_patterns)
	addtimer(CALLBACK(src, PROC_REF(symbol_telegraph)), 6)

/mob/living/simple_animal/formic/verdant_growth/proc/symbol_telegraph()
	to_chat(brainmob, span_notice("<font size='5'>You must next draw a depiction of a [correct_pattern].</font>"))

/mob/living/simple_animal/formic/verdant_growth/proc/reward()
	if(num_mistakes == 0) //more potent reward for a flawless run
		new /obj/item/verdant_offspring/perfect(get_turf(src))
		playsound(src, 'sound/effects/portal/portal_travel.ogg', 40)
		qdel(src)
	else //otherwise, standard reward
		new /obj/item/verdant_offspring(get_turf(src))
		playsound(src, 'sound/effects/portal/portal_travel.ogg', 40)
		qdel(src)

/obj/item/verdant_offspring
	name = "verdant offspring"
	desc = "A cluster of odd, hue-shifting crystals. It creates bursts of unstable time to various effects on nearby machines and lifeforms. Some say it can satiate the gazing beast..."
	icon = 'modular_oculis/modules/contact_science/icons/verdant_growth.dmi'
	icon_state = "offspring"
	custom_materials = list(/datum/material/plasma=SMALL_MATERIAL_AMOUNT)
	throwforce = 0
	throw_speed = 3
	throw_range = 7

	var/accel_chance = 10
	var/accel_number = 1
	var/accel_range = 2

/obj/item/verdant_offspring/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/item/verdant_offspring/process(seconds_per_tick) //the following is a ridiculous ass multifaceted effect to simulate unstable bursts of time
	if(prob(accel_chance))
		playsound(src, 'sound/effects/ghost2.ogg', 15, TRUE, -2, TRUE, FALSE)
		for(var/i in 1 to accel_number)
			for(var/obj/machinery/M in range(accel_range, src))
				M.process(seconds_per_tick)
			for(var/mob/living/G in range(accel_range, src))
				G.Life(seconds_per_tick)
				for(var/datum/disease/D in G.diseases) //increase the rate at which diseases apply
					if(D.stage < D.max_stages)
						D.stage += 1
				G.adjust_blood_volume(5 * seconds_per_tick, maximum = BLOOD_VOLUME_NORMAL) //increase the rate at which blood regenerates. a treasure for the hemophage
				for(var/datum/status_effect/status_to_tick in G) //tick statuses
					status_to_tick.tick_interval = 0
			for(var/mob/living/simple_animal/formic/panopticon_beast/panbeast in range(accel_range, src)) //special pan beast satiation effect
				panbeast.feeding_timer_current += 5

/obj/item/verdant_offspring/perfect
	name = "perfect offspring"
	desc = "A massive sphere of odd, hue-shifting crystals. It creates strong bursts of unstable time to various effects on nearby machines and lifeforms. A reward for an unfaltering understanding of a songbird, some say it can satiate the gazing beast..."
	icon_state = "potent_offspring"
	custom_materials = list(/datum/material/plasma=SMALL_MATERIAL_AMOUNT * 2)
	throwforce = 2
	accel_number = 2

/datum/action/cooldown/spell/pointed/songwriting //kinda copying the revenant ghostwriting because it has restrictions and properties i dont want. there might be a better method but i'm an amateur
	name = "Songwriting"
	desc = "Write messages on the ground. Try to depict the prompt given."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "arcane_barrage"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	spell_requirements = NONE
	cooldown_time = 0.2 SECONDS
	check_flags = SPELL_CASTABLE_AS_BRAIN

	active_msg = "You start inscribing your song."
	deactive_msg = "You stop singing."
	aim_assist = FALSE
	unset_after_click = FALSE
	var/obj/item/toy/crayon/revenant/ghost_crayon
	var/list/click_params

/datum/action/cooldown/spell/pointed/songwriting/Destroy(force)
	QDEL_NULL(ghost_crayon)
	return ..()

/datum/action/cooldown/spell/pointed/songwriting/on_activation(mob/on_who)
	. = ..()
	if(!ghost_crayon)
		ghost_crayon = new()
		ghost_crayon.paint_color = LIGHT_COLOR_VIVID_GREEN
		ghost_crayon.drawtype = "."

	ghost_crayon.forceMove(on_who)

/datum/action/cooldown/spell/pointed/songwriting/on_deactivation(mob/on_who, refund_cooldown)
	. = ..()
	if(ghost_crayon)
		QDEL_NULL(ghost_crayon)

/datum/action/cooldown/spell/pointed/songwriting/is_valid_target(atom/cast_on)
	return isturf(cast_on)

/datum/action/cooldown/spell/pointed/songwriting/cast(atom/cast_on)
	. = ..()
	if(ghost_crayon)
		if(!IsAvailable())
			return FALSE

		if(!ghost_crayon.can_use_on(cast_on, owner))
			return FALSE
		StartCooldown()
		ghost_crayon.use_on(cast_on, owner, click_params)
		ghost_crayon.drawtype = "."
		return TRUE
	return FALSE

/datum/action/cooldown/spell/pointed/songwriting/can_cast_spell(feedback = TRUE) //custom spell condition script because i cannot figure out how to make it allow the cast
	if(!owner)
		CRASH("[type] - can_cast_spell called on a spell without an owner!")
	if(SEND_SIGNAL(src, COMSIG_SPELL_CAN_CAST_CHECK, feedback) & SPELL_CANCEL_CAST)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/songwriting/InterceptClickOn(mob/living/clicker, params, atom/target)
	src.click_params = params2list(params)
	return ..()

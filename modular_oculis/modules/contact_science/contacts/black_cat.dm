/mob/living/simple_animal/formic/black_cat
	name = "Black Cat"
	desc = "A small black cat. Light disappears around it."
	icon = 'modular_oculis/modules/contact_science/icons/black_cat.dmi'
	icon_state = "cat"

	nanotrasen_id = "NT-ARDB-003"
	primary_hazard_labels = "Causal-hazard, neurohazard"
	secondary_hazard_labels = "Light alteration"
	initial_line = "Can... can I be loved?"
	hidden_description = "A plain black cat with an inherent anti-photon field, creating an area of darkness nearby. It seems to have a desire to be loved, but fights the notion that it can be."
	dialogue_lines = list(
		"No... it's impossible to love something like me.",
		"Just don't even try. Give up on me...",
		"I just want to be loved...",
		"Please? For an unlovable creature like me?",
		"Why even bother...",
		"You secretly hate me, don't you...?"
	)
	echoes = list(
		"you can be loved"
	)
	talksound = 'sound/mobs/non-humanoids/cat/cat_purr1.ogg'

	var/dark_light_range = 2
	var/dark_light_power = -6
	var/current_sequence = 0
	var/sequence1_answer
	var/sequence2_answer
	var/sequence3_answer

	//the player must praise the cat thrice among lists of three, each correct answer being randomized when initializing. even through its disbelief, you must maintain your belief in it
	var/sequence1 = list(
		"i love you for your soft fur",
		"i love you for your shining eyes",
		"i love you for your long whiskers"
	)
	var/sequence1_failures = list(
		"What? No... that's ugly. I'm ugly.",
		"That's... no. No. You're wrong.",
		"You're wrong. That's stupid."
	)

	var/sequence2 = list(
		"i love you for your kindness",
		"i love you for your perseverance",
		"i love you for your curiosity"
	)
	var/sequence2_failures = list(
		"What? That's not... that's not right. I'm not like that.",
		"That's... do you really think that of me? No... it doesn't make sense.",
		"You're wrong. That's stupid. You're... no."
	)

	var/sequence3 = list(
		"because you are gentle",
		"because you are good-hearted",
		"because you are patient"
	)
	var/sequence3_failures = list(
		"What... me? No... I'm not... I'm not like that.",
		"Do you really... think that? No... it doesn't make any sense.",
		"No... no. No. It can't be."
	)

/mob/living/simple_animal/formic/black_cat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/overlay_lighting, dark_light_range, dark_light_power, force = TRUE)
	set_light(dark_light_range, dark_light_power)
	sequence1_answer = rand(1, 3)
	sequence2_answer = rand(1, 3)
	sequence3_answer = rand(1, 3)

/mob/living/simple_animal/formic/black_cat/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "you can be loved")
		last_response = "you can be loved"
		balloon_alert(last_speaker, "new echoes detected!")
		echoes = sequence1
		current_sequence = 1
		say("No... what can be loved about me?")
		return
	if(successful_echo == "you are worth loving")
		last_response = "you are worth loving"
		langsay("Thank you.")
		new /obj/item/clothing/neck/cloak/black_cat_coat(get_turf(src))
		visible_message(span_warning("The black cat disappears, leaving behind a cloak..."))
		playsound(src, 'sound/effects/magic/staff_healing.ogg', 50)
		qdel(src)
		return
	if(current_sequence == 3)
		if(successful_echo == sequence3[sequence3_answer])
			last_response = sequence3_answer
			balloon_alert(last_speaker, "new echoes detected!")
			langsay("Then... then tell me. Tell me I am worth loving.")
			current_sequence = 4
			echoes = list(
				"you are worth loving"
			)
			return
		else
			last_response = successful_echo
			langsay(pick(sequence3_failures))
			curse(last_speaker)
			last_speaker.adjust_organ_loss(ORGAN_SLOT_BRAIN, 15, 100)
			return
	if(current_sequence == 2)
		if(successful_echo == sequence2[sequence2_answer])
			last_response = sequence2_answer
			balloon_alert(last_speaker, "new echoes detected!")
			langsay("You're... no. Stop. Why... why are you doing this?")
			current_sequence = 3
			echoes = sequence3
			return
		else
			last_response = successful_echo
			langsay(pick(sequence3_failures))
			curse(last_speaker)
			last_speaker.adjust_organ_loss(ORGAN_SLOT_BRAIN, 10, 100)
			return
	if(current_sequence == 1)
		if(successful_echo == sequence1[sequence1_answer])
			last_response = sequence1_answer
			balloon_alert(last_speaker, "new echoes detected!")
			langsay("I guess... but that's... no. What is there to really love about me?")
			current_sequence = 2
			echoes = sequence2
			return
		else
			last_response = successful_echo
			langsay(pick(sequence1_failures))
			curse(last_speaker)
			last_speaker.adjust_organ_loss(ORGAN_SLOT_BRAIN, 5, 100)
			return

/mob/living/simple_animal/formic/black_cat/proc/curse(mob/living/carbon/human/to_curse)
	if(!to_curse.GetComponent(/datum/component/omen))
		to_curse.AddComponent( \
		/datum/component/omen, \
		incidents_left = 4, \
		luck_mod = 0.3, \
		damage_mod = 0.25, \
		bless_fixable = TRUE, \
		)
		to_chat(to_curse, span_warning("The tendrils of causality constrict you..."))
//cloak of the black cat

/obj/item/clothing/neck/cloak/black_cat_coat
	name = "cloak of the black cat"
	desc = "A symbol of belief in the black cat. It suppresses anomalous causality (known to the layman as bad luck or curses) within its wearer."
	icon_state = "catcloak"
	icon = 'modular_oculis/modules/contact_science/icons/black_cat.dmi'
	worn_icon = 'modular_oculis/modules/contact_science/icons/cat_cloak_worn.dmi'
	inhand_icon_state = "catcloak"
	lefthand_file = 'modular_oculis/modules/contact_science/icons/cat_cloak_lhand.dmi'
	righthand_file = 'modular_oculis/modules/contact_science/icons/cat_cloak_rhand.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	resistance_flags = FIRE_PROOF | FREEZE_PROOF
	clothing_traits = list(
		TRAIT_CURSED_SUPPRESS
	)

/mob/living/simple_animal/formic/rabbit_hole
	name = "Hole-In-The-Rabbit"
	desc = "Ichor drips from the hole in this giant rabbit's head."
	icon = 'modular_oculis/modules/contact_science/icons/rabbit_hole.dmi'
	icon_state = "hole"
	initial_size = 2

	nanotrasen_id = "NT-ARDB-009"
	primary_hazard_labels = "Neurohazard"
	secondary_hazard_labels = "N/A"
	initial_line = "You. Like you, once..."
	hidden_description = "A rabbit about twice the size of the regular species. Despite the hole in its head dripping with an unidentifiable black liquid, it seems to be interested in helping. It may have some knowledge about the Anomalous Resonance Forms."
	dialogue_lines = list(
		"Us. We help eachother. Even if I am long gone.",
		"You. Understand me? I am lost.",
		"Memory. A cold thing...",
		"Help.",
		"Scientists. Us both, work together.",
		"Cat. Have you seen her? She is lost..." //connected with the black cat
	)
	echoes = list(
		"who are you",
		"can you help me"
	)

	var/list/associated_dialogue = list(
		/mob/living/simple_animal/formic/rabbit_hole = "Me. You're talking to it. I can help you if you show me another resonance form on that scanner.",
		/mob/living/simple_animal/formic/ozymandian_wreckage = "War. What did it say? Do not let it 'lend you its strength.' 'Proper salvage' is okay. Repair can yield the suit either way.",
		/mob/living/simple_animal/formic/panopticon_beast = "Surveillance. Do not let it starve. It sees through anything, as do its projectiles. Shut it off if you suspect a breach, do not wait until it is too late.",
		/mob/living/simple_animal/formic/divine_congealment = "Slime. It holds something special... Radia, or disease. Slime of a new variety. Plasma or uranium create Radia.",
		/mob/living/simple_animal/formic/olivers_scarecrow = "Maze. Something hidden... bring meson equipment. Old project of an old friend. Bring weapons as well. The dolls will kill you otherwise.",
		/mob/living/simple_animal/formic/forgotten_forge = "Brass. The clockwork is gone, but its ghost remains. Do not be greedy unless you are ready to fight. Implantation may rip others out to take their place.",
		/mob/living/simple_animal/formic/black_cat = "What? She is... here too? Could you retrieve her cloak? I have not seen her in a long time..." //connected with the black cat
	)
	var/help_damage_min = 5
	var/help_damage_max = 10
	var/cat_quest_started = FALSE

/mob/living/simple_animal/formic/rabbit_hole/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "who are you") //starting dialogue
		last_response = "who are you"
		langsay("Scientist. Like you. We are down the rabbit hole together. Analyze others. Show them to me.")
		echoes -= "who are you"
		echoes -= "can you help me"
		echoes += "take a look"
		balloon_alert(last_speaker, "new echoes detected!")
	if(successful_echo == "can you help me") //starting dialogue
		last_response = "can you help me"
		langsay("Yes. Analyze another with your device, show it to me. I will try.")
		echoes -= "who are you"
		echoes -= "can you help me"
		echoes += "take a look"
		balloon_alert(last_speaker, "new echoes detected!")
	if(successful_echo == "take a look") //analysis dialogue
		last_response = "take a look"
		look()
	if(successful_echo == "i have the cloak") //cat quest
		last_response = "i have the cloak"
		if(get_dist(src, last_speaker) > 1)
			langsay("Closer. Please.")
		else
			cloak_quest()

/mob/living/simple_animal/formic/rabbit_hole/proc/look()
	var/obj/item/to_check = last_speaker.get_active_held_item()
	if(!to_check)
		langsay("Analyzer. Formic. Let me see it.")
		return
	if(istype(to_check, /obj/item/contactanalyzer))
		var/obj/item/contactanalyzer/analyzer = to_check
		langsay(associated_dialogue[(analyzer.last_scanned).type])
		if(!istype(analyzer.last_scanned, /mob/living/simple_animal/formic/rabbit_hole) && !istype(analyzer.last_scanned, /mob/living/simple_animal/formic/black_cat)) //do not deal brain damage for self or special interaction
			last_speaker.adjust_organ_loss(ORGAN_SLOT_BRAIN, rand(help_damage_min, help_damage_max), 80)
			to_chat(last_speaker, span_warning("Something rings in the back of your mind... like a tiny hole, burning."))
		if(istype(analyzer.last_scanned, /mob/living/simple_animal/formic/black_cat) && !cat_quest_started)
			cat_quest_started = TRUE
			echoes += "i have the cloak"
			balloon_alert(last_speaker, "new echoes detected!")
			associated_dialogue[/mob/living/simple_animal/formic/black_cat] = "Cat. She is a memory of the Storm now, like me. Old friend... I miss her."
	else
		langsay("Analyzer. Formic. Let me see it.")

/mob/living/simple_animal/formic/rabbit_hole/proc/cloak_quest()
	var/obj/item/to_check = last_speaker.get_active_held_item()
	if(!to_check)
		langsay("Where?")
		return
	if(istype(to_check, /obj/item/clothing/neck/cloak/black_cat_coat))
		langsay("Thanks. It is good to see a trace of her again...")
		last_speaker.adjust_organ_loss(ORGAN_SLOT_BRAIN, rand(help_damage_min, help_damage_max) * -10, 80)
		to_chat(last_speaker, span_warning("Your mind is filled with clarity."))
		echoes -= "i have the cloak"
		playsound(last_speaker, 'sound/effects/portal/portal_travel.ogg', 40)
		qdel(to_check)
	else
		langsay("Where?")

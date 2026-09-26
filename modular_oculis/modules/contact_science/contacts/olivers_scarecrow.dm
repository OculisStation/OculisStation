/mob/living/simple_animal/formic/olivers_scarecrow
	name = "Oliver's Scarecrow"
	desc = "You swear you can see tears dripping from the sockets of this scarecrow's skull."
	icon = 'modular_oculis/modules/contact_science/icons/olivers_scarecrow.dmi'
	icon_state = "oliver"

	nanotrasen_id = "NT-ARDB-006"
	primary_hazard_labels = "N/A"
	secondary_hazard_labels = "Dimensional manifestation"
	initial_line = "Our failure... I implore you... not to enter."
	hidden_description = "A scarecrow comprised of a straw-like material, its head replaced with a skull. Forensic scans have not been able to identify its origin. It seems to guard an infinite pocket dimension - we think it could be connected to the elusive 'Hilbert's Hotel' artifact."
	dialogue_lines = list(
		"Dangerous... hateful... they hunt.",
		"My... work... what a failure.",
		"They killed... all of us.",
		"Trapped then... trapped now... a nightmare...",
		"Do... not... enter.",
		"The fields... the infinite fields...",
		"Room after room... yet no cohesion...",
		"Artificial space... terrible things..."
	)
	echoes = list(
		"what are you"
	)

	var/artifact_given = FALSE //it can only give one Oliver's Labyrinth

	//following info is passed down to the artifact. loaded via scarecrow to give more generation time
	var/datum/map_template/oliverslabyrinth/theLab //map template
	var/datum/space_level/labLevel //level

/mob/living/simple_animal/formic/olivers_scarecrow/Initialize(mapload)
	. = ..()
	//Load template
	INVOKE_ASYNC(src, PROC_REF(prepare_room))

/mob/living/simple_animal/formic/olivers_scarecrow/proc/prepare_room()
	theLab = new()
	labLevel = theLab.load_new_z(FALSE)

/mob/living/simple_animal/formic/olivers_scarecrow/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "what are you") //starting dialogue
		last_response = "what are you"
		langsay("Something terrible... a creator... an infinite space...")
		echoes -= "what are you"
		echoes += "where is the space"
		balloon_alert(last_speaker, "new echoes detected!")
	if(successful_echo == "where is the space") //next dialogue, tree opens up after
		last_response = "where is the space"
		langsay("Within me... I can offer entry... but be warned... you might not come back.")
		echoes -= "where is the space"
		echoes += "let me enter"
		echoes += "what are the dangers"
		echoes += "how can i leave"
		echoes += "what is there"
		balloon_alert(last_speaker, "new echoes detected!")
	if(successful_echo == "what are the dangers") //warning about the mannequins
		if(last_response == "what are the dangers")
			langsay("Why must I... repeat myself..?")
			return
		last_response = "what are the dangers"
		langsay("The dolls... they attacked all at once... they walk... and hate...")
	if(successful_echo == "what is there") //warning about the environment
		if(last_response == "what is there")
			langsay("Why must I... repeat myself..?")
			return
		last_response = "what is there"
		langsay("An infinite field... an infinite structure... makes no sense... two infinites..?")
	if(successful_echo == "how can i leave") //a tip on how to leave
		if(last_response == "how can i leave")
			langsay("Why must I... repeat myself..?")
			return
		last_response = "how can i leave"
		langsay("Navigate the maze... cross the bridge... it's in the building.")
	if(successful_echo == "let me enter") //hand over the artifact
		last_response = "let me enter"
		if(!artifact_given)
			langsay("You are making... a grave mistake... look down...")
			var/obj/item/oliverslabyrinth/generated_lab = new /obj/item/oliverslabyrinth(get_turf(last_speaker))
			generated_lab.origin = src
			artifact_given = TRUE
		else
			langsay("I have already... done what I can... good luck...")

/obj/item/oliverslabyrinth //hilberts hotel but EVIL
	name = "Oliver's Labyrinth"
	desc = "A sphere of what appears to be an intricate network of redspace. It feels like its size dilates further and further the longer you peer into it."
	icon = 'modular_oculis/modules/contact_science/icons/olivers_scarecrow.dmi'
	icon_state = "oliverslab"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/space_level/labLevel //level
	var/mob/living/simple_animal/formic/olivers_scarecrow/origin //the scarecrow
	var/has_generated_exit = FALSE //have we generated the exit yet?
	var/list/potential_codes = list( //potential codes for the secret item
		"MARY",
		"HALIVER",
		"OLIVER",
		"ROMEO"
	)
	var/correct_code

/obj/item/oliverslabyrinth/Initialize(mapload)
	. = ..()
	correct_code = pick(potential_codes)
	//rot13 codes
	potential_codes["MARY"] = "ZNEL"
	potential_codes["HALIVER"] = "UNYVIRE"
	potential_codes["OLIVER"] = "BYVIRE"
	potential_codes["ROMEO"] = "EBZRB"

/obj/item/oliverslabyrinth/attack_self(mob/user)
	. = ..()
	if(origin.labLevel)
		labLevel = origin.labLevel
	else
		balloon_alert(user, "generation in progress!")
		return
	balloon_alert(user, "entering the labyrinth...")
	if(do_after(user, 2 SECONDS, src))
		enter_lab(user)

/obj/item/oliverslabyrinth/proc/enter_lab(mob/user)
	user.dropItemToGround(src)
	do_sparks(3, FALSE, get_turf(user))
	user.forceMove(locate(
	66,
	66,
	labLevel.z_value,
	))
	do_sparks(3, FALSE, get_turf(user))
	if(!has_generated_exit) //generates initial stuff with dynamic values that cant be generated in map
		var/obj/item/oliversreprieve/generated_exit = new /obj/item/oliversreprieve(locate(
		145,
		189,
		labLevel.z_value,
		))
		generated_exit.generated_lab = src
		var/obj/item/paper/crumpled/bloody/decipher_key_paper = new /obj/item/paper/crumpled/bloody(locate(
		165,
		190,
		labLevel.z_value,
		))
		decipher_key_paper.add_raw_text(correct_code)
		var/obj/item/mod/module/dispenser/mirage/dreamcoil/dream_module = new /obj/item/mod/module/dispenser/mirage/dreamcoil(locate(
		71,
		185,
		labLevel.z_value,
		))
		dream_module.code = potential_codes[correct_code]
		has_generated_exit = TRUE

/datum/map_template/oliverslabyrinth
	name = "Oliver's Labyrinth"
	mappath = "modular_oculis/modules/contact_science/maps/labyrinth.dmm"
	var/landingZoneRelativeX = 4
	var/landingZoneRelativeY = 4

/obj/item/oliversreprieve //the exit item
	name = "Oliver's Reprieve"
	desc = "Do you want to leave yet?"
	icon = 'modular_oculis/modules/contact_science/icons/olivers_scarecrow.dmi'
	icon_state = "oliverslab"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/simple_animal/formic/olivers_scarecrow/origin //the scarecrow
	var/obj/item/oliverslabyrinth/generated_lab //the item to go back to

/obj/item/oliversreprieve/attack_self(mob/user)
	. = ..()
	balloon_alert(user, "exiting the nightmare...")
	if(do_after(user, 2 SECONDS, src))
		exit_lab(user)

/obj/item/oliversreprieve/proc/exit_lab(mob/user)
	user.dropItemToGround(src)
	do_sparks(3, FALSE, get_turf(user))
	do_teleport(user, get_turf(generated_lab), 0, channel = TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)
	do_sparks(3, FALSE, get_turf(user))

/obj/item/mod/module/dispenser/mirage/dreamcoil //special chaotic grenade dispenser. must be unlocked via code secret
	name = "\improper malfunctioning MOD dreamcoil module"
	desc = "Redundant complexities prevent this module from being inserted until a code is entered. Dispenses 'dreamcoil' grenades. Dreams are chaotic - or was it a nightmare he had?"
	icon = 'modular_oculis/modules/contact_science/icons/olivers_scarecrow.dmi'
	icon_state = "dreamcoil"
	complexity = 42
	cooldown_time = 30 SECONDS //longer cooldown due to unstable effects
	dispense_type = /obj/item/grenade/dreamcoil
	var/true_complexity = 3 //post-decoding complexity
	var/decoded = FALSE
	var/code = "EXAMPLE"

/obj/item/mod/module/dispenser/mirage/dreamcoil/attack_self(mob/user, modifiers)
	. = ..()
	if(!decoded)
		var/entered_code = input(user, "Enter a code.", "Code")
		if(entered_code == code)
			complexity = true_complexity
			balloon_alert(user, "module unlocked!")
			decoded = TRUE
		else //electrical injection punishment for incorrect code
			if(entered_code) //prevent punishment for empty code box
				balloon_alert(user, "code incorrect!")
				user.reagents?.add_reagent(/datum/reagent/teslium,10)
				playsound(user, 'modular_nova/modules/hyposprays/sound/hypospray.ogg', 40, TRUE, -2, TRUE, FALSE)
				to_chat(user, span_warning("You feel an injection perforate your hand!"))
				user.dropItemToGround(src)

/obj/item/mod/module/dispenser/mirage/dreamcoil/on_use(mob/activator)
	var/obj/item/grenade/dreamcoil/grenade = ..()
	grenade.arm_grenade(mod.wearer)

/obj/item/grenade/dreamcoil //the grenade
	name = "dreamcoil grenade"
	desc = "In the end, his dream failed, for reasons he would never live to understand."
	icon = 'modular_oculis/modules/contact_science/icons/olivers_scarecrow.dmi'
	icon_state = "dreamcoil_grenade"
	det_time = 6 SECONDS //longer det time due to unstable effects
	shrapnel_radius = 1
	var/list/potential_projectiles = list( //assorted bullshit, mostly magic but with some extra fun little thangs. what does the dreamcoil dream of this time?
		/obj/projectile/bullet/c980grenade/smoke,
		/obj/projectile/magic/door,
		/obj/projectile/magic/shrink/superweak,
		/obj/projectile/magic/pizza,
		/obj/projectile/kiss,
		/obj/projectile/beam/emitter/hitscan/bioregen,
		/obj/projectile/magic/teleport
	)

/obj/item/grenade/dreamcoil/Initialize()
	. = ..()
	shrapnel_type = pick(potential_projectiles)

/obj/item/grenade/dreamcoil/detonate(mob/living/lanced_by)
	. = ..()
	do_sparks(rand(3, 6), FALSE, src)
	qdel(src)

/obj/projectile/magic/shrink/superweak //very brief shrink for the dreamcoil
	shrink_time = 15 SECONDS

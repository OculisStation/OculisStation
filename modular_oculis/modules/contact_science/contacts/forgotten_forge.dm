GLOBAL_LIST_INIT(already_upgraded, list())

/mob/living/simple_animal/formic/forgotten_forge
	name = "Forgotten Forge"
	desc = "An ever-beating heart bearing an unblinking eye. Various bits of clockwork and brass are sticking out of it."
	icon = 'modular_oculis/modules/contact_science/icons/forgotten_forge.dmi'
	icon_state = "heart"

	nanotrasen_id = "NT-ARDB-002"
	primary_hazard_labels = "Somatohazard"
	secondary_hazard_labels = "Bodily alteration, hostile manifestation"
	initial_line = "We must prepare for your trial. Come forth, and be changed, changed."
	hidden_description = "An artificial heart, its internals powered by brass clockwork. We theorize it to be some kind of remnant or memory of the long-forgotten 'Clockwork Cult.' It seems to express a desire to provide augmentation in preparation for something."
	dialogue_lines = list(
		"Even in this age of stagnation, I am present, present.",
		"I will change you for the better. Pledge yourself to me, to me.",
		"One day, the age of brass will return, return.",
		"Your armaments are suboptimal. Allow me to improve them, improve them.",
		"I dream of a world of brass, brass.",
		"Loyal ones, step forth, and be changed, changed.",
		"The clock ticks. What are you waiting for, waiting for?",
		"Pledge loyalty, and I will improve you, improve you."
	)
	echoes = list(
		"i present myself",
		"i present my blade"
	)

	var/loyalty = 0 //goes up by 1 with each augmentation, similar to Philosopher's Camera.
	var/loyalty_threshold = 4 //at the threshold, breach. randomized a bit when initialized
	var/firstaugment = TRUE //after first augment, unlock new echoes

/mob/living/simple_animal/formic/forgotten_forge/Initialize(mapload)
	. = ..()
	loyalty_threshold += rand(0, 3)

/mob/living/simple_animal/formic/forgotten_forge/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "i present myself") //install a random unique implant into yourself, take damage to the implanted limb
		last_response = "i present myself"
		if(get_dist(src, last_speaker) > 1) //must be adjacent
			langsay("Come closer, closer.")
		else
			give_augment(0)
	if(successful_echo == "i present my blade") //give a random upgrade to one of your weapons, take damage to a random limb
		last_response = "i present my blade"
		if(get_dist(src, last_speaker) > 1)
			langsay("Bring it closer, closer.")
		else
			give_upgrades()
	if(successful_echo == "why are you here") //simple dialogue, meant to hint at the containment breach
		langsay("Something great is coming. You must be ready to embrace it, embrace it.")

/mob/living/simple_animal/formic/forgotten_forge/proc/give_upgrades() //for both hands, find weapons and give them random upgrades
	var is_success = FALSE
	var/obj/item/upgrading_item = last_speaker.get_active_held_item()
	var/upgrade_type = rand(1,3)
	if(!GLOB.already_upgraded.Find(upgrading_item)) //if not in the list of things already upgraded
		if(istype(upgrading_item, /obj/item/gun))
			var/obj/item/gun/upgrading_gun = upgrading_item
			if(upgrade_type == 1) //make weapon more accurate and improve its projectile speed
				upgrading_gun.projectile_speed_multiplier += 0.25
				upgrading_gun.spread *= 0.5
				to_chat(last_speaker, span_notice("The " + upgrading_gun.name + " becomes more accurate. You feel like you could hit anything."))
				upgrading_gun.name = "brass-accurized " + upgrading_gun.name
				is_success = TRUE
			if(upgrade_type == 2) //make weapon suppressed, also increases damage a bit so that it's still an upgrade for already-suppressed weapons
				upgrading_gun.suppressed = SUPPRESSED_QUIET
				upgrading_gun.can_unsuppress = FALSE
				upgrading_gun.projectile_damage_multiplier += 0.1
				to_chat(last_speaker, span_notice("The " + upgrading_gun.name + " becomes suppressed. It feels deadlier in your hands."))
				upgrading_gun.name = "brass-suppressed " + upgrading_gun.name
				is_success = TRUE
			if(upgrade_type == 3) //make weapon light, allowing it to be one-handed. also reduces dual wield spread
				upgrading_gun.weapon_weight = WEAPON_LIGHT
				upgrading_gun.dual_wield_spread *= 0.5
				to_chat(last_speaker, span_notice("The " + upgrading_gun.name + " becomes lightened. Its burdens are removed."))
				upgrading_gun.name = "brass-lightened " + upgrading_gun.name
				is_success = TRUE
		else if(istype(upgrading_item, /obj/item) && upgrading_item.force > 10) //only upgrades if the item has enough force for it to consider the item a melee weapon. yes toolboxes apply
			var/obj/item/upgrading_melee = upgrading_item
			if(upgrade_type == 1) //make weapon better at blocking
				upgrading_melee.block_chance += 20
				to_chat(last_speaker, span_notice("The " + upgrading_melee.name + "'s guarding is improved. You feel safer wielding it."))
				upgrading_melee.name = "brass-guarding " + upgrading_melee.name
				is_success = TRUE
			if(upgrade_type == 2) //make weapon better at penetrating armor
				upgrading_melee.armour_penetration += 20
				to_chat(last_speaker, span_notice("The " + upgrading_melee.name + "'s armor penetration is improved. No matter its original sharpness, it somehow feels sharper."))
				upgrading_melee.name = "brass-piercing " + upgrading_melee.name
				is_success = TRUE
			if(upgrade_type == 3) //give weapon more force
				upgrading_melee.force += 3
				to_chat(last_speaker, span_notice("The " + upgrading_melee.name + "'s force is improved. Somehow, the weapon feels... guilty?"))
				upgrading_melee.name = "brass-striking " + upgrading_melee.name
				is_success = TRUE
	if(is_success)
		loyalty += 1
		var/limb_to_hit = last_speaker.get_bodypart(last_speaker.get_random_valid_zone(even_weights = TRUE))
		GLOB.already_upgraded += upgrading_item
		last_speaker.apply_damage(loyalty * 5, BRUTE, limb_to_hit, wound_bonus=CANT_WOUND)
		last_speaker.add_splatter_floor(get_turf(last_speaker), FALSE)
		to_chat(last_speaker, span_warning("An ache creeps around your body, like a serpent searching for a point to sink its teeth into."))
		playsound(last_speaker, 'sound/effects/magic/staff_healing.ogg', 50)
		if(firstaugment) //different lines if first upgrade, also first upgrade unlocks echoes
			langsay("Feel the brass in your hands, hands.")
			firstaugment = FALSE
			echoes += "why are you here"
			balloon_alert(last_speaker, "new echoes detected!")
		else
			langsay("Feel the brass in your hands, loyal one, loyal one.")
	else
		if(firstaugment)
			langsay("I cannot forge this, nascent one, nascent one.")
		else
			langsay("I cannot forge this, forge this.")

/mob/living/simple_animal/formic/forgotten_forge/proc/give_augment(var/num_loops)
	if(num_loops >= 10) //at ten loops, activate failsafe
		langsay("Your body is already prepared, prepared.")
		return
	var/list/potential_implants = list(
		/obj/item/organ/cyberimp/arm/toolkit/clockwork_spear/left_arm,
		/obj/item/organ/cyberimp/arm/toolkit/clockwork_spear/right_arm,
		/obj/item/organ/cyberimp/arm/toolkit/shell_launcher/clockwork,
		/obj/item/organ/cyberimp/arm/toolkit/shell_launcher/clockwork/l,
		/obj/item/organ/cyberimp/chest/clockwork_regen
	)
	var/obj/item/organ/chosen_implant = pick(potential_implants)
	var/obj/item/organ/plooby = new chosen_implant
	if(!plooby.mob_insert(last_speaker)) // pick a special implant and try to insert
		give_augment(num_loops + 1) //increase number of tries by 1 and retry on failing
		qdel(plooby)
		return
	else
		loyalty += 1
		langsay("You are changed for the greater, greater.")
		playsound(last_speaker, 'sound/effects/magic/staff_healing.ogg', 50)
		last_speaker.apply_damage(loyalty * 5, BRUTE, chosen_implant.zone, wound_bonus=CANT_WOUND)
		to_chat(last_speaker, span_warning("An ache festers within your body as a " + chosen_implant.name + " is inserted into you."))
		last_speaker.add_splatter_floor(get_turf(last_speaker), FALSE)

/mob/living/simple_animal/formic/forgotten_forge/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()

	if(loyalty >= loyalty_threshold && !breaching) //if meeting the threshold, breach
		breaching = TRUE
		langsay("Finally, you are ready for your trial. Allow your brass to carry you to victory, victory.")
		sound_to_playing_players('sound/effects/magic/lightning_chargeup.ogg')
		addtimer(CALLBACK(src, PROC_REF(breach)), 80, TIMER_UNIQUE | TIMER_DELETE_ME)

/mob/living/simple_animal/formic/forgotten_forge/proc/breach()
	priority_announce("An anomalous resonance form has breached containment within [station_name()]. Please route to subdue the hostile form.")
	new /mob/living/simple_animal/hostile/megafauna/clockwork_defender/true(get_turf(src))
	src.gib(DROP_ALL_REMAINS)

/mob/living/simple_animal/hostile/megafauna/clockwork_defender/true
	name = "true clockwork defender"
	desc = "So this is what it was preparing you for."
	health = 650
	maxHealth = 650
	speed = 5
	ranged = TRUE
	ranged_cooldown_time = 120
	melee_damage_lower = 15
	melee_damage_upper = 30
	melee_damage_type = BRUTE
	gps_name = "True Signal"
	attack_sound = 'modular_nova/master_files/sound/weapons/bloodyslice.ogg'
	death_sound = 'sound/effects/magic/staff_healing.ogg'
	ranged_ignores_vision = FALSE

/mob/living/simple_animal/hostile/megafauna/clockwork_defender/true/Initialize(mapload)
	. = ..()
	loot = list(/obj/item/clockwork_alloy) //re-override loot list because something else makes it spawn the book. no book from this one

/mob/living/simple_animal/hostile/megafauna/clockwork_defender/true/OpenFire()
	if(prob(50)) //50/50 between far throw and charge-attack
		INVOKE_ASYNC(src, PROC_REF(spear_throw), target)
	else
		INVOKE_ASYNC(src, PROC_REF(charge_attack), target)

/mob/living/simple_animal/hostile/megafauna/clockwork_defender/true/proc/spear_throw(atom/target)
	var/obj/item/clockwork/weapon/brass_spear/to_throw = new /obj/item/clockwork/weapon/brass_spear(get_turf(src))
	to_throw.throwforce = 35
	playsound(src, 'sound/items/weapons/bolathrow.ogg', 60, 0)
	to_throw.throw_at(target, 12, 5, thrower = src)
	QDEL_IN(to_throw, 3 SECONDS)

/mob/living/simple_animal/hostile/megafauna/clockwork_defender/true/proc/charge_attack(atom/target)
	var/relative_direction = get_dir(src, target)
	var/atom/throw_target = get_edge_target_turf(target, relative_direction)
	src.throw_at(throw_target, 3, 3, src, gentle = TRUE)

/mob/living/simple_animal/formic/forgotten_forge/resonate_info()
	var/list/message = list()
	message += "Loyalty: [loyalty]"
	return message

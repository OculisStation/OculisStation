/mob/living/simple_animal/formic/ozymandian_wreckage
	name = "Ozymandian Wreckage"
	desc = "Yellow wires dangle from the open internals of this destroyed chassis. A voice rings from within."
	icon = 'modular_oculis/modules/contact_science/icons/ozymandian_wreckage.dmi'
	icon_state = "ozymandia-broken"

	nanotrasen_id = "NT-ARDB-008"
	primary_hazard_labels = "Electrohazard"
	secondary_hazard_labels = "Hostile manifestation"
	initial_line = "Look upon my frame... and despair."
	hidden_description = "A Phazon-model exosuit bearing unusual purple plating and yellow internals. Despite the lack of audio equipment within, it seems to be able to vocalize from a source unknown. Repair may be possible, but be aware of potential breaching."
	dialogue_lines = list(
		"It will return again... and be gone again all the same.",
		"!ERROR! !ERROR! Vital parts missing.",
		"Aren't my works wonderful?",
		"Your pointless wars... there and back again.",
		"Wars waged across countless parties... I, the greatest of them all.",
		"One day, they will look upon me again, all the same.",
		"The day She was slain... it was no different. It will happen again, and again."
	)
	echoes = list(
		"what happened to you",
		"what are you"
	)

	var/list/potential_parts = list( //potential object types which can be selected for repair
		"Femto-Servo" = /obj/item/stock_parts/servo/femto,
		"Subspace Amplifier" = /obj/item/stock_parts/subspace/amplifier,
		"Hyperwave Filter" = /obj/item/stock_parts/subspace/filter,
		"Ansible Crystal" = /obj/item/stock_parts/subspace/crystal,
		"Wavelength Analyzer" = /obj/item/stock_parts/subspace/analyzer,
		"Flux Core" = /obj/item/assembly/signaler/anomaly/flux,
		"Bluespace Core" = /obj/item/assembly/signaler/anomaly/bluespace,
		"Gravity Core" = /obj/item/assembly/signaler/anomaly/grav,
		"Slime Extract" = /obj/item/slime_extract,
		"Bluespace Megacell" = /obj/item/stock_parts/power_store/battery/bluespace
	)
	var/list/success_dialogue = list(
		"Good... continue.",
		"Very good... more must be done.",
		"Keep going. There is much to be done.",
		"!ERROR! !ERROR! More repairs required."
	)
	var/current_part
	var/num_repairs = 0
	var/required_repairs
	var/base_zap_chance = 20
	var/zap_range = 5
	var/zap_power = 1e10
	var/zap_flags = ZAP_DEFAULT_FLAGS
	var/repair_result
	var/ready_for_repair = FALSE
	var/first_repair = TRUE

/mob/living/simple_animal/formic/ozymandian_wreckage/Initialize(mapload)
	. = ..()
	current_part = pick(potential_parts)
	required_repairs = potential_parts.len / 2 //requires half of the total amount of things the repair could potentially need
	repair_result = rand(1, 2) //which repair type will occur when successfully repaired. 1 = breach, 2 = regular repair

/mob/living/simple_animal/formic/ozymandian_wreckage/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "what happened to you") //starting dialogue. meant to establish symbolism
		last_response = "what happened to you"
		langsay("One of your needless conflicts... now, you will put me back together.")
		echoes -= "what happened to you"
		echoes -= "what are you"
		echoes += "what do you need"
		echoes += "what would i gain"
		ready_for_repair = TRUE
		balloon_alert(last_speaker, "new echoes detected!")
	if(successful_echo == "what are you") //starting dialogue. meant to establish symbolism
		last_response = "what are you"
		langsay("I ruled over all, once. And, I will once again... you will put me back together.")
		echoes -= "what happened to you"
		echoes -= "what are you"
		echoes += "what do you need"
		echoes += "what would i gain"
		ready_for_repair = TRUE
		balloon_alert(last_speaker, "new echoes detected!")
	if(successful_echo == "what do you need" || "what next") //repair dialogue, so the player knows what to do next
		last_response = successful_echo
		langsay(get_part_dialogue())
	if(successful_echo == "what would i gain") //extra, reveals result type
		if(last_response == "what would i gain")
			langsay("You will see my work continue.")
			return
		last_response = "what would i gain"
		langsay(get_result_dialogue())

/mob/living/simple_animal/formic/ozymandian_wreckage/attackby(obj/item/attacking_item, mob/living/user)
	. = ..()
	if (!istype(user) || user.combat_mode || !ready_for_repair)
		return

	if(istype(attacking_item, potential_parts[current_part]))
		playsound(src, 'sound/items/deconstruct.ogg', 30, TRUE)
		num_repairs += 1
		potential_parts -= current_part //only one of each randomly-chosen part should be needed
		current_part = pick(potential_parts)
		qdel(attacking_item)
		balloon_alert(user, "repair successful!")
		if(prob(base_zap_chance + num_repairs * 5)) //low but ever-present and increasing chance for tesla proc. get grounding rods!
			for(var/i in 1 to 3) //couple of em
				tesla_zap(source = src, zap_range = zap_range, power = zap_power, cutoff = zap_power * 2, zap_flags = zap_flags)
		if(num_repairs >= required_repairs)
			successful_repair()
		else
			langsay(pick(success_dialogue))
			if(first_repair)
				first_repair = FALSE
				echoes -= "what do you need"
				echoes += "what next"
				balloon_alert(last_speaker, "new echoes detected!")

/mob/living/simple_animal/formic/ozymandian_wreckage/proc/successful_repair()
	if(repair_result == 1) //breach
		langsay("It is done... now, I can continue my work.")
		sound_to_playing_players('sound/effects/magic/lightning_chargeup.ogg')
		addtimer(CALLBACK(src, PROC_REF(breach)), 80, TIMER_UNIQUE | TIMER_DELETE_ME)
	if(repair_result == 2) //salvage
		langsay("It is done... now, you can continue my work.")
		addtimer(CALLBACK(src, PROC_REF(salvage)), 40, TIMER_UNIQUE | TIMER_DELETE_ME)

/mob/living/simple_animal/formic/ozymandian_wreckage/proc/breach()
	priority_announce("An anomalous resonance form has breached containment within [station_name()]. Please route to subdue the hostile form.")
	new /mob/living/simple_animal/hostile/ozymandia(get_turf(src))
	qdel(src)

/mob/living/simple_animal/formic/ozymandian_wreckage/proc/salvage()
	tesla_zap(source = src, zap_range = zap_range, power = zap_power, cutoff = zap_power * 2, zap_flags = zap_flags) //one more for the road
	var/obj/vehicle/sealed/mecha/ripley/ozymandia/spawned_mech = new /obj/vehicle/sealed/mecha/ripley/ozymandia(get_turf(src))
	spawned_mech.populate_parts()
	qdel(src)

/mob/living/simple_animal/formic/ozymandian_wreckage/proc/get_part_dialogue()
	if(current_part == "Flux Core")
		return "A flux anomaly core... I am not sustaining enough power."
	if(current_part == "Bluespace Core")
		return "A bluespace anomaly core... my tethering software is malfunctioning."
	if(current_part == "Gravity Core")
		return "A gravity anomaly core... my gravitic gyroscopes are dysfunctional."
	if(current_part == "Ansible Crystal")
		return "An ansible crystal... my transmitters are lacking."
	if(current_part == "Hyperwave Filter")
		return "A hyperwave filter... my senses are blurry."
	if(current_part == "Subspace Amplifier")
		return "A subspace amplifier... my current recievers are clouded with static."
	if(current_part == "Wavelength Analyzer")
		return "A wavelength analyzer... I cannot function without undamaged analytical systems."
	if(current_part == "Femto-Servo")
		return "A femto-servo... I cannot move my limbs."
	if(current_part == "Slime Extract")
		return "An extract of slime... my mechanisms are not sufficiently lubricated."
	if(current_part == "Bluespace Megacell")
		return "A bluespace megacell... my battery is presently too damaged."

/mob/living/simple_animal/formic/ozymandian_wreckage/proc/get_result_dialogue()
	if(repair_result == 1) //will breach
		return "Enough repairs, and I will lend you my strength."
	if(repair_result == 2) //will not breach
		return "Enough repairs, and proper salvage should be possible."

/mob/living/simple_animal/formic/ozymandian_wreckage/resonate_info()
	var/list/message = list()
	message += "Arc Risk: [base_zap_chance + num_repairs * 5]%"
	return message

/obj/vehicle/sealed/mecha/ripley/ozymandia //has to be an extension of the ripley for cargo hold functionality
	name = "\improper Ozymandia"
	desc = "An exosuit akin to the Phazon in chassis appearance with a cargo system designed for holding anomaly cores. You've never seen anything like it."
	icon = 'modular_oculis/modules/contact_science/icons/ozymandian_wreckage.dmi'
	icon_state = "ozymandia"
	base_icon_state = "ozymandia"
	movedelay = 3
	step_energy_drain = 10
	max_integrity = 200
	armor_type = /datum/armor/mecha_ozymandia
	accesses = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY)
	destruction_sleep_duration = 40
	exit_delay = 40
	force = 8
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 2,
	)
	mech_type = EXOSUIT_MODULE_PHAZON
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/vorpis,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	stepsound = 'sound/vehicles/mecha/mechstep.ogg'
	turnsound = 'sound/vehicles/mecha/mechturn.ogg'

/datum/armor/mecha_ozymandia
	melee = 20
	bullet = 20
	laser = 20
	energy = 40
	bomb = 40
	fire = 100
	acid = 100

/obj/item/mecha_parts/mecha_equipment/weapon/energy/vorpis
	name = "\improper OZ-Y \"Vorpis\" anomaly beam"
	desc = "A strange laser cannon of unknown manufacturer which feeds from anomaly cores stored in a separate mech-mounted compartment."
	icon = 'modular_oculis/modules/contact_science/icons/ozymandian_wreckage.dmi'
	icon_state = "vorpis"
	fire_sound = 'sound/items/weapons/laser.ogg'
	equip_cooldown = 25
	energy_drain = 15 KILO JOULES
	projectile = /obj/projectile/beam/vorpis
	var/obj/item/mecha_parts/mecha_equipment/ejector/loader
	var/obj/vehicle/sealed/mecha/ripley/workmech

/obj/item/mecha_parts/mecha_equipment/weapon/energy/vorpis/attach()
	. = ..()
	workmech = chassis
	loader = workmech.cargo_hold

/obj/item/mecha_parts/mecha_equipment/weapon/energy/vorpis/detach()
	. = ..()
	loader = null
	workmech = null

/obj/item/mecha_parts/mecha_equipment/weapon/energy/vorpis/action(mob/source, atom/target, list/modifiers)
	. = ..()
	if(!loader)
		loader = workmech.cargo_hold
	var/list/obj/item/assembly/signaler/anomaly/core_list
	var/load_success = FALSE
	for(var/obj/item/assembly/signaler/anomaly/core in loader.contents)
		core_list += core
		load_success = TRUE
	if(load_success) //if anomaly cores were found, load one
		projectile = load_anomaly(pick(core_list))
	else //otherwise, default to standard beam
		projectile = /obj/projectile/beam/vorpis

/obj/item/mecha_parts/mecha_equipment/weapon/energy/vorpis/proc/load_anomaly(obj/item/assembly/signaler/anomaly/loading_core)
	if(istype(loading_core, /obj/item/assembly/signaler/anomaly/pyro))
		return /obj/projectile/beam/vorpis/pyro
	if(istype(loading_core, /obj/item/assembly/signaler/anomaly/bluespace))
		return /obj/projectile/beam/vorpis/bluespace
	if(istype(loading_core, /obj/item/assembly/signaler/anomaly/grav))
		return /obj/projectile/beam/vorpis/gravity
	if(istype(loading_core, /obj/item/assembly/signaler/anomaly/flux))
		return /obj/projectile/beam/vorpis/flux
	if(istype(loading_core, /obj/item/assembly/signaler/anomaly/hallucination))
		return /obj/projectile/beam/vorpis/hallucination
	if(istype(loading_core, /obj/item/assembly/signaler/anomaly/bioscrambler))
		return /obj/projectile/beam/vorpis/bios
	if(istype(loading_core, /obj/item/assembly/signaler/anomaly/panopticon))
		return /obj/projectile/beam/vorpis/panopticon
	if(istype(loading_core, /obj/item/assembly/signaler/anomaly/ectoplasm))
		return /obj/projectile/beam/vorpis/ectoplasm
	return /obj/projectile/beam/vorpis/flux //default to flux if no coded core was found

/obj/projectile/beam/vorpis //base class for the anomaly beams
	icon_state = null
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/laser/vorpal
	tracer_type = /obj/effect/projectile/tracer/laser/vorpal
	impact_type = /obj/effect/projectile/impact/laser/vorpal
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_range = 0.75
	hitscan_light_color_override = COLOR_VIOLET
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = COLOR_VIOLET
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = COLOR_VIOLET
	damage = 15

/obj/effect/projectile/impact/laser/vorpal
	name = "vorpal impact"
	icon_state = "impact_hcult"

/obj/effect/projectile/muzzle/laser/vorpal
	name = "vorpal flash"
	icon_state = "muzzle_hcult"

/obj/effect/projectile/tracer/laser/vorpal
	name = "vorpal beam"
	icon_state = "hcult"

/obj/projectile/beam/vorpis/bluespace //bluespace anomaly core
	hitscan_light_color_override = COLOR_DARK_CYAN
	muzzle_flash_color_override = COLOR_DARK_CYAN
	impact_light_color_override = COLOR_DARK_CYAN

/obj/projectile/beam/vorpis/bluespace/impact(atom/target)
	. = ..()
	if(istype(target, /mob/living))
		var/mob/living/victim = target
		playsound(get_turf(victim),'sound/effects/magic/blink.ogg', 50, TRUE)
		do_teleport(victim, get_turf(victim), 5, no_effects = FALSE, channel = TELEPORT_CHANNEL_BLUESPACE)
		victim.visible_message(span_danger("The bluespace beam flings [victim.name] elsewhere!"))

/obj/projectile/beam/vorpis/gravity //gravity anomaly core
	hitscan_light_color_override = COLOR_JADE
	muzzle_flash_color_override = COLOR_JADE
	impact_light_color_override = COLOR_JADE
	var/power = 2

/obj/projectile/beam/vorpis/gravity/impact(atom/target)
	. = ..()
	var/turf/T = get_turf(target)
	var/list/thrown_items = list()
	for(var/atom/movable/A in range(T, power))
		if(A == src || (firer && A == src.firer) || A.anchored || thrown_items[A])
			continue
		if(ismob(A)) //because (ismob(A) && A:mob_negates_gravity()) is a recipe for bugs.
			var/mob/M = A
			if(M.mob_negates_gravity())
				continue
		var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(A, src)))
		A.safe_throw_at(throwtarget,power+1,1, force = MOVE_FORCE_EXTREMELY_STRONG)
		thrown_items[A] = A
	for(var/turf/F in RANGE_TURFS(power, T))
		new /obj/effect/temp_visual/gravpush(F)

/obj/projectile/beam/vorpis/pyro //pyro anomaly core
	hitscan_light_color_override = COLOR_ORANGE
	muzzle_flash_color_override = COLOR_ORANGE
	impact_light_color_override = COLOR_ORANGE

/obj/projectile/beam/vorpis/pyro/impact(atom/target)
	. = ..()
	for(var/turf/turf as anything in RANGE_TURFS(1, get_turf(target)))
		new /obj/effect/hotspot(turf)

/obj/projectile/beam/vorpis/flux //flux anomaly core
	hitscan_light_color_override = COLOR_YELLOW
	muzzle_flash_color_override = COLOR_YELLOW
	impact_light_color_override = COLOR_YELLOW

/obj/projectile/beam/vorpis/flux/impact(atom/target)
	. = ..()
	for(var/i in 1 to 3) //couple of em
		tesla_zap(source = target, zap_range = 4, power = 1e10, cutoff = 1e10, zap_flags = ZAP_DEFAULT_FLAGS)

/obj/projectile/beam/vorpis/hallucination //hall anomaly core
	hitscan_light_color_override = COLOR_SOFT_RED
	muzzle_flash_color_override = COLOR_SOFT_RED
	impact_light_color_override = COLOR_SOFT_RED

/obj/projectile/beam/vorpis/hallucination/impact(atom/target)
	. = ..()
	visible_hallucination_pulse(get_turf(target), 2, 20 SECONDS, 1 MINUTES)

/obj/projectile/beam/vorpis/bios //bioscrambler anomaly core
	hitscan_light_color_override = COLOR_OLIVE_GREEN
	muzzle_flash_color_override = COLOR_OLIVE_GREEN
	impact_light_color_override = COLOR_OLIVE_GREEN

/obj/projectile/beam/vorpis/bios/impact(atom/target)
	. = ..()
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/victim = target
		victim.bioscramble(src)

/obj/projectile/beam/vorpis/panopticon //panopticon anomaly core, pan. beast exclusive
	hitscan_light_color_override = COLOR_BLACK
	muzzle_flash_color_override = COLOR_BLACK
	impact_light_color_override = COLOR_BLACK

/obj/projectile/beam/vorpis/panopticon/impact(atom/target)
	. = ..()
	do_sparks(3, FALSE, get_turf(target))
	for(var/obj/machinery/camera/C in range(3, get_turf(target)))
		C.camera_enabled = FALSE
	for(var/obj/machinery/light/L in range(3, get_turf(target)))
		L.break_light_tube()

/obj/projectile/beam/vorpis/ectoplasm //ghost anomaly core
	hitscan_light_color_override = COLOR_WHITE
	muzzle_flash_color_override = COLOR_WHITE
	impact_light_color_override = COLOR_WHITE

/obj/projectile/beam/vorpis/ectoplasm/impact(atom/target)
	. = ..()
	haunt_outburst(get_turf(target), 2, 50, 30 SECONDS)

/mob/living/simple_animal/hostile/ozymandia //breaching version
	name = "Ozymandia"
	desc = "You don't have time to examine too closely; this strange exosuit is active and hostile."
	health = 800
	maxHealth = 800
	speed = 6
	icon = 'modular_oculis/modules/contact_science/icons/ozymandian_wreckage.dmi'
	icon_state = "ozymandia"
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	melee_damage_lower = 8
	melee_damage_upper = 12
	melee_damage_type = BRUTE
	obj_damage = 60
	ranged = TRUE
	ranged_cooldown_time = 35
	projectiletype = /obj/projectile/beam/vorpis/flux
	vision_range = 18
	aggro_vision_range = 18
	robust_searching = TRUE
	attack_vis_effect = ATTACK_EFFECT_SMASH
	mob_size = MOB_SIZE_LARGE
	attack_verb_continuous = "pridefully pummels"
	attack_verb_simple = "pummel"
	ai_controller = /datum/ai_controller/basic_controller/ozymandia
	death_sound = 'sound/effects/portal/portal_travel.ogg'
	death_message = "'s voice dissipates, leaving an empty, open exosuit."

	var/list/projectile_types = list(
		/obj/projectile/beam/vorpis/bluespace,
		/obj/projectile/beam/vorpis/panopticon,
		/obj/projectile/beam/vorpis/hallucination,
		/obj/projectile/beam/vorpis/flux,
		/obj/projectile/beam/vorpis/ectoplasm
	)

/mob/living/simple_animal/hostile/ozymandia/OpenFire()
	. = ..()
	projectiletype = pick(projectile_types)

/mob/living/simple_animal/hostile/ozymandia/death()
	. = ..()
	var/obj/vehicle/sealed/mecha/ripley/ozymandia/spawned_mech = new /obj/vehicle/sealed/mecha/ripley/ozymandia(get_turf(src))
	spawned_mech.populate_parts()

/datum/ai_controller/basic_controller/ozymandia
	behavior_tree_json = "modular_oculis/modules/contact_science/ai/ozymandia_ai.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance

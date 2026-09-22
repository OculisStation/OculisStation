/mob/living/simple_animal/formic/panopticon_beast
	name = "Panopticon Beast"
	desc = "A vague, quadrupedal figure. Its form is hard to make out."
	icon = 'modular_oculis/modules/contact_science/icons/observer.dmi'
	icon_state = "observer"

	nanotrasen_id = "NT-ARDB-004"
	primary_hazard_labels = "N/A"
	secondary_hazard_labels = "Hostile manifestation"
	initial_line = "Request. Feed. Logistics. Reward."
	hidden_description = "An antiperceptive quadrupedal creature. It seems to want to be fed logistical data, cargo shipping manifests should work? We advise you do not let it grow hungry."
	dialogue_lines = list(
		"Observe. Grow. Help.",
		"Storm. Cold. Cold. Cold.",
		"Supply. Data. Feed. Reward.",
		"Watch. Listen. Speak.",
		"Hunger. Thirst. Logistics. Feed.",
		"Know. Logistics. Know. Everything.",
		"Distant. Close. Connect."
	)
	echoes = list(
		"feed from my hand",
		"what is my reward",
		"are you hungry"
	)

	var/points = 0
	var/rewards = 0 //gain 1 reward per 3 points
	var/feeding_timer = 220
	var/feeding_timer_current = 220 //dont let it get hungry!

	var/list/obj/item/potential_rewards = list(
		/obj/item/raw_anomaly_core/panopticon
	)

/mob/living/simple_animal/formic/panopticon_beast/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(feeding_timer_current > 0)
		feeding_timer_current -= 1
	else //break out once its starving
		if(!breaching)
			breaching = TRUE
			sound_to_playing_players('sound/effects/magic/lightning_chargeup.ogg')
			addtimer(CALLBACK(src, PROC_REF(breach)), 80, TIMER_UNIQUE | TIMER_DELETE_ME)

/mob/living/simple_animal/formic/panopticon_beast/proc/breach()
	priority_announce("An anomalous resonance form has breached containment within [station_name()]. Please route to subdue the hostile form.")
	new /mob/living/simple_animal/hostile/panopticon_beast(get_turf(src))
	qdel(src)

/mob/living/simple_animal/formic/panopticon_beast/echo_success()
	var/successful_echo = awaiting_response
	if(breaching)
		return
	if(successful_echo == "feed from my hand") //feed from the hands of the speaker
		last_response = "feed from my hand"
		if(get_dist(src, last_speaker) > 1) //must be adjacent
			langsay("Closer. Hand. Forward.")
		else
			feed_logistics(last_speaker)
	if(successful_echo == "what is my reward") //get rewards
		last_response = "what is my reward"
		if(rewards > 0)
			give_reward(last_speaker)
		else
			langsay("Feed. More. Then. Reward.")
	if(successful_echo == "are you hungry") //check the timer
		last_response = "are you hungry"
		if(feeding_timer_current < feeding_timer * 0.25) //less than 25%
			langsay("Starving. Feed. Feed. Feed.")
		else if(feeding_timer_current < feeding_timer * 0.5) //less than 50%
			langsay("Hungry. Feed. Feed.")
		else if(feeding_timer_current < feeding_timer * 0.75) //less than 75%
			langsay("Peckish. Feed. Data.")
		else
			langsay("Full. Yet. Hungry. Always. Feed.")

/mob/living/simple_animal/formic/panopticon_beast/proc/feed_logistics(mob/living/carbon/human/feeder)
	var is_success = FALSE
	for(var/obj/item/feeding_item in feeder.held_items)
		if(istype(feeding_item, /obj/item/paper/fluff/jobs/cargo/manifest)) //eat cargo manifest
			points += 1
			if(points >= 3)
				points -= 3
				rewards += 1
			is_success = TRUE
			to_chat(feeder, span_warning("The manifest disappears as its essence is absorbed by the creature."))
			qdel(feeding_item)
	if(is_success)
		langsay("Feed. Gratitude. Grow.")
		playsound(feeder, 'sound/effects/portal/portal_travel.ogg', 25)
		feeding_timer -= 5 //reduce the max timer, little by little. it will get out eventually
		feeding_timer_current += feeding_timer * 0.25
	else
		langsay("Cannot. Feed. Bring. Data.")

/mob/living/simple_animal/formic/panopticon_beast/proc/give_reward(mob/living/carbon/human/rewardee)
	to_chat(rewardee, span_warning("The creature regurgitates item(s) at you!"))
	for(var/i in 1 to rewards)
		var/obj/item/reward_to_give = pick(potential_rewards)
		var/obj/item/reward_to_throw = new reward_to_give(get_turf(src))
		reward_to_throw.throw_at(rewardee, 7, 3, thrower = src, gentle = TRUE)
	rewards = 0
	langsay("Reward.")

/obj/effect/anomaly/panopticon //unique anomaly type. must exist for the core to exist
	name = "panopticon anomaly"
	anomaly_core = /obj/item/assembly/signaler/anomaly/panopticon
	icon = 'modular_oculis/modules/contact_science/icons/special_anomalies.dmi'
	icon_state = "panopticon"
	var/effect_range = 5

/obj/effect/anomaly/panopticon/Initialize(mapload, new_lifespan)
	. = ..()
	apply_wibbly_filters(src)

/obj/effect/anomaly/panopticon/anomalyEffect()
	..()
	for(var/obj/machinery/camera/C in range(effect_range, src))
		C.camera_enabled = FALSE
	for(var/obj/machinery/light/L in range(effect_range, src))
		L.break_light_tube()

/obj/item/assembly/signaler/anomaly/panopticon
	name = "\improper panopticon anomaly core"
	desc = "The neutralized core of a panopticon anomaly. Somehow, it feels like it's looking at you. It'd probably be valuable for research."
	icon = 'modular_oculis/modules/contact_science/icons/special_anomalies.dmi'
	icon_state = "panopticon_core"
	core_color = COLOR_BLACK
	anomaly_type = /obj/effect/anomaly/panopticon
	var/effect_range = 2

/obj/item/assembly/signaler/anomaly/panopticon/signal()
	do_sparks(3, FALSE, get_turf(src))
	for(var/obj/machinery/camera/C in range(effect_range, src))
		C.camera_enabled = FALSE
	for(var/obj/machinery/light/L in range(effect_range, src))
		L.break_light_tube()

/obj/item/raw_anomaly_core/panopticon
	name = "raw panopticon core"
	desc = "The raw core of a panopticon anomaly, full of glaring eyes and waiting teeth."
	anomaly_type = /obj/item/assembly/signaler/anomaly/panopticon
	icon = 'modular_oculis/modules/contact_science/icons/special_anomalies.dmi'
	icon_state = "rawcore_panopticon"

/obj/item/clothing/suit/armor/reactive/panopticon //reactive panopticon armor, creates multitool-style arrows towards all nearby player characters
	name = "reactive panopticon armor"
	desc = "An experimental suit of armor with a reactive sensor array aligned with a sight-manipulating threat detector."
	emp_message = span_warning("The reactive armor's sight-manipulators begin to short!")
	cooldown_message = span_danger("The reactive detection system is still recharging! It fails to activate!")
	reactivearmor_cooldown_duration = 5 SECONDS
	var/effect_range = 5

/obj/item/clothing/suit/armor/reactive/panopticon/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/datum/hud/user_hud = owner.hud_used
	if(!user_hud)
		return
	owner.visible_message(span_danger("[src] blocks [attack_text], revealing lifeforms nearby!"))
	var/threats_counted = 0
	do_sparks(3, FALSE, get_turf(owner))
	for(var/mob/living/H in range(effect_range * 2, owner))
		if(H != owner)
			threats_counted += 1
			var/arrow_key = "threat_arrow_" + threats_counted
			var/dir = get_dir(owner, H)
			var/atom/movable/screen/multitool_arrow/arrow = user_hud.add_screen_object(/atom/movable/screen/multitool_arrow, arrow_key, HUD_GROUP_INFO, update_screen = TRUE)
			arrow.color = COLOR_RED
			arrow.transform = matrix(dir2angle(dir), MATRIX_ROTATE)
			QDEL_IN(arrow, 0.75 SECONDS)

/obj/item/clothing/suit/armor/reactive/panopticon/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] fizzles, altering nearby cameras and lights!"))
	do_sparks(3, FALSE, get_turf(owner))
	for(var/obj/machinery/camera/C in range(effect_range, owner))
		C.camera_enabled = FALSE
	for(var/obj/machinery/light/L in range(effect_range, owner))
		L.break_light_tube()
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return FALSE

/mob/living/simple_animal/hostile/panopticon_beast //breaching version
	name = "Panopticon Beast"
	desc = "Hungry. Feed. Starving. Devour."
	health = 1000
	maxHealth = 1000
	speed = 8
	icon = 'modular_oculis/modules/contact_science/icons/observer.dmi'
	icon_state = "observer"
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	melee_damage_lower = 20
	melee_damage_upper = 30
	melee_damage_type = BRUTE
	obj_damage = 80
	ranged = TRUE
	ranged_cooldown_time = 90
	projectiletype = /obj/projectile/panopticon_ball
	vision_range = 27 //vision range is very high. the panopticon will find you
	aggro_vision_range = 27
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	mob_size = MOB_SIZE_LARGE
	attack_verb_continuous = "slashes at"
	attack_verb_simple = "slash at"
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	ai_controller = /datum/ai_controller/basic_controller/panbeast
	death_sound = 'sound/effects/portal/portal_travel.ogg'
	death_message = "vanishes, just as quickly as it came."
	var/list/projectile_lines = list(
		"Suffocate. Starve.",
		"Die.",
		"Hate. Drown."
	)

/mob/living/simple_animal/hostile/panopticon_beast/Initialize(mapload)
	. = ..()
	say("Devour. Devour. Devour.")

/mob/living/simple_animal/hostile/panopticon_beast/OpenFire()
	. = ..()
	say(pick(projectile_lines))
	playsound(src, 'sound/effects/portal/portal_travel.ogg', 35)

/obj/projectile/panopticon_ball //slow, piercing projectile which deals burn and stamina damage
	name = "panopticon sphere"
	icon = 'modular_oculis/modules/contact_science/icons/observer_items_old.dmi'
	icon_state = "beast_projectile"
	hitsound = 'sound/effects/portal/portal_travel.ogg'
	projectile_piercing = PASSTABLE | PASSGLASS | PASSGRILLE | PASSMOB | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSFLAPS | PASSDOORS
	speed = 0.4
	damage = 25
	stamina = 10
	immobilize = 1 SECONDS
	jitter = 3 SECONDS
	damage_type = BURN
	reflectable = FALSE
	armor_flag = ENERGY

/datum/ai_controller/basic_controller/panbeast
	behavior_tree_json = "modular_oculis/modules/contact_science/ai/panbeast_ai.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/mob/living/simple_animal/formic/panopticon_beast/resonate_info()
	var/list/message = list()
	message += "Satiation: [feeding_timer_current]"
	return message

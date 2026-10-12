//Blank PK modkit, able to be fit with an anomaly core
/obj/item/borg/upgrade/modkit/blank
	name = "blank anomaly kit"
	desc = "A specialized PK anomaly modkit. This one is currently empty, awaiting an anomaly core for completion."
	cost = 10
	icon = 'modular_oculis/modules/anomalykits/icons/obj/anomalykits.dmi'
	icon_state = "anomalykitempty"
	custom_materials = list(
		/datum/material/iron =SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass =SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver =SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold =SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/uranium =SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond =SHEET_MATERIAL_AMOUNT
	)

/obj/item/borg/upgrade/modkit/blank/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	var/static/list/anomaly_kit_types = list(
		/obj/effect/anomaly/grav = /obj/item/borg/upgrade/modkit/cooldown/gravity,
		/obj/effect/anomaly/weather = /obj/item/borg/upgrade/modkit/weather,
		/obj/effect/anomaly/ectoplasm = /obj/item/borg/upgrade/modkit/ectoplasm,
		/obj/effect/anomaly/bluespace = /obj/item/borg/upgrade/modkit/cooldown/bluespace,
		/obj/effect/anomaly/bhole = /obj/item/borg/upgrade/modkit/vortex,
		/obj/effect/anomaly/flux = /obj/item/borg/upgrade/modkit/flux,
		/obj/effect/anomaly/bioscrambler = /obj/item/borg/upgrade/modkit/bioscrambler,
	)

	if(istype(tool, /obj/item/assembly/signaler/anomaly))
		var/obj/item/assembly/signaler/anomaly/anomaly = tool
		var/anomkit_path = is_path_in_list(anomaly.anomaly_type, anomaly_kit_types, TRUE)
		if(!anomkit_path)
			anomkit_path = /obj/item/borg/upgrade/modkit/cooldown/gravity //If an anomaly is inserted without a specifically coded modifier, give the gravity one so that the player isn't unrewarded
		to_chat(user, span_notice("You insert [anomaly] into the modkit, and it gently hums to life."))
		new anomkit_path(get_turf(src))
		qdel(src)
		qdel(anomaly)
		return ITEM_INTERACT_SUCCESS

/datum/design/anomaly_mod
	name = "Kinetic Accelerator Blank Anomaly Mod"
	desc = "Ask Research to slot an anomaly core into this for a specialized proto-kinetic accelerator upgrade."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron =SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass =SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver =SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold =SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/uranium =SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond =SHEET_MATERIAL_AMOUNT
	)
	build_path = /obj/item/borg/upgrade/modkit/blank
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_PKA_MODS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/obj/item/borg/upgrade/modkit/cooldown/gravity
	name = "gravitic pulverizer"
	desc = "A specialized PK anomaly modkit. This one vastly increases the weapon's damage at the cost of cooldown, as well as allowing it to knock targets back."
	icon = 'modular_oculis/modules/anomalykits/icons/obj/anomalykits.dmi'
	icon_state = "anomalykit"
	modifier = -10
	cost = 35
	maximum_of_type = 1

/obj/item/borg/upgrade/modkit/cooldown/gravity/modify_projectile(obj/projectile/kinetic/K)
	K.damage -= modifier * 5

/obj/item/borg/upgrade/modkit/cooldown/gravity/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/movable/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	var/relative_direction = get_cardinal_dir(src, target)
	var/atom/throw_target = get_edge_target_turf(target, relative_direction)
	if(!istype(target, /turf) && !target.anchored)
		var/whack_speed = (2)
		target.throw_at(throw_target, 2, whack_speed, K, gentle = TRUE)

/obj/item/borg/upgrade/modkit/weather
	name = "storm capacitor"
	desc = "A specialized PK anomaly modkit. This one allows the weapon to call lightning from above, electrocuting targets."
	icon = 'modular_oculis/modules/anomalykits/icons/obj/anomalykits.dmi'
	icon_state = "anomalykit"
	cost = 35
	maximum_of_type = 1
	modifier = 1

/obj/item/borg/upgrade/modkit/weather/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	new /obj/effect/temp_visual/telegraphing/circle(target_turf)
	addtimer(CALLBACK(src, PROC_REF(shock_turf), target_turf), 1 SECONDS)

/obj/item/borg/upgrade/modkit/weather/proc/shock_turf(turf/target)
	playsound(target, 'sound/effects/magic/lightningbolt.ogg', 66, TRUE)
	new /obj/effect/temp_visual/thunderbolt(target)
	for(var/turf/open/adjacent_turf in oview(1, target))
		new /obj/effect/temp_visual/electricity(adjacent_turf)

	for(var/mob/living/hit_mob in target)
		to_chat(hit_mob, span_userdanger("You've been struck by lightning!"))
		hit_mob.electrocute_act(30, src, flags = SHOCK_TESLA|SHOCK_NOSTUN)
		var/limb_to_hit = hit_mob.get_bodypart(hit_mob.get_random_valid_zone(even_weights = TRUE))
		hit_mob.apply_damage(10, BURN, limb_to_hit, wound_bonus=CANT_WOUND)

	for(var/mob/living/nearby_target in oview(1, target))
		to_chat(nearby_target, span_userdanger("You've been struck by an arc of lightning!"))
		nearby_target.electrocute_act(10, src, flags = SHOCK_TESLA|SHOCK_NOSTUN)
		var/limb_to_hit = nearby_target.get_bodypart(nearby_target.get_random_valid_zone(even_weights = TRUE))
		nearby_target.apply_damage(10, BURN, limb_to_hit, wound_bonus=CANT_WOUND)

/obj/item/borg/upgrade/modkit/ectoplasm
	name = "poltergeist projector"
	desc = "A specialized PK anomaly modkit. This one grants the weapon a chance to haunt nearby objects, throwing them at the target. Comes with a large range increase."
	icon = 'modular_oculis/modules/anomalykits/icons/obj/anomalykits.dmi'
	icon_state = "anomalykit"
	cost = 35
	modifier = 4
	maximum_of_type = 1

/obj/item/borg/upgrade/modkit/ectoplasm/modify_projectile(obj/projectile/kinetic/K)
	K.range += modifier

/obj/item/borg/upgrade/modkit/ectoplasm/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/movable/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	for(var/obj/item/throwable in view(modifier, target))
		if(prob(30))
			playsound(target_turf,'sound/effects/hallucinations/veryfar_noise.ogg', 50, TRUE)
			var/relative_direction = get_cardinal_dir(throwable, target)
			var/atom/throw_target = get_edge_target_turf(target, relative_direction)
			var/whack_speed = (modifier / 2)
			throwable.throw_at(throw_target, modifier, whack_speed, K, gentle = TRUE)

/obj/item/borg/upgrade/modkit/cooldown/bluespace
	name = "bluespace aberrator"
	desc = "A specialized PK anomaly modkit. This one allows the weapon to chaotically teleport targets, alongside increased cooling rates."
	icon = 'modular_oculis/modules/anomalykits/icons/obj/anomalykits.dmi'
	icon_state = "anomalykit"
	cost = 35
	modifier = 4

/obj/item/borg/upgrade/modkit/cooldown/bluespace/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/movable/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	if(!istype(target, /turf) && !target.anchored)
		do_teleport(target, target_turf, 1, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/item/borg/upgrade/modkit/vortex
	name = "vortex attractor"
	desc = "A specialized PK anomaly modkit. This one allows the weapon to pull enemies in, along with an increase to force output."
	icon = 'modular_oculis/modules/anomalykits/icons/obj/anomalykits.dmi'
	icon_state = "anomalykit"
	modifier = 10
	cost = 35
	maximum_of_type = 1

/obj/item/borg/upgrade/modkit/vortex/modify_projectile(obj/projectile/kinetic/K)
	K.damage += modifier

/obj/item/borg/upgrade/modkit/vortex/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/movable/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	var/relative_direction = get_cardinal_dir(target, src)
	var/atom/throw_target = get_edge_target_turf(target, relative_direction)
	if(!istype(target, /turf) && !target.anchored)
		var/whack_speed = (modifier / 5)
		target.throw_at(throw_target, 2, whack_speed, K, gentle = TRUE)

/obj/item/borg/upgrade/modkit/flux
	name = "flux charger"
	desc = "A specialized PK anomaly modkit. This one gives the weapon a slight damage and range increase at no modularity cost. Push the limit."
	icon = 'modular_oculis/modules/anomalykits/icons/obj/anomalykits.dmi'
	icon_state = "anomalykit"
	modifier = 10
	cost = 0
	maximum_of_type = 1

/obj/item/borg/upgrade/modkit/flux/modify_projectile(obj/projectile/kinetic/K)
	K.damage += modifier
	K.range += modifier / 5

/obj/item/borg/upgrade/modkit/bioscrambler
	name = "genetic inducer"
	desc = "A specialized PK anomaly modkit. This one allows the weapon to genetically batter its opponent, giving it a chance to deal critical internal damage."
	icon = 'modular_oculis/modules/anomalykits/icons/obj/anomalykits.dmi'
	icon_state = "anomalykit"
	modifier = 20
	cost = 35
	maximum_of_type = 1

/obj/item/borg/upgrade/modkit/bioscrambler/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/movable/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	if(istype(target, /mob) && prob(modifier))
		playsound(target, 'sound/items/weapons/zapbang.ogg', 100, TRUE)
		if(target.uses_integrity)
			target.take_damage(60, BRUTE, ENERGY, FALSE)

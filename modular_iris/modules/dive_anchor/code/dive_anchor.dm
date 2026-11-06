GLOBAL_LIST_EMPTY(anchors)

/obj/machinery/dive_anchor
	name = "dive anchor"
	desc = "They've been working on a unified theory."
	icon = 'modular_iris/modules/dive_anchor/icons/dive_anchor.dmi'
	icon_state = "anchor_active"
	density = TRUE
	use_power = NO_POWER_USE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 400
	light_range = 3.5
	///Unique name for this anchor
	var/designation = "Ad Astra"
	///Name of linked anchor
	var/target_designation = "Space Station 13"
	///Original location of this anchor, used in the return home function of the anchor controller
	var/home_location
	///How many times can this anchor move before it needs to be refuelled
	var/fuel_charges = 0

/obj/machinery/dive_anchor/Initialize(mapload)
	. = ..()
	home_location = loc
	if(GLOB.anchors[designation])
		designation += " (duplicate)"
	GLOB.anchors[designation] = src
	AddComponent(/datum/component/gps, "Dive Anchor")
	set_light_on(TRUE)

/obj/machinery/dive_anchor/Destroy(force)
	. = ..()
	GLOB.anchors -= designation

/obj/machinery/dive_anchor/examine(mob/user)
	. = ..()
	. += span_notice("Its designation is <b>[designation]</b>.")
	if(target_designation)
		. += span_notice("The designation of its target anchor is <b>[target_designation]</b>.")

/obj/machinery/dive_anchor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/obj/machinery/dive_anchor/destination_anchor = GLOB.anchors[target_designation]
	if(!destination_anchor)
		audible_message(span_warning("Teleporation prevented: destination anchor unset or undetected!"))
		visible_message(span_warning("A red light blinks on [src]."))
		return
	if(do_after(user, 3.5 SECONDS, src))
		perform_teleportation(destination_anchor.loc)

/obj/machinery/dive_anchor/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(!istype(tool, /obj/item/stack/impure_telecrystal))
		return NONE
	if(istype(src, /obj/machinery/dive_anchor/stationary))
		balloon_alert(user, "[src] lacks a fuel port")
		return ITEM_INTERACT_BLOCKING
	var/obj/item/stack/impure_telecrystal/crystals = tool
	fuel_charges += crystals.amount
	balloon_alert(user, "fueled")
	user.visible_message("[user] fuels [src] with [crystals].")
	qdel(crystals)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/dive_anchor/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	var/obj/item/multitool/multitool = tool
	if(multitool.buffer && istype(multitool.buffer, /obj/machinery/dive_anchor))
		var/obj/machinery/dive_anchor/buffered_anchor = multitool.buffer
		if(target_designation != buffered_anchor.designation && buffered_anchor.designation != designation)
			target_designation = buffered_anchor.designation
			balloon_alert(user, "destination anchor set")
			return ITEM_INTERACT_SUCCESS
	multitool.set_buffer(src)
	balloon_alert(user, "anchor saved to multitool buffer")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/dive_anchor/multitool_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	var/new_designation = tgui_input_text(user, "Rename this anchor to:", "Input Designation", designation, 25)
	if(!new_designation || new_designation == designation)
		return ITEM_INTERACT_BLOCKING
	if(GLOB.anchors[new_designation])
		balloon_alert(user, "anchor name '[new_designation]' already in use")
		return ITEM_INTERACT_BLOCKING
	GLOB.anchors -= designation
	designation = new_designation
	GLOB.anchors[designation] = src
	balloon_alert(user, "new designation set!")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/dive_anchor/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(target_designation && GLOB.anchors[target_designation])
		if(user)
			user.log_message("emagged [src].", LOG_ATTACK, color="red")
			balloon_alert(user, "system overloaded")
		playsound(src, /datum/sound_effect/sparks, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		var/obj/machinery/dive_anchor/target_anchor = GLOB.anchors[target_designation]
		//emagging one anchor zaps mobs in an area around the other
		for(var/mob/living/mob in circle_range(target_anchor, 7))
			target_anchor.Beam(mob, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
			playsound(get_turf(mob), 'sound/effects/magic/lightningshock.ogg', 50, TRUE, -1)
			mob.electrocute_act(80, "electricity arc", flags = SHOCK_NOGLOVES)
		//and breaks the link between the two
		target_anchor.target_designation = null
		target_anchor.visible_message(span_warning("A red light blinks on [target_anchor]."))
		target_designation = null
		visible_message(span_warning("A red light blinks on [src]."))
		return TRUE
	if(user)
		balloon_alert(user, "system overload failed")
	return FALSE

/obj/machinery/dive_anchor/proc/perform_teleportation(target_loc)
	if(!target_loc)
		return

	var/list/safe_landing_turfs = list()
	for(var/turf/open/possible_landing_turf in circle_range_turfs(target_loc, 1))
		if(istype(possible_landing_turf, /turf/open/lava) || istype(possible_landing_turf, /turf/open/chasm))
			continue
		if(!(possible_landing_turf.is_blocked_turf(exclude_mobs = TRUE)))
			safe_landing_turfs += possible_landing_turf

	if(!safe_landing_turfs)
		audible_message(span_warning("Teleportation prevented: all disembarkation angles blocked!"))
		visible_message(span_warning("A red light blinks on [src]."))
		return

	var/datum/effect_system/basic/spark_spread/quantum/quantum_sparks

	var/list/teleportables = list()
	for(var/turf/target_turf in circle_range_turfs(radius = 1))
		teleportables += target_turf.get_all_contents_type(/mob/living)

	for(var/atom/movable/teleportable in teleportables)
		//pre-tp sparks
		quantum_sparks = new(teleportable, rand(4, 8), FALSE)
		quantum_sparks.attach(teleportable)
		quantum_sparks.start()
		//do the tp
		teleportable.forceMove(pick(safe_landing_turfs))
		//knock 'em down if we can, for vibes
		if(iscarbon(teleportable))
			var/mob/living/carbon/teleported_carbon = teleportable
			teleported_carbon.Knockdown(3 SECONDS)
		//post tp sparks
		quantum_sparks.start()

/obj/machinery/dive_anchor/proc/trigger_relocate(target_loc, expend_fuel = TRUE)
	if(!target_loc)
		return

	apply_wibbly_filters(src)
	addtimer(CALLBACK(src, PROC_REF(relocate), target_loc, expend_fuel), 4 SECONDS, TIMER_UNIQUE | TIMER_DELETE_ME)

/obj/machinery/dive_anchor/proc/relocate(target_loc, expend_fuel)
	forceMove(target_loc)
	remove_wibbly_filters(src)

	if(expend_fuel && fuel_charges > 0)
		fuel_charges--

/obj/machinery/dive_anchor/debug
	name = "debug anchor"
	fuel_charges = INFINITY

/obj/machinery/dive_anchor/stationary
	name = "stationary dive anchor"
	icon_state = "anchor_stationary"
	light_range = 0
	designation = "Space Station 13"
	target_designation = "Ad Astra"

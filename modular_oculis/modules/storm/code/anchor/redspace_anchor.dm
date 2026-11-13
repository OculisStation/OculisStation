#define POWER_NOMINAL 0
#define POWER_UP 1
#define POWER_DOWN 2

#define POWER_STATE_OFFLINE 0
#define POWER_STATE_CHARGING 1
#define POWER_STATE_PASSIVE 2
#define POWER_STATE_ACTIVE 3

/obj/machinery/redspace_anchor
	name = "redspace anchor"
	icon = 'modular_oculis/modules/storm/icons/redspace_anchor.dmi'
	icon_state = "anchor_off"
	base_icon_state = "anchor"
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	/*
	* Yes, I know this doesn't use BASE_MACHINE_IDLE_CONSUMPTION at all,
	* and this is purelly done so that the code is readable without pulling out a calculator
	* to make sure these values are right.
	*/
	use_power = NO_POWER_USE
	idle_power_usage = (100 KILO WATTS)
	active_power_usage = (6 MEGA WATTS) // Lotta fucking power to keep the storm at bay.

	// 3x3 offset by one row
	pixel_x = -32
	pixel_y = -32
	bound_height = 96
	bound_width = 96
	bound_x = -32
	bound_y = -32
	density = TRUE
	move_resist = INFINITY

	/// Current state of the redspace anchor.
	var/current_state = POWER_STATE_OFFLINE
	/// If the main breaker is on/off, to enable/disable the anchor.
	var/breaker = TRUE
	/// If the power cable is cut or not.
	var/shorted = FALSE
	/// If a silicon can interact with it.
	var/ai_disabled = FALSE
	/// If the anchor will produce an alarm when changing states.
	var/alarm_disabled = FALSE
	/// If the anchor can safely discharge its redspace energy.
	var/can_discharge = TRUE
	/// If the generator is charging, or down.
	var/charging_state = POWER_UP
	/// How much charge the redspace anchor has, goes down when breaker is shut, and shuts down at 0.
	var/charge_count = 100
	/// How much excess violetspace energy the redspace anchor has, which can cause it to fail once it reaches 100.
	var/violetspace_energy = 0

	/// Audio for when the redspace anchor is on
	var/datum/looping_sound/redspace_anchor/soundloop


/obj/machinery/redspace_anchor/Initialize(mapload)
	. = ..()
	SSeidolon_storm.register_anchor(src)
	SSeidolon_storm.redspace_anchors += src
	set_wires(new /datum/wires/redspace_anchor(src))
	soundloop = new(src, start_immediately = FALSE)
	update_appearance()

/obj/machinery/redspace_anchor/Destroy(force)
	QDEL_NULL(soundloop)
	SSeidolon_storm.redspace_anchors -= src
	return ..()

/obj/machinery/redspace_anchor/examine(mob/user)
	if(HAS_TRAIT(user, TRAIT_MINDSHIELD))
		desc = "The most important machine on the station. You feel more... Stable, near it."
		return ..()
	desc = "The most important machine on the station. \n[span_danger("Looking directly at it gives you a headache.")]"
	return ..()

/obj/machinery/redspace_anchor/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE)
	return FALSE

/obj/machinery/redspace_anchor/ex_act(severity, target)
	if(severity >= EXPLODE_DEVASTATE) // Very sturdy.
		set_broken()
		return TRUE
	return FALSE

/obj/machinery/redspace_anchor/blob_act(obj/structure/blob/B)
	if(prob(20))
		set_broken()

/obj/machinery/redspace_anchor/zap_act(power, zap_flags)
	. = ..()
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		atom_break()

// You aren't allowed to move.
/obj/machinery/redspace_anchor/Move()
	. = ..()
	qdel(src)

/obj/machinery/redspace_anchor/proc/set_broken()
	atom_break()
	update_appearance()

/obj/machinery/redspace_anchor/proc/set_fix()
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()

/obj/machinery/redspace_anchor/update_icon_state()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "[base_icon_state]_broken"
		return

	switch(current_state)
		if(POWER_STATE_ACTIVE)
			icon_state = "[base_icon_state]_on"
		if(POWER_STATE_PASSIVE)
			icon_state = "[base_icon_state]_standby"
		else
			icon_state = "[base_icon_state]_off"

/obj/machinery/redspace_anchor/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	switch(current_state)
		if(POWER_STATE_ACTIVE) // Are we activated or on standby?
			. += emissive_appearance(icon, "emissive_on", src)
		if(POWER_STATE_PASSIVE)
			. += emissive_appearance(icon, "emissive_standby", src)

/obj/machinery/redspace_anchor/screwdriver_act(mob/living/user, obj/item/tool)
	if(machine_stat & BROKEN)
		return
	tool.play_tool_sound(src)
	toggle_panel_open()
	to_chat(user, span_notice("The wires have been [panel_open ? "exposed" : "unexposed"]."))
	update_appearance()
	return TRUE

// Wire interactions
/obj/machinery/redspace_anchor/proc/reset(wire)
	switch(wire)
		if(WIRE_POWER)
			if(!wires.is_cut(WIRE_POWER))
				shorted = FALSE
			set_power()
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				ai_disabled = FALSE
		if(WIRE_ALARM)
			if(!wires.is_cut(WIRE_ALARM))
				alarm_disabled = FALSE
		if(WIRE_DISCHARGE)
			update_appearance()

/obj/machinery/redspace_anchor/power_change()
	. = ..()
	if(SSticker.current_state == GAME_STATE_PLAYING)
		investigate_log("has [machine_stat & NOPOWER ? "lost" : "regained"] power.", INVESTIGATE_ENGINE)
	set_power()

// Set the charging state based on power/breaker.
/obj/machinery/redspace_anchor/proc/set_power()
	var/new_state = FALSE
	if(machine_stat & (NOPOWER|BROKEN) || !breaker || shorted)
		new_state = FALSE
	else if(breaker)
		new_state = TRUE

	charging_state = new_state ? POWER_UP : POWER_DOWN // Startup sequence animation.
	use_power = new_state ? active_power_usage : NO_POWER_USE
	if(SSticker.current_state == GAME_STATE_PLAYING)
		investigate_log("is now [charging_state == POWER_UP ? "charging" : "discharging"].", INVESTIGATE_ENGINE)
	update_appearance()
	START_PROCESSING(SSprocessing, src)

/obj/machinery/redspace_anchor/proc/enable()
	use_power = idle_power_usage
	current_state = POWER_STATE_PASSIVE
	charging_state = POWER_NOMINAL

	//soundloop.start()
	update_appearance()

	if(SSticker.current_state == GAME_STATE_PLAYING)
		investigate_log("was brought online.", INVESTIGATE_ENGINE)
		message_admins("The redspace anchor was brought online [ADMIN_VERBOSEJMP(src)]")
	shake_everyone()
	STOP_PROCESSING(SSprocessing, src)

/obj/machinery/redspace_anchor/proc/disable()
	use_power = NO_POWER_USE
	current_state = POWER_STATE_OFFLINE
	charging_state = POWER_NOMINAL

	//soundloop.stop()
	update_appearance()

	if(SSticker.current_state == GAME_STATE_PLAYING)
		investigate_log("was brought offline.", INVESTIGATE_ENGINE)
		message_admins("The redspace anchor was brought offline. [ADMIN_VERBOSEJMP(src)]")
	shake_everyone()
	STOP_PROCESSING(SSprocessing, src)

// Charge/Discharge and turn on/off when you reach 0/100 percent.
/obj/machinery/redspace_anchor/process()
	if(machine_stat & BROKEN)
		return
	if(charging_state == POWER_NOMINAL)
		STOP_PROCESSING(SSprocessing, src)
		return
	if((charging_state == POWER_UP) && (charge_count >= 100))
		enable()
	else if((charging_state == POWER_DOWN) && (charge_count <= 0))
		disable()
	else
		if(charging_state == POWER_UP)
			charge_count += 2
		else if(charging_state == POWER_DOWN)
			charge_count -= 2

		for(var/mob/mobs as anything in GLOB.mob_list)
			var/turf/mob_turf = get_turf(mobs)
			if(!istype(mob_turf))
				continue
			if(!is_valid_z_level(src, mob_turf))
				continue
			if(mobs.client)
				if((charge_count % 4 == 0 && prob(75)) && !alarm_disabled) // Let them know it is charging/discharging.
					if(charging_state == POWER_UP)
						mobs.playsound_local(mob_turf, 'sound/effects/magic/cosmic_expansion.ogg', 100, TRUE)
					else
						mobs.playsound_local(mob_turf, 'sound/effects/magic/swap.ogg', 100, TRUE)
				if((charge_count <= 50) && (charging_state == POWER_DOWN) && prob(5))
					to_chat(mobs, span_bolddanger("You feel a foreign presence encroaching around you."))

/// Shake everyone on the z level to let them know that the anchor was turned on into standby mode or off.
/obj/machinery/redspace_anchor/proc/shake_everyone()
	var/turf/T = get_turf(src)
	var/sound/alert_sound = sound('sound/effects/alert.ogg')
	for(var/mob/mobs as anything in GLOB.mob_list)
		var/turf/mob_turf = get_turf(mobs)
		if(!istype(mob_turf))
			continue
		if(!is_valid_z_level(T, mob_turf))
			continue
		if(mobs.client)
			shake_camera(mobs, 15, 1)
			mobs.playsound_local(T, null, 100, 1, 0.5, sound_to_use = alert_sound)
	if(!SSmapping.level_has_any_trait(z, ZTRAIT_STATION))
		return
	switch(current_state)
		if(POWER_STATE_ACTIVE)
			priority_announce("Redspace Anchor activated during ongoing storm.", "Redspace Anchor", color_override = "purple")
		if(POWER_STATE_PASSIVE)
			priority_announce("Redspace Anchor enabled and awaiting activation codes.", "Redspace Anchor", color_override = "green")
		if(POWER_STATE_OFFLINE)
			priority_announce("Warning: Redspace Anchor has been disabled.", "Redspace Anchor", color_override = "red")

/// Throw everyone on the z level to let them know that the anchor was activated/deactivated. Used when it enters active mode.
/obj/machinery/redspace_anchor/proc/throw_everyone()


/obj/machinery/redspace_anchor/proc/tick(intensity)
	switch(current_state)
		if(POWER_STATE_OFFLINE)
			return FALSE
		if(POWER_STATE_CHARGING)
			use_energy(active_power_usage)
			return FALSE
		if(POWER_STATE_PASSIVE) // WTF what are we doing ticking if we aren't activated? Fuck fuck fuck power ourselves up already!
			activate()
		if(POWER_STATE_ACTIVE)
			violetspace_energy += (rand(1,5) * intensity)
			if(violetspace_energy >= 100)
				trigger_unsafe_discharge()

/obj/machinery/redspace_anchor/proc/trigger_unsafe_discharge()
	violetspace_energy = 0
	breaker = FALSE
	set_power()
	priority_announce(
		text = "Redspace Anchor failure! Unsafe shutdown in progress!",
		title = "Redspace Anchor",
		sound = SSstation.announcer.get_rand_alert_sound(),
		has_important_message = TRUE,
	)
	SSevents.spawnEvent()

/obj/machinery/redspace_anchor/proc/trigger_safe_discharge()
	violetspace_energy = 0
	priority_announce(
		text = "Redspace Anchor safe discharge in progress.",
		title = "Redspace Anchor",
		sound = SSstation.announcer.get_rand_alert_sound(),
		has_important_message = TRUE,
	)
	SSevents.spawnEvent()

// For the start of a storm.
/obj/machinery/redspace_anchor/proc/activate()
	current_state = POWER_STATE_ACTIVE
	throw_everyone()
	update_appearance()

// For after a storm.
/obj/machinery/redspace_anchor/proc/deactivate()
	current_state = POWER_STATE_PASSIVE
	throw_everyone()
	update_appearance()

#undef POWER_UP
#undef POWER_DOWN
#undef POWER_STATE_OFFLINE
#undef POWER_STATE_CHARGING
#undef POWER_STATE_PASSIVE
#undef POWER_STATE_ACTIVE

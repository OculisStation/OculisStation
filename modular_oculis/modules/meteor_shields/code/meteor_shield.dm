GLOBAL_VAR_INIT(total_meteors_zapped, 0)

/obj/machinery/satellite/meteor_shield
	name = "meteor defense satellite"
	icon = 'modular_oculis/modules/meteor_shields/icons/satellite.dmi'
	icon_state = "meteor_sat"
	base_icon_state = "meteor_sat"
	mode = "HK-MPS"
	kill_range = 16
	/// Whether the meteor sat checks for line of sight to determine if it can intercept a meteor.
	var/check_sight = TRUE
	/// The proximity monitor used to detect meteors entering the shield's range.
	var/datum/proximity_monitor/advanced/meteor_shield/monitor
	/// A counter for how many meteors this specific satellite has zapped.
	var/meteors_zapped = 0
	/// An alist of "proxy" objects used for multi-z coverage.
	/// [z] = proxy
	var/alist/proxies = alist()

/obj/machinery/satellite/meteor_shield/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, /obj/item/meteor_shield_capsule, 2 SECONDS)

	RegisterSignal(src, COMSIG_MOVABLE_SPACEMOVE, PROC_REF(on_space_move)) // so these fuckers don't drift off into space when you're trying to position them
	setup_proximity()
	setup_proxies()
	register_context()

/obj/machinery/satellite/meteor_shield/Destroy()
	// close any meteor sat previews we might have open
	for(var/mob/living/nearby in orange(1, src))
		close_meteor_sat_preview_for(nearby, src)
		UnregisterSignal(nearby, COMSIG_MOVABLE_MOVED)
	QDEL_NULL(monitor)
	proxies.Cut()
	return ..()

/obj/machinery/satellite/meteor_shield/examine(mob/user)
	. = ..()
	. += span_notice("[EXAMINE_HINT("Right-click")] the satellite with a [EXAMINE_HINT("multitool")] to see a preview of its coverage.")
	. += span_info("It has stopped <b>[meteors_zapped]</b> meteors so far.")
	. += span_info("Overall, all meteor defense satellites have stopped a combined <b>[GLOB.total_meteors_zapped]</b> meteors this shift.")

/obj/machinery/satellite/meteor_shield/update_icon_state()
	. = ..() // call parent first so we can override the usual satellite icon state suffix shit
	icon_state = base_icon_state

/obj/machinery/satellite/meteor_shield/update_overlays()
	. = ..()
	if(active)
		if(obj_flags & EMAGGED)
			. += "[base_icon_state]_hacked"
			. += emissive_appearance(icon, "[base_icon_state]_hacked_e", src)
		else
			. += "meteor_sat_active"
			. += emissive_appearance(icon, "[base_icon_state]_active_e", src)

/obj/machinery/satellite/meteor_shield/proc/on_space_move(datum/source)
	SIGNAL_HANDLER
	return COMSIG_MOVABLE_STOP_SPACEMOVE

/obj/machinery/satellite/meteor_shield/vv_edit_var(vname, vval)
	. = ..()
	if(.)
		switch(vname)
			if(NAMEOF(src, kill_range))
				monitor?.set_range(kill_range)
				for(var/proxy_z, proxy in proxies)
					var/obj/effect/abstract/meteor_shield_proxy/proxy_object = proxy
					proxy_object.monitor.set_range(kill_range)
			if(NAMEOF(src, active))
				set_anchored(active)
				setup_proximity()

/obj/machinery/satellite/meteor_shield/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_LMB] = active ? "Deactivate" : "Activate"
	if(held_item?.tool_behaviour == TOOL_MULTITOOL)
		context[SCREENTIP_CONTEXT_RMB] = "Toggle coverage preview"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/satellite/meteor_shield/toggle(mob/user)
	. = ..()
	if(.)
		user.log_message("[active ? "" : "de"]activated [src] at [AREACOORD(src)]", LOG_GAME)
	setup_proximity()

/obj/machinery/satellite/meteor_shield/multitool_act_secondary(mob/living/user, obj/item/tool)
	if(toggle_meteor_sat_preview_for(user, src))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_coverage_viewer_moved))
	else
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/satellite/meteor_shield/proc/on_coverage_viewer_moved(mob/living/mover)
	SIGNAL_HANDLER
	if(!mover.Adjacent(src))
		close_meteor_sat_preview_for(mover, src)
		UnregisterSignal(mover, COMSIG_MOVABLE_MOVED)

/obj/machinery/satellite/meteor_shield/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	user.log_message("emagged [src] at [AREACOORD(src)]", LOG_GAME)
	setup_proximity()
	update_appearance()

/obj/machinery/satellite/meteor_shield/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	setup_proxies()

/obj/machinery/satellite/meteor_shield/proc/setup_proximity()
	if(QDELETED(src))
		return
	if((obj_flags & EMAGGED) || !active)
		QDEL_NULL(monitor)
	else if(QDELETED(monitor))
		monitor = new(src, kill_range)

/obj/machinery/satellite/meteor_shield/proc/setup_proxies()
	if(QDELETED(src))
		return
	for(var/stacked_z in SSmapping.get_connected_levels(get_turf(src)))
		setup_proxy_for_z(stacked_z)

/obj/machinery/satellite/meteor_shield/proc/setup_proxy_for_z(target_z)
	if(target_z == z)
		return
	// don't setup a proxy if there already is one.
	if(proxies[target_z])
		return
	var/turf/our_loc = get_turf(src)
	var/turf/target_loc = locate(our_loc.x, our_loc.y, target_z)
	if(isnull(target_loc))
		return
	var/obj/effect/abstract/meteor_shield_proxy/new_proxy = new(target_loc, src)
	proxies[target_z] = new_proxy

/obj/machinery/satellite/meteor_shield/proc/get_covered_turfs(target_z)
	. = list()
	var/turf/our_turf = get_turf(src)
	if(isnull(target_z) || target_z == our_turf.z)
		var/list/nearby_turfs = RANGE_TURFS(kill_range, our_turf)
		// fun trick to avoid an implicit copy :3
		for(var/idx = 1 to length(nearby_turfs))
			var/turf/turf = nearby_turfs[idx]
			if(check_los(our_turf, turf))
				. += turf
	if(target_z == our_turf.z) // we only wanted our own z-level, dont check proxies at all
		return
	for(var/z, value in proxies)
		if(!isnull(target_z) && z != target_z)
			continue
		var/obj/effect/abstract/meteor_shield_proxy/proxy = value
		var/turf/proxy_turf = get_turf(proxy)
		var/list/nearby_turfs = RANGE_TURFS(kill_range, proxy_turf)
		for(var/idx = 1 to length(nearby_turfs))
			var/turf/turf = nearby_turfs[idx]
			if(check_los(proxy_turf, turf))
				. += turf

/obj/machinery/satellite/meteor_shield/piercing
	check_sight = FALSE

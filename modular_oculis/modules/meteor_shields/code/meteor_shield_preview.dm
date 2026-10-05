#define TURF_NEWLY_COVERED (1 << 0)
#define TURF_ALREADY_COVERED (1 << 1)
#define TURF_OBSCURED (1 << 2)
#define TURF_SOLID (1 << 3)
#define TURF_OTHER_SAT (1 << 4)
#define PREVIEW_SCALE 3

/atom/movable/screen/meteor_sat_turf_preview
	icon_state = ""
	layer = MINIMAP_IMAGE_LAYER
	screen_loc = "CENTER-1.5,CENTER-1.5"
	alpha = 196
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/datum/weakref/source_weakref
	var/turf/center
	var/view_range

	var/alist/turf_coverage = alist()

/atom/movable/screen/meteor_sat_turf_preview/Initialize(mapload, datum/hud/hud_owner, atom/source, view_range)
	..()
	if(!isatom(source) || QDELING(source))
		. = INITIALIZE_HINT_QDEL
		CRASH("Tried to create [type] with an invalid source!")
	src.source_weakref = WEAKREF(source)
	src.center = get_turf(source)
	src.view_range = isnum(view_range) ? view_range : /obj/machinery/satellite/meteor_shield::kill_range
	return INITIALIZE_HINT_LATELOAD

/atom/movable/screen/meteor_sat_turf_preview/LateInitialize()
	get_preview_turfs()
	generate_appearance()
	addtimer(CALLBACK(src, PROC_REF(safety_close)), 5 MINUTES) // safety timer to ensure we self-close after 5 minutes, in case something breaks

/atom/movable/screen/meteor_sat_turf_preview/Destroy(force)
	source_weakref = null
	center = null
	turf_coverage.Cut()
	return ..()

/atom/movable/screen/meteor_sat_turf_preview/proc/safety_close()
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	var/mob/our_mob = get_mob()
	if(our_mob)
		our_mob.balloon_alert(our_mob, "automatically closed coverage preview")
	hud.remove_screen_object(src, update = TRUE)

/atom/movable/screen/meteor_sat_turf_preview/proc/get_preview_turfs()
	turf_coverage.Cut()

	var/scaled_view_range = round(max(/obj/machinery/satellite/meteor_shield::kill_range, view_range) * 1.5, 1)
	for(var/obj/machinery/satellite/meteor_shield/sat as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/satellite/meteor_shield))
		if(!sat.active || (sat.obj_flags & EMAGGED) || IS_WEAKREF_OF(sat, source_weakref))
			continue
		var/turf/sat_turf = get_turf(sat)
		if(sat_turf.z != center.z)
			var/obj/effect/abstract/meteor_shield_proxy/proxy = sat.proxies[center.z]
			if(proxy)
				sat_turf = get_turf(proxy)
			else
				continue
		if(get_dist(center, sat_turf) > max(round(sat.kill_range * 1.5, 1), scaled_view_range))
			continue
		for(var/turf/turf as anything in sat.get_covered_turfs(sat_turf.z))
			turf_coverage[turf] = TURF_ALREADY_COVERED
		turf_coverage[sat_turf] = TURF_OTHER_SAT

	var/min_x = center.x - view_range
	var/min_y = center.y - view_range
	var/max_x = center.x + view_range
	var/max_y = center.y + view_range
	turf_loop:
		for(var/turf/turf as anything in RANGE_TURFS(scaled_view_range, center))
			if(turf.opacity)
				turf_coverage[turf] = TURF_SOLID
				continue
			// performance cheat lol - there's prolly not gonna be doors and shit on open turfs, so don't check those.
			if(!isgroundlessturf(turf))
				for(var/atom/movable/thing in turf)
					if(thing.opacity)
						turf_coverage[turf] = TURF_SOLID
						continue turf_loop
			if(!has_view_line(center, turf))
				turf_coverage[turf] |= TURF_OBSCURED
			else if(!(turf_coverage[turf] & TURF_SOLID) && ISINRANGE(turf.x, min_x, max_x) && ISINRANGE(turf.y, min_y, max_y))
				turf_coverage[turf] |= TURF_NEWLY_COVERED

/atom/movable/screen/meteor_sat_turf_preview/proc/generate_appearance()
	var/icon/new_icon = icon('icons/ui_icons/minimap/minimap.dmi')

	var/min_x = world.maxx
	var/min_y = world.maxy
	var/max_x = 1
	var/max_y = 1

#ifdef SPACEMAN_DMM // stupid workaround for dreamchecker/sdmm issue
	for(var/k, turf_flags in turf_coverage)
		var/turf/turf = k
#else
	for(var/turf/turf as anything, turf_flags in turf_coverage)
#endif
		var/color
		if(turf == center)
			color = "#F2B33D"
		else if(turf_flags & TURF_OTHER_SAT)
			color = "#8A6A2A"
		else if(turf_flags & TURF_SOLID)
			color = "#37475A"
		else if(turf_flags & TURF_OBSCURED)
			if(turf_flags & TURF_ALREADY_COVERED) // i could not for the life of me get `if((turf_flags & (TURF_OBSCURED|TURF_ALREADY_COVERED)) == (TURF_OBSCURED|TURF_ALREADY_COVERED))` to fucking work
				color = "#5D313C"
			else
				color = "#5E2F39"
		else if(turf_flags & TURF_NEWLY_COVERED)
			if(turf_flags & TURF_ALREADY_COVERED)
				color = "#3FA9DE"
			else
				color = "#5CE08A"
		else if(turf_flags & TURF_ALREADY_COVERED)
			color = "#10212D"
		if(isnull(color))
			continue
		new_icon.DrawBox(color, turf.x, turf.y)
		min_x = min(min_x, turf.x)
		min_y = min(min_y, turf.y)
		max_x = max(max_x, turf.x)
		max_y = max(max_y, turf.y)

	// bullshit to ensure it always scales in a way where it can be centered
	var/x_radius = max(center.x - min_x, max_x - center.x)
	var/y_radius = max(center.y - min_y, max_y - center.y)
	min_x = center.x - x_radius
	min_y = center.y - y_radius
	max_x = center.x + x_radius + 1
	max_y = center.y + y_radius + 1
	new_icon.Crop(min_x, min_y, max_x, max_y)

	var/final_w = new_icon.Width() * PREVIEW_SCALE
	var/final_h = new_icon.Height() * PREVIEW_SCALE
	new_icon.Scale(final_w, final_h)

	// funky little border
	new_icon.DrawBox("#F2B33D", 1, 1, final_w, 1) // bottom border (if i dont comment these i will lose track lmao)
	new_icon.DrawBox("#F2B33D", 1, final_h, final_w, final_h) // top
	new_icon.DrawBox("#F2B33D", 1, 1, 1, final_h) // left
	new_icon.DrawBox("#F2B33D", final_w, 1, final_w, final_h) // right

	icon = new_icon

	var/screen_x_offset = round((ICON_SIZE_X - PREVIEW_SCALE) / 2) - (center.x - min_x) * PREVIEW_SCALE
	var/screen_y_offset = round((ICON_SIZE_Y - PREVIEW_SCALE) / 2) - (center.y - min_y) * PREVIEW_SCALE
	screen_loc = "CENTER:[screen_x_offset],CENTER:[screen_y_offset]"

/proc/open_meteor_sat_preview_for(mob/user, atom/source)
	if(QDELETED(source))
		return
	var/datum/hud/user_hud = user.hud_used
	if(!user_hud)
		return
	var/atom/movable/screen/meteor_sat_turf_preview/preview = user_hud.screen_objects[HUD_METEOR_SHIELD_PREVIEW]
	if(preview)
		if(IS_WEAKREF_OF(source, preview.source_weakref)) // we already have a preview
			return
		else
			user_hud.remove_screen_object(preview, update = FALSE)
	var/atom/movable/screen/meteor_sat_turf_preview/new_preview = new(null, user_hud, source)
	user_hud.add_screen_object(new_preview, HUD_METEOR_SHIELD_PREVIEW, update_screen = TRUE)
	user.balloon_alert(user, "opened coverage preview")

// if source is null, it just closes the preview regardless of source
/proc/close_meteor_sat_preview_for(mob/user, atom/source = null)
	var/datum/hud/user_hud = user.hud_used
	var/atom/movable/screen/meteor_sat_turf_preview/preview = user_hud?.screen_objects[HUD_METEOR_SHIELD_PREVIEW]
	if(!preview)
		return
	if(isnull(source) || IS_WEAKREF_OF(source, preview.source_weakref))
		user_hud.remove_screen_object(preview)
		user.balloon_alert(user, "closed coverage preview")

// returns true if it was opened, false otherwise
/proc/toggle_meteor_sat_preview_for(mob/user, atom/source)
	. = FALSE
	if(QDELETED(source))
		return
	var/datum/hud/user_hud = user.hud_used
	if(!user_hud)
		return
	var/atom/movable/screen/meteor_sat_turf_preview/preview = user_hud.screen_objects[HUD_METEOR_SHIELD_PREVIEW]
	if(preview)
		if(IS_WEAKREF_OF(source, preview.source_weakref))
			user_hud.remove_screen_object(preview)
			user.balloon_alert(user, "closed coverage preview")
			return
		user_hud.remove_screen_object(preview, update = FALSE)
	var/atom/movable/screen/meteor_sat_turf_preview/new_preview = new(null, user_hud, source)
	user_hud.add_screen_object(new_preview, HUD_METEOR_SHIELD_PREVIEW, update_screen = TRUE)
	user.balloon_alert(user, "opened coverage preview")
	return TRUE

#undef PREVIEW_SCALE
#undef TURF_OTHER_SAT
#undef TURF_SOLID
#undef TURF_OBSCURED
#undef TURF_ALREADY_COVERED
#undef TURF_NEWLY_COVERED

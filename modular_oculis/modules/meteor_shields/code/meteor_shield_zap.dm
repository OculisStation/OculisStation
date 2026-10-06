/obj/machinery/satellite/meteor_shield/proc/meteor_act(obj/effect/meteor/meteor)
	if(!active || !istype(meteor) || QDELING(meteor) || (obj_flags & EMAGGED))
		return
	var/turf/our_turf = get_turf(src)
	var/turf/meteor_turf = get_turf(meteor)
	if(!check_los(our_turf, meteor_turf))
		return
	our_turf.Beam(meteor_turf, icon_state = "sat_beam", time = 0.5 SECONDS)
	if(meteor.shield_defense(src))
		new /obj/effect/temp_visual/explosion(meteor_turf)
		SSblackbox.record_feedback("tally", "meteors_zapped", 1, "[meteor.type]")
		meteors_zapped++
		GLOB.total_meteors_zapped++
		// alright time for a god-awful hack
		// some meteors use spawner effects rather than directly spawning
		// and there's not really any "clean" way to get specifically what it spawns from what I know
		// so let's just... compare the adjacent turfs before and after.
		var/nudge_angle
		if(meteor.dest) // if the meteor has a set destination, we'll use that
			nudge_angle = get_angle(meteor_turf, get_turf(meteor.dest))
		else
			// alright we're just gonna go towards the center, prolly good enough
			var/turf/center = locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), meteor.z)
			nudge_angle = get_angle(meteor_turf, center)
		var/list/nearby = range(1, meteor_turf)
		meteor.make_debris()
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(meteor_debris_drift), nearby, meteor_turf, nudge_angle), 0.5 SECONDS)
		qdel(meteor)

/obj/machinery/satellite/meteor_shield/proc/check_los(turf/source, turf/target) as num
	return !check_sight || has_view_line(source, target)

/proc/has_view_line(turf/source, turf/target)
	// if something goes fucky wucky, let's just assume line-of-sight by default
	. = TRUE
	for(var/turf/segment as anything in get_line(source, target))
		if(segment.opacity)
			return FALSE
		// performance cheat lol - there's prolly not gonna be doors and shit on open turfs, so don't check those.
		if(!isgroundlessturf(segment))
			for(var/atom/movable/thing in segment)
				if(thing.opacity)
					return FALSE

/proc/meteor_debris_drift(list/nearby, turf/center, nudge_angle)
	nearby ^= range(1, center)
	for(var/atom/movable/debris in nearby)
		if(QDELING(debris) || debris.anchored)
			continue
		debris.newtonian_move(nudge_angle, instant = TRUE)

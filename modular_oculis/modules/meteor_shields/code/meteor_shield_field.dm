/// A proximity monitor field that marks openspace turfs within as being covered by a meteor shield.
/datum/proximity_monitor/advanced/meteor_shield
	edge_is_a_field = TRUE
	var/obj/machinery/satellite/meteor_shield/true_host

/datum/proximity_monitor/advanced/meteor_shield/New(atom/_host, range, _ignore_if_not_on_turf, obj/machinery/satellite/meteor_shield/proxied_host)
	true_host = proxied_host || _host
	return ..()

/datum/proximity_monitor/advanced/meteor_shield/Destroy()
	true_host = null
	return ..()

/datum/proximity_monitor/advanced/meteor_shield/set_range(range, force_rebuild)
	. = ..()
	if(.)
		recalculate_field(full_recalc = TRUE)

/datum/proximity_monitor/advanced/meteor_shield/field_turf_crossed(atom/movable/thingymajig, turf/old_location, turf/new_location)
	true_host.meteor_act(thingymajig)

/datum/proximity_monitor/advanced/meteor_shield/field_turf_uncrossed(atom/movable/thingymajig, turf/old_location, turf/new_location)
	true_host.meteor_act(thingymajig)

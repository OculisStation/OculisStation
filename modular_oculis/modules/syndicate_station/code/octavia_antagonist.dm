
/datum/antagonist/octavia

/datum/antagonist/octavia/proc/spawn_rubicon()
	var/datum/map_template/shuttle/rubicon/ship = SSmapping.shuttle_templates["rubicon"]
	var/x = (world.maxx - TRANSITIONEDGE - ship.width)
	var/y = (world.maxy - TRANSITIONEDGE - ship.height)
	var/z
	if(SSmapping.empty_space)
		z = SSmapping.empty_space.z_value
	else
		for(var/datum/space_level/z_level as anything in SSmapping.z_list)
			if(z_level.traits.Find(ZTRAIT_RESERVED))
				z = z_level.z_value
				break

	var/turf/turf = locate(x,y,z)

	if(!turf)
		CRASH("Rubicon found no turf to load in")

	if(!ship.load(turf))
		CRASH("Rubicon has failed to load!")

	var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle("rubicon")
	mobile_port.destination = SSshuttle.getDock("octavia_away")
	mobile_port.mode = SHUTTLE_IGNITING
	mobile_port.setTimer(mobile_port.ignitionTime)

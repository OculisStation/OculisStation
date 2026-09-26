/* Candela Drone

Basic behavior-tree-controlled mob used in the candela emergency retrieval MOD module (`/obj/item/mod/module/candela_retrieval`)

*/
/mob/living/basic/pet/candela_drone
	mob_size = MOB_SIZE_TINY
	var/tethering_beacon = null // where are we pulling to
	var/candela_network = null // what network is the `tethering_beacon` in
	var/destination_beacon = null // where are we navigating along the `candela_network` to


/mob/living/basic/pet/candela_drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_PACIFISM)
	AddComponent(/datum/component/simple_access, SSid_access.get_region_access_list(list(REGION_ALL_GLOBAL))) // all access so they can get miners out of almost anywhere


/mob/living/basic/pet/candela_drone/rescue()



/mob/living/basic/pet/candela_drone/proc/pop_out()
	// Pop out [animation] (the whimsy...)

	// Pull out the radio [animation]

	// Broadcast the radio message (MEDICALLLL you have a Patient)

	// Mumble in a silly voice

	// Put away the radio [animation]

	// Look around [animation] (*squints "hmmmmmmm..")

	// Next!

/mob/living/basic/pet/candela_drone/proc/find_closest_network()
	// Pull out the hardlight rope

	// Hook one end to the MODsuit [animation]

	// Pull out the candela network tracker (ping!)

	// Navigate to the nearest beacon (weeee)


/mob/living/basic/pet/candela_drone/proc/attach_tether()
	// Attach the other end of the tether to the beacon

	// Give a thumbs up

	// Pull the MODsuit & user to the beacon

	// Wait

/mob/living/basic/pet/candela_drone/proc/navigate_to_end()
	// Jump onto the corpse and ride it (zoooooom)

	// Pull the corpse along the network towards the end

	// Wait

/mob/living/basic/pet/candela_drone/proc/drop_off()
	// Clap when they arrive

	// Pop back into the MODsuit

	// Delete the mob (bye little drone!)


// Runs if the MOD was depowered during retrieval
/mob/living/basic/pet/candela_drone/proc/mod_powered_off()
	emote("question") // bwuh..?
	// Burrow into ground [animation]

	// Delete mob (womp-womp...)

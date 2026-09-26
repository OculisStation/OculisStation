/obj/item/mod/module/candela_retrieval
	// yes i Know i could have just made it use a fulton or something but its WAY more fun to watch silly drone save you
	name = "\improper MOD \"Candela\" emergency retrieval module"
	desc = "An incredibly efficient pulley system that, when detecting the user has fallen into critical condition, first notifies Medical radio of it's user's . Regardless of range, this device can extend, find and attach to the nearest candela network. The high-speed pulley system then pulls the user towards the network and navigates along said network until it finds it's origin point."
	icon_state = "" // REPLACE WHEN I SPRITE IT !!!!!!!!!
	module_type = MODULE_PASSIVE // hmm i dont want it draining...
	use_energy_cost = DEFAULT_CHARGE_DRAIN / 10 // i guess?? we only want it using power when it's actually in use, and even then it Probably doesn't matter
	incompatible_modules = list(/obj/item/mod/module/candela_retrieval)
	cooldown_time = 1 SECONDS
	required_slots = list(ITEM_SLOT_BACK)
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.75)
	complexity = 3

	// The drone mob that tethers you to the nearest network
	var/mob/living/basic/pet/candela_drone/drone_savior = null // little guy! :D
	var/tethering_beacon = null // where are we pulling to
	var/candela_network = null // what network is the `tethering_beacon` in
	var/destination_beacon = null // where are we navigating along the `candela_network` to




/obj/item/mod/module/propulsion

	name = "\improper MOD \"Candela\" propulsion module"
	desc = "A set of tethers and connectors, capable of automatically deploying \"Candela\" beacons from within a MODsuit."
	icon_state = "" // REPLACE WHEN I SPRITE IT !!!!!!!!!
	module_type = MODULE_TOGGLE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 4 // Not meant to be used outside of mining, tethers should charge enough
	incompatible_modules = list(/obj/item/mod/module/propulsion, /obj/item/mod/module/ash_accretion)
	cooldown_time = 1 SECONDS
	required_slots = list(ITEM_SLOT_FEET)
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.75)
	complexity = 2

	var/speed_added = -0.50 // Add this when

/obj/item/mod/module/magboot/on_install()
	. = ..()
	RegisterSignal(mod, COMSIG_MOD_UPDATE_SPEED, PROC_REF(on_update_speed))

/obj/item/mod/module/magboot/on_uninstall(deleting = FALSE)
	. = ..()
	UnregisterSignal(mod, COMSIG_MOD_UPDATE_SPEED)

/obj/item/mod/module/magboot/proc/on_update_speed(datum/source, list/module_slowdowns, prevent_slowdown)
	SIGNAL_HANDLER
	if (!prevent_slowdown && active)
		module_slowdowns += speed_added

/obj/machinery/smartfridge/extract/accept_check(obj/item/weapon)
	return ..() || istype(weapon, /obj/item/slime_rancher_scanner)

/obj/machinery/smartfridge/extract/preloaded
	initial_contents = list(/obj/item/slime_rancher_scanner = 2)

// SLIME_RANCHER - vacuum packs dump into it, and anything it takes can be thrown in
/obj/machinery/smartfridge/extract/proc/can_take(obj/item/thing)
	return !machine_stat && accept_check(thing) && length(contents - component_parts) < max_n_of_items

/obj/machinery/smartfridge/extract/proc/take(obj/item/thing)
	if(!can_take(thing) || !load(thing))
		return FALSE
	SStgui.update_uis(src)
	if(visible_contents)
		update_appearance()
	return TRUE

/obj/machinery/smartfridge/extract/hitby(atom/movable/hitting_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isitem(hitting_atom) && take(hitting_atom))
		playsound(src, 'sound/items/vacuum/vacuum_ploop.ogg', vol = 40, vary = TRUE)
		return
	return ..()

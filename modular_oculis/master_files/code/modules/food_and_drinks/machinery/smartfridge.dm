/obj/machinery/smartfridge/extract/accept_check(obj/item/weapon)
	return ..() || istype(weapon, /obj/item/slime_rancher_scanner)

/obj/machinery/smartfridge/extract/preloaded
	initial_contents = list(/obj/item/slime_rancher_scanner = 2)

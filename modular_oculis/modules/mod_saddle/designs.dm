/datum/design/module/mod_riding_saddle
	name = "Riding Saddle Module"
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT *1.25,
		/datum/material/glass =SMALL_MATERIAL_AMOUNT*5,
	)
	build_path = /obj/item/mod/module/saddle

/datum/techweb_node/mod_equip/New()
	. = ..()
	unlocked_designs += list(
		/datum/design/module/mod_riding_saddle,
	)

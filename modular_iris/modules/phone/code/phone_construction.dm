// Circuit board for rotary telephones
/obj/item/circuitboard/machine/phone
	name = "Rotary Telephone Circuit Board"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/phone_base/rotary
	req_components = list(
		/obj/item/stock_parts/subspace/treatment = 1,
		/obj/item/stack/cable_coil = 2
	)
	needs_anchored = FALSE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2, /datum/material/plastic = SHEET_MATERIAL_AMOUNT)

// Construction design for rotary telephone circuit boards
/datum/design/rotary_phone
	name = "Rotary Telephone Circuit Board"
	desc = "A circuit board for building classic rotary telephones that can be placed anywhere and connected to the station's phone network."
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/circuitboard/machine/phone
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

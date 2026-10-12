/datum/design/diskplantgene
	name = "Plant Data Disk"
	desc = "A disk for storing plant genetic data."
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=200, /datum/material/glass = 100)
	build_path = /obj/item/disk/plantgene
	category = list("Electronics")
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/spraycan/roboticist
	name = "Roboticist Spraycan"
	desc = "Paint for restyling unattached robotic limbs. Sadly doesn't shine like chrome."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/toy/crayon/spraycan/roboticist
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_EQUIPMENT_SCIENCE)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/module/mod_storage_bluespace
	name = "Bluespace Storage Module"
	materials = list(
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/uranium = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT * 1.5,
		)

	build_path = /obj/item/mod/module/storage/bluespace/nerfed

/datum/design/module/energy_shield_nanotrasen
	name = "Energy Shield Module"
	materials = list(
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 3.5,
		/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 3.5,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 4,
	)
	build_path = /obj/item/mod/module/energy_shield/nanotrasen

/datum/design/module/medbeam_nanotrasen
	name = "Medical Beam Module"
	materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT * 3.5,
	)
	build_path = /obj/item/mod/module/medbeam/nanotrasen
	category = list(RND_CATEGORY_MODSUIT_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

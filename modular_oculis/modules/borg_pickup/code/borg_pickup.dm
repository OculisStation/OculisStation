/datum/design/borg_upgrade_weight_reducer
	name = "Cyborg Weight Reducer"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/weight_reducer
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 5,
	)
	construction_time = 4 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ALL
	)

/obj/item/borg/upgrade/weight_reducer
	name = "Cyborg Weight Reducer"
	desc = "An upgrade to the cyborg to help reduce its weight. Makes borgs be light enough to be picked up."
	icon_state = "module_service"
	require_model = TRUE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 5, /datum/material/silver = SMALL_MATERIAL_AMOUNT * 5)

/obj/item/borg/upgrade/weight_reducer/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .

	borg.mob_size = MOB_SIZE_TINY
	borg.held_w_class = WEIGHT_CLASS_TINY
	borg.worn_slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_BACK
	borg.AddElement(/datum/element/can_be_held)
	ADD_TRAIT(borg, TRAIT_BORG_AGGRO_GRABBABLE, "weight_reducer_upgrade")

/obj/item/borg/upgrade/weight_reducer/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .

	borg.mob_size = initial(borg.mob_size)
	borg.held_w_class = initial(borg.held_w_class)
	borg.worn_slot_flags = initial(borg.worn_slot_flags)
	borg.RemoveElement(/datum/element/can_be_held)
	REMOVE_TRAIT(borg, TRAIT_BORG_AGGRO_GRABBABLE, "weight_reducer_upgrade")

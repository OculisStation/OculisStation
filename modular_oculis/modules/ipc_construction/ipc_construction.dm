/mob/living/carbon/human/species/synth/empty
	name = "synth assembly"
	desc = "Prints out a fully prepared synthetic chest, ready for further construction."
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/gold = SHEET_MATERIAL_AMOUNT)

/mob/living/carbon/human/species/synth/empty/Initialize(mapload)
	var/mob/living/carbon/human/species/synth/synth_body = src
	. = ..()
	/// death proc skips giving people a death moodlet so we use it before everything else
	ADD_TRAIT(synth_body, TRAIT_EMOTEMUTE, type)
	death()
	REMOVE_TRAIT(synth_body, TRAIT_EMOTEMUTE, type)

	for(var/synth_body_parts in synth_body.bodyparts)
		var/obj/item/bodypart/bodypart = synth_body_parts
		if(bodypart.body_part != CHEST)
			QDEL_NULL(bodypart)
	/// Remove those organs
	for (var/synth_organ in synth_body.organs)
		qdel(synth_organ)

/datum/design/synth_construction
	name = "Android Construction"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 10 SECONDS
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /mob/living/carbon/human/species/synth/empty
	category = list(
		RND_SUBCATEGORY_MECHFAB_ANDROID + RND_SUBCATEGORY_MECHFAB_ANDROID_CHASSIS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/obj/item/brain_processor/positronic/ipc
	name = "compact positronic brain"
	desc = "A cube of shining metal, it has an IPC serial number engraved on the top. It is usually slotted into the chest of synthetic crewmembers. This one appears to be inactive."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "posibrain"
	base_icon_state = "posibrain"

	begin_activation_message = "<span class='notice'>You carefully locate the manual activation switch and start the compact positronic brain's boot process.</span>"
	success_message = "<span class='notice'>The compact positronic brain pings, and its lights start flashing. Success!</span>"
	fail_message = "<span class='notice'>The compact positronic brain buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/gold = SHEET_MATERIAL_AMOUNT * 2, /datum/material/glass = SHEET_MATERIAL_AMOUNT, /datum/material/silver = SHEET_MATERIAL_AMOUNT)

/obj/item/brain_processor/positronic/ipc/update_icon_state()
	. = ..()
	if(is_searching())
		icon = 'icons/obj/devices/assemblies.dmi'
		icon_state = "[base_icon_state]-searching"
		return
	if(brainmob?.key)
		icon = 'modular_nova/master_files/icons/obj/surgery.dmi'
		icon_state = "posibrain-ipc"
		return
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "[base_icon_state]"
	return

/datum/design/synth_positronic
	name = "Android Positronic Brain"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 10 SECONDS
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/brain_processor/positronic/ipc
	category = list(
		RND_SUBCATEGORY_MECHFAB_ANDROID + RND_SUBCATEGORY_MECHFAB_ANDROID_CHASSIS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/power_cord
	name = "Charging Implant"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 3 SECONDS
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 5,
	)
	build_path = /obj/item/organ/cyberimp/arm/toolkit/power_cord/left_arm
	category = list(
		RND_SUBCATEGORY_MECHFAB_ANDROID + RND_SUBCATEGORY_MECHFAB_ANDROID_CHASSIS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

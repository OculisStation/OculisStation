/mob/living/basic/slime/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_SET_TYPE, "Set Slime Type")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_ADD_TRANSFORMATION, "Add Transformation")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_SET_LIFE_STAGE, "Set Life Stage")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_SET_POWER, "Set Power Level")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_SET_BEHAVIOR, "Set Behavior")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_FILL_GROWTH, "Fill Growth")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_FORCE_SPLIT, "Force Split")

/mob/living/basic/slime/vv_do_topic(list/href_list)
	. = ..()

	if(href_list[VV_HK_SLIME_SET_TYPE])
		admin_set_slime_type(usr)
	if(href_list[VV_HK_SLIME_ADD_TRANSFORMATION])
		admin_add_transformation(usr)
	if(href_list[VV_HK_SLIME_SET_LIFE_STAGE])
		admin_set_life_stage(usr)
	if(href_list[VV_HK_SLIME_SET_POWER])
		admin_set_power_level(usr)
	if(href_list[VV_HK_SLIME_SET_BEHAVIOR])
		admin_set_behavior(usr)
	if(href_list[VV_HK_SLIME_FILL_GROWTH])
		admin_fill_growth(usr)
	if(href_list[VV_HK_SLIME_FORCE_SPLIT])
		admin_force_split(usr)

/mob/living/basic/slime/proc/admin_set_slime_type(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	var/list/types_by_color = list()
	for(var/datum/slime_type/type_path as anything in subtypesof(/datum/slime_type))
		types_by_color[type_path::colour] = type_path

	var/chosen_color = tgui_input_list(admin, "Which slime type?", "Set Slime Type", types_by_color, default = slime_type.colour)
	if(!chosen_color || QDELETED(src) || !check_rights(NONE))
		return

	set_slime_type(types_by_color[chosen_color])
	// set_slime_type only renames slimes that still have a generic name, and this one may have been named by hand
	name = "[slime_type.colour] [life_stage] slime ([rand(1, 1000)])"
	real_name = name
	log_admin("[key_name(admin)] set [key_name(src)]'s slime type to [chosen_color].")

/mob/living/basic/slime/proc/admin_add_transformation(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	var/list/types_by_name = list()
	for(var/datum/slime_transformation/transformation_type as anything in subtypesof(/datum/slime_transformation))
		if(locate(transformation_type) in transformations)
			continue
		types_by_name[replacetext("[transformation_type]", "/datum/slime_transformation/", "")] = transformation_type

	if(!length(types_by_name))
		tgui_alert(admin, "This slime already has every transformation.", "Add Transformation")
		return
	if(length(transformations) >= SLIME_MAX_TRANSFORMATIONS)
		tgui_alert(admin, "This slime can't hold any more transformations.", "Add Transformation")
		return

	var/chosen_name = tgui_input_list(admin, "Which transformation?", "Add Transformation", types_by_name)
	if(!chosen_name || QDELETED(src) || !check_rights(NONE))
		return

	if(!add_transformation(types_by_name[chosen_name], admin))
		tgui_alert(admin, "The slime couldn't take that transformation.", "Add Transformation")
		return
	log_admin("[key_name(admin)] gave [key_name(src)] the [chosen_name] transformation.")

/mob/living/basic/slime/proc/admin_set_life_stage(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	var/chosen_stage = tgui_input_list(admin, "Which life stage?", "Set Life Stage", list(SLIME_LIFE_STAGE_BABY, SLIME_LIFE_STAGE_ADULT), default = life_stage)
	if(!chosen_stage || QDELETED(src) || !check_rights(NONE))
		return
	// set_life_stage scales health and damage from the current numbers, so doing it twice would stack
	if(chosen_stage == life_stage)
		return

	set_life_stage(chosen_stage)
	amount_grown = 0
	update_name()
	regenerate_icons()
	log_admin("[key_name(admin)] set [key_name(src)]'s life stage to [chosen_stage].")

/mob/living/basic/slime/proc/admin_set_power_level(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	var/new_power = tgui_input_number(admin, "Power level?", "Set Power Level", default = powerlevel, max_value = SLIME_MAX_POWER, min_value = SLIME_MIN_POWER, round_value = TRUE)
	if(isnull(new_power) || QDELETED(src) || !check_rights(NONE))
		return

	adjust_power_level(new_power - powerlevel)
	log_admin("[key_name(admin)] set [key_name(src)]'s power level to [new_power].")

/mob/living/basic/slime/proc/admin_set_behavior(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	var/static/list/behaviors = list("Pacified", "Default", "Enraged")
	var/chosen_behavior = tgui_input_list(admin, "Which behavior?", "Set Behavior", behaviors)
	if(!chosen_behavior || QDELETED(src) || !check_rights(NONE))
		return

	switch(chosen_behavior)
		if("Pacified")
			set_pacified_behaviour()
		if("Default")
			set_default_behaviour()
		if("Enraged")
			set_enraged_behaviour()
	log_admin("[key_name(admin)] set [key_name(src)]'s behavior to [chosen_behavior].")

/mob/living/basic/slime/proc/admin_fill_growth(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	amount_grown = SLIME_EVOLUTION_THRESHOLD
	log_admin("[key_name(admin)] filled [key_name(src)]'s growth.")

/mob/living/basic/slime/proc/admin_force_split(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	amount_grown = SLIME_EVOLUTION_THRESHOLD
	if(!reproduce())
		tgui_alert(admin, "The slime can't split right now (needs to be a conscious adult with room, and not blocked from splitting).", "Force Split")
		return
	log_admin("[key_name(admin)] forced [key_name(src)] to split.")

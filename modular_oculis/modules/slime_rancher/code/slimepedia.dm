/// Every slime color, mutation, extract reaction and crossbreed, for the Slimepedia.
/datum/asset/json/slimepedia
	name = "slimepedia"

/datum/asset/json/slimepedia/generate()
	var/alist/reactions_by_extract = reactions_by_extract()
	var/alist/colors = alist()
	var/alist/source_by_effect = alist()
	for(var/datum/slime_type/slime_type as anything in subtypesof(/datum/slime_type))
		var/id = slime_type::colour
		if(!id)
			continue
		var/obj/item/slime_extract/extract = slime_type::core_type
		colors[id] = list(
			"id" = id,
			"name" = id,
			"hex" = slime_type::rgb_code,
			"transparent" = slime_type::transparent,
			"mutations" = mutation_data(slime_type),
			"parents" = list(),
			"effect" = extract::crossbreed_modification,
			"reactions" = reactions_by_extract[extract] || list(),
		)
		if(extract::crossbreed_modification)
			source_by_effect[extract::crossbreed_modification] = id

	for(var/id in colors)
		for(var/list/mutation as anything in colors[id]["mutations"])
			var/list/target = colors[mutation["into"]]
			var/list/target_parents = target["parents"]
			target_parents += id

	var/alist/families = alist()
	for(var/key in GLOB.slime_crossbreeds)
		var/obj/item/slimecross/cross_path = GLOB.slime_crossbreeds[key]
		var/effect = cross_path::effect
		if(!families[effect])
			families[effect] = list(
				"id" = effect,
				"source" = source_by_effect[effect],
				"crossbreeds" = list(),
			)
		var/list/family_crossbreeds = families[effect]["crossbreeds"]
		family_crossbreeds += list(list(
			"color" = cross_path::colour,
			"desc" = cross_path::effect_desc,
		))

	var/list/color_list = list()
	for(var/id in colors)
		color_list += list(colors[id])
	var/list/family_list = list()
	for(var/effect in families)
		family_list += list(families[effect])

	return list(
		"colors" = color_list,
		"families" = family_list,
		"effect_extracts" = COMPRESSOR_EFFECT_EXTRACTS,
		"color_extracts" = COMPRESSOR_COLOR_EXTRACTS,
	)

/// What each slime color can mutate into. Lists can't be read off a typepath, hence the throwaway instances.
/datum/asset/json/slimepedia/proc/mutation_data(datum/slime_type/slime_type) as /list
	. = list()
	var/datum/slime_type/info = new slime_type
	for(var/datum/slime_mutation/mutation_type as anything in info.possible_mutations)
		// not qdel'd, Destroy() unregisters from a slime this one never had
		var/datum/slime_mutation/recipe = new mutation_type
		var/list/items = list()
		for(var/obj/item/wanted as anything in recipe.needed_items)
			items += list(list(
				"name" = wanted::name,
				"icon" = wanted::icon,
				"icon_state" = wanted::icon_state,
			))
		var/list/drains = list()
		for(var/prey_type, drain_total in recipe.latch_needed)
			var/mob/living/prey = prey_type
			drains += list(list(
				"name" = prey::name,
				"icon" = prey::icon,
				"icon_state" = prey::icon_state,
				"amount" = drain_total,
			))
		var/datum/slime_type/result = mutation_type::mutates_into
		. += list(list(
			"into" = result::colour,
			"items" = items,
			"drains" = drains,
		))
	qdel(info, TRUE)

/// Extract type -> what injecting each reagent mix into it does.
/datum/asset/json/slimepedia/proc/reactions_by_extract() as /alist
	. = alist()
	for(var/reaction_type in GLOB.chemical_reactions_list)
		var/datum/chemical_reaction/slime/reaction = GLOB.chemical_reactions_list[reaction_type]
		if(!istype(reaction))
			continue
		var/list/reagents = list()
		for(var/datum/reagent/reagent_type as anything in reaction.required_reagents)
			reagents += list(list(
				"name" = reagent_type::name,
				"amount" = reaction.required_reagents[reagent_type],
			))
		.[reaction.required_container] += list(list(
			"reagents" = reagents,
			"desc" = reaction.desc,
		))

/datum/asset/spritesheet_batched/slimepedia
	name = "slimepedia"

/datum/asset/spritesheet_batched/slimepedia/create_spritesheets()
	var/slime_icon = /mob/living/basic/slime::icon
	var/datum/universal_icon/face = uni_icon(slime_icon, "aslime-[SLIME_MOOD_SMILE]", SOUTH, 1)
	for(var/datum/slime_type/slime_type as anything in subtypesof(/datum/slime_type))
		var/id = slime_type::colour
		if(!id)
			continue
		var/datum/universal_icon/body = uni_icon(slime_icon, "[id]-[SLIME_LIFE_STAGE_ADULT]", SOUTH, 1)
		insert_icon("slime-[id]", body.blend_icon(face, ICON_OVERLAY))
		var/obj/item/slime_extract/extract = slime_type::core_type
		insert_icon("extract-[id]", uni_icon(extract::icon, extract::icon_state, SOUTH, 1))

	for(var/key in GLOB.slime_crossbreeds)
		var/obj/item/slimecross/cross_path = GLOB.slime_crossbreeds[key]
		// the tint gets picked in Initialize(), so we need a real one to find out what it is
		var/obj/item/slimecross/cross = new cross_path
		var/datum/universal_icon/cross_icon = uni_icon(cross_path::icon, cross_path::icon_state, SOUTH, 1)
		if(cross.color)
			cross_icon.blend_color(cross.color, ICON_MULTIPLY)
		insert_icon("cross-[cross_path::effect]-[cross_path::colour]", cross_icon)
		qdel(cross)

/// A field guide to every slime color, its mutations, its extract and its crossbreeds.
/datum/computer_file/program/slimepedia
	filename = "slimepedia"
	filedesc = "Slimepedia"
	downloader_category = PROGRAM_CATEGORY_SCIENCE
	program_open_overlay = "research"
	extended_desc = "A xenobiology field guide covering every slime color, what it mutates into, what its extract does, and every crossbreed."
	size = 4
	tgui_id = "NtosSlimepedia"
	program_icon = "flask"

/datum/computer_file/program/slimepedia/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/slimepedia),
		get_asset_datum(/datum/asset/spritesheet_batched/slimepedia),
	)

/obj/item/slime_rancher_scanner/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/slimepedia),
		get_asset_datum(/datum/asset/spritesheet_batched/slimepedia),
	)

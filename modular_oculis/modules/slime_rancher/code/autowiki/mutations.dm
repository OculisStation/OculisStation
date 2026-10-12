/datum/autowiki/slime_mutations
	page = "Template:Autowiki/Content/SlimeMutations"
	var/static/list/uploaded_filenames = list()

/datum/autowiki/slime_mutations/generate()
	var/output = ""
	var/list/sources_by_mutation = build_sources()

	for(var/datum/slime_mutation/mutation_path as anything in sort_list(valid_subtypesof(/datum/slime_mutation), GLOBAL_PROC_REF(cmp_typepaths_asc)))
		var/datum/slime_type/result_type = mutation_path::mutates_into

		output += include_template("Autowiki/SlimeMutation", list(
			"result" = escape_value(result_type::colour),
			"color" = result_type::rgb_code,
			"icon" = slime_icon(result_type::colour),
			"sources" = format_sources(sources_by_mutation[mutation_path]),
			"items" = format_items(mutation_path::needed_items),
			"drains" = format_drains(mutation_path::latch_needed),
		)) + "\n"

	return output

/// color -> from what colors it can come
/datum/autowiki/slime_mutations/proc/build_sources()
	var/list/sources_by_mutation = list()

	for(var/slime_path in sort_list(valid_subtypesof(/datum/slime_type), GLOBAL_PROC_REF(cmp_typepaths_asc)))
		// possible_mutations defaults to rainbow in New() when null, so we need a real instance
		var/datum/slime_type/slime_type = new slime_path
		if(slime_type.colour)
			for(var/mutation_path in slime_type.possible_mutations)
				if(!sources_by_mutation[mutation_path])
					sources_by_mutation[mutation_path] = list()
				sources_by_mutation[mutation_path] += slime_type.colour
		qdel(slime_type, TRUE)

	return sources_by_mutation

/datum/autowiki/slime_mutations/proc/format_sources(list/colors)
	var/output = ""
	for(var/color in colors)
		output += include_template("Autowiki/SlimeMutationSource", list(
			"name" = escape_value(color),
			"icon" = slime_icon(color),
		)) + "\n"
	return output

/datum/autowiki/slime_mutations/proc/format_items(list/item_paths)
	var/list/counts = list()
	for(var/obj/item/item_path as anything in item_paths)
		counts[item_path] = (counts[item_path] || 0) + 1

	var/output = ""
	for(var/obj/item/item_path as anything in counts)
		output += include_template("Autowiki/SlimeMutationItem", list(
			"name" = escape_value(item_path::name),
			"icon" = atom_icon(item_path),
			"amount" = counts[item_path],
		)) + "\n"
	return output

/datum/autowiki/slime_mutations/proc/format_drains(alist/latch_needed)
	var/output = ""
	for(var/mob/mob_path as anything in latch_needed)
		output += include_template("Autowiki/SlimeMutationDrain", list(
			"name" = escape_value(mob_path::name),
			"icon" = atom_icon(mob_path),
			"amount" = latch_needed[mob_path],
		)) + "\n"
	return output

/datum/autowiki/slime_mutations/proc/upload_icon_once(icon/icon_to_upload, filename)
	if(filename in uploaded_filenames)
		return
	upload_icon(icon_to_upload, filename)
	uploaded_filenames += filename

/datum/autowiki/slime_mutations/proc/slime_icon(color)
	var/filename = SANITIZE_FILENAME("slime_[color]")
	upload_icon_once(icon(/mob/living/basic/slime::icon, "[color]-[SLIME_LIFE_STAGE_ADULT]", SOUTH, 1, FALSE), filename)
	return "Autowiki-[filename].png"

/datum/autowiki/slime_mutations/proc/atom_icon(atom/thing_path)
	var/filename = SANITIZE_FILENAME("slime_[replacetext("[thing_path]", "/", "_")]")
	upload_icon_once(icon(thing_path::icon, thing_path::icon_state, SOUTH, 1, FALSE), filename)
	return "Autowiki-[filename].png"

/datum/autowiki/slime_mutations/by_source
	page = "Template:Autowiki/Content/SlimeMutationsBySource"

/datum/autowiki/slime_mutations/by_source/generate()
	var/output = ""
	var/list/sources_by_mutation = build_sources()

	var/list/mutations_by_source = list()
	for(var/mutation_path in sources_by_mutation)
		for(var/color in sources_by_mutation[mutation_path])
			if(!mutations_by_source[color])
				mutations_by_source[color] = list()
			mutations_by_source[color] += mutation_path

	for(var/color in sort_list(mutations_by_source))
		for(var/datum/slime_mutation/mutation_path as anything in sort_list(mutations_by_source[color], GLOBAL_PROC_REF(cmp_typepaths_asc)))
			var/datum/slime_type/result_type = mutation_path::mutates_into

			output += include_template("Autowiki/SlimeMutationBySource", list(
				"source" = escape_value(color),
				"source_icon" = slime_icon(color),
				"result" = escape_value(result_type::colour),
				"color" = result_type::rgb_code,
				"icon" = slime_icon(result_type::colour),
				"items" = format_items(mutation_path::needed_items),
				"drains" = format_drains(mutation_path::latch_needed),
			)) + "\n"

	return output

/datum/autowiki/slime_crossbreeds
	page = "Template:Autowiki/Content/SlimeCrossbreeds"

/datum/autowiki/slime_crossbreeds/generate()
	var/output = ""
	var/list/extract_by_effect = build_extracts()

	for(var/obj/item/slimecross/cross_path as anything in sort_list(valid_subtypesof(/obj/item/slimecross), GLOBAL_PROC_REF(cmp_typepaths_asc)))
		if(cross_path::colour == "null")
			continue // effect parents like /obj/item/slimecross/chilling itself, not a real crossbreed

		var/obj/item/slimecross/cross = new cross_path()
		var/obj/item/slime_extract/extract_path = extract_by_effect[cross.effect]

		output += include_template("Autowiki/SlimeCrossbreed", list(
			"name" = escape_value(cross.name),
			"effect" = escape_value(cross.effect),
			"slime_color" = escape_value(cross.colour),
			"description" = escape_value(cross.effect_desc),
			"icon" = create_icon(cross),
			"feed_item" = extract_path ? escape_value(extract_path::name) : "",
			"feed_amount" = SLIME_EXTRACT_CROSSING_REQUIRED,
		)) + "\n"

		qdel(cross)

	return output

/// crossbreed_modification (the effect string) -> the extract type that grants it
/datum/autowiki/slime_crossbreeds/proc/build_extracts()
	var/list/extract_by_effect = list()
	for(var/obj/item/slime_extract/extract_path as anything in valid_subtypesof(/obj/item/slime_extract))
		if(extract_path::crossbreed_modification)
			extract_by_effect[extract_path::crossbreed_modification] = extract_path
	return extract_by_effect

/datum/autowiki/slime_crossbreeds/proc/create_icon(obj/item/slimecross/cross)
	var/filename = SANITIZE_FILENAME("slime_cross_[cross.effect]_[cross.colour]")
	upload_icon(getFlatIcon(cross, no_anim = TRUE), filename)
	return "Autowiki-[filename].png"

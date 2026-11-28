ADMIN_VERB(change_storm_intensity, R_ADMIN, "Change Storm Intensity", "Change the Eidolon Storm's Intensity", ADMIN_CATEGORY_EVENTS)
	var/list/possible_options = list()
	for(var/storm_ruleset in subtypesof(/datum/storm_ruleset))
		var/datum/storm_ruleset/storm_ruleset_datum = new storm_ruleset()
		possible_options[storm_ruleset_datum.name] = storm_ruleset

	var/picked_ruleset = tgui_input_list(user, "Choose a Storm Ruleset", "Storm Rulesets", sort_list(possible_options))
	if(isnull(picked_ruleset))
		return
	var/datum/storm_ruleset/new_storm_ruleset = new picked_ruleset()
	SSeidolon_storm.chosen_storm_ruleset = new_storm_ruleset

	log_admin("[key_name(user.mob)] changed the storm intensity to: [new_storm_ruleset.name]")
	message_admins("[key_name_admin(user.mob)] changed the storm intensity to: [new_storm_ruleset.name]")
	SSblackbox.record_feedback("tally", "change_storm_intensity", 1, "Changed the storm intensity to: [new_storm_ruleset.name]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

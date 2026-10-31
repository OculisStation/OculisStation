PROCESSING_SUBSYSTEM_DEF(eidolon_storm)
	name = "Eidolon Storm"
	stat_tag = "ES"
	ss_flags = SS_NO_INIT | SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	wait = 1 MINUTES

	COOLDOWN_DECLARE(eidolon_storm_cooldown)
	/// Currently selected storem intensity. See defines for values.
	var/datum/storm_ruleset/chosen_storm_ruleset = /datum/storm_ruleset
	/// The station's redspace anchor. We shouldn't care for any other anchors in the game.
	var/obj/machinery/redspace_anchor/station_anchor = null

/datum/controller/subsystem/processing/eidolon_storm/proc/register_anchor(obj/machinery/redspace_anchor/anchor)
	if(!SSmapping.level_has_any_trait(anchor.z, ZTRAIT_STATION)) // So that we can have decorative anchors on other z levels, like on castor.
		return
	if(station_anchor) // Incase some admin fucks up and spawns in a second anchor on the station z level.
		return
	station_anchor = anchor

/datum/controller/subsystem/processing/eidolon_storm/proc/initialize_storm_intensity()
	var/list/player_candidates = list()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list - SSjob.unassigned)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			player_candidates += player
	var/roundstart_population = length(player_candidates)

	var/list/possible_rulesets = list()
	for(var/storm_ruleset in subtypesof(/datum/storm_ruleset))
		var/datum/storm_ruleset/intensity_datum = new storm_ruleset()
		if(roundstart_population < intensity_datum.min_pop)
			qdel(intensity_datum)
			continue
		possible_rulesets += intensity_datum
	chosen_storm_ruleset = pick(possible_rulesets)

	log_dynamic("Selected intensity: [chosen_storm_ruleset.intensity]")
	log_dynamic("- Roundstart population: [roundstart_population]")
	SSblackbox.record_feedback(
		"associative",
		"storm_intensity",
		1,
		list(
			"server_name" = CONFIG_GET(string/serversqlname),
			"intensity" = chosen_storm_ruleset.intensity,
			"player_count" = roundstart_population,
		),
	)

/datum/controller/subsystem/processing/eidolon_storm/fire(resumed = FALSE)
	if(!COOLDOWN_FINISHED(src, eidolon_storm_cooldown))
		return
	COOLDOWN_START(src, eidolon_storm_cooldown, (chosen_storm_ruleset.storm_cooldown))
	station_anchor?.tick(chosen_storm_ruleset.intensity)

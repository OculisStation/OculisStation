PROCESSING_SUBSYSTEM_DEF(eidolon_storm)
	name = "Eidolon Storm"
	stat_tag = "ES"
	ss_flags = SS_NO_INIT | SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	wait = 1 MINUTES

	/// Cooldown for ticking the redspace anchor on station.
	COOLDOWN_DECLARE(eidolon_storm_cooldown)
	/// Cooldown for how often we should spawn events while the anchor is in an invalid state.
	COOLDOWN_DECLARE(eidolon_event_cooldown)
	/// Currently selected storm intensity. See defines for values.
	var/datum/storm_ruleset/chosen_storm_ruleset = /datum/storm_ruleset
	/// The station's redspace anchor. We shouldn't care for any other anchors in the game.
	var/obj/machinery/redspace_anchor/station_anchor = null
	// List of all anchors.
	var/list/redspace_anchors = list()

/datum/controller/subsystem/processing/eidolon_storm/Recover()
	chosen_storm_ruleset = SSeidolon_storm.chosen_storm_ruleset
	station_anchor = SSeidolon_storm.station_anchor

/datum/controller/subsystem/processing/eidolon_storm/proc/register_anchor(obj/machinery/redspace_anchor/anchor)
	if(!SSmapping.level_has_any_trait(anchor.z, ZTRAIT_STATION)) // So that we can have decorative anchors on other z levels, like on castor.
		return
	if(station_anchor) // Incase some admin fucks up and spawns in a second anchor on the station z level.
		return
	station_anchor = anchor

/datum/controller/subsystem/processing/eidolon_storm/proc/initialize_storm_intensity()
	var/player_candidates = 0
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list - SSjob.unassigned)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			player_candidates += 1

	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player.ready == PLAYER_NOT_READY)
			player_candidates += 0.5

	player_candidates = round(player_candidates, 1)

	var/list/possible_rulesets = list()
	for(var/storm_ruleset in subtypesof(/datum/storm_ruleset))
		var/datum/storm_ruleset/intensity_datum = new storm_ruleset()
		if(player_candidates < intensity_datum.min_pop)
			qdel(intensity_datum)
			continue
		possible_rulesets += intensity_datum
	chosen_storm_ruleset = pick(possible_rulesets)

	log_dynamic("Selected intensity: [chosen_storm_ruleset.intensity]")
	log_dynamic("- Roundstart population: [player_candidates]")
	SSblackbox.record_feedback(
		"associative",
		"storm_intensity",
		1,
		list(
			"server_name" = CONFIG_GET(string/serversqlname),
			"intensity" = chosen_storm_ruleset.intensity,
			"player_count" = player_candidates,
		),
	)

/datum/controller/subsystem/processing/eidolon_storm/fire(resumed = FALSE)
	if(!COOLDOWN_FINISHED(src, eidolon_storm_cooldown))
		return
	COOLDOWN_START(src, eidolon_storm_cooldown, (chosen_storm_ruleset.storm_cooldown))
	if(station_anchor?.tick(chosen_storm_ruleset.intensity)) // Attempt to tick the anchor
		return
	if(!COOLDOWN_FINISHED(src, eidolon_event_cooldown))
		return
	SSevents.spawnEvent() // Oops! Your anchor has turned off or is in an invalid state to protect you! Chaos Time!
	COOLDOWN_START(src, eidolon_event_cooldown, 5 MINUTES)

/// Throw everyone to let them know that the anchor was activated/deactivated. Used when it enters active mode.
/datum/controller/subsystem/processing/eidolon_storm/proc/throw_everyone()
	for(var/turf/open/floor/targeted_turf in GLOB.station_turfs)
		for(var/atom/movable/unanchored_atom as anything in targeted_turf)
			if(unanchored_atom.anchored)
				continue
			var/turf/atom_turf = get_turf(unanchored_atom)
			if(!istype(atom_turf))
				continue
			if(!is_valid_z_level(get_turf(src), atom_turf))
				continue
			var/throwtarget = get_edge_target_turf(unanchored_atom, rand(1,8))
			unanchored_atom.throw_at(throwtarget, 5, 2)

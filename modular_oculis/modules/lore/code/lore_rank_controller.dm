// The loremaster system is a bit more complex than the other player ranks, so it's
// got its own handling and global lists declarations in the `loremaster` module.

/datum/player_rank_controller/loremaster
	rank_title = "loremaster"

/datum/player_rank_controller/loremaster/New()
	. = ..()
	legacy_file_path = "[global.config.directory]/oculis/loremasters.txt"

/datum/player_rank_controller/loremaster/add_player(ckey)
	if(IsAdminAdvancedProcCall())
		return

	ckey = ckey(ckey)

	new /datum/loremasters(ckey)

/datum/player_rank_controller/loremaster/remove_player(ckey)
	if(IsAdminAdvancedProcCall())
		return

	var/datum/loremasters/loremaster_datum = GLOB.loremaster_datums[ckey]
	loremaster_datum?.remove_loremaster()

/datum/player_rank_controller/loremaster/clear_existing_rank_data()
	if(IsAdminAdvancedProcCall())
		return

	GLOB.loremaster_datums.Cut()

	for(var/client/ex_loremaster as anything in GLOB.loremasters)
		ex_loremaster.remove_loremaster_verbs()
		ex_loremaster.loremaster_datum = null

	GLOB.loremasters.Cut()

/datum/player_rank_controller/loremaster/get_ckeys_for_legacy_save()
	if(IsAdminAdvancedProcCall())
		return

	return GLOB.loremasters

/datum/player_rank_controller/loremaster/should_use_legacy_system()
	return CONFIG_GET(flag/loremaster_legacy_system)

/// Defines whether the server uses the legacy donator system with donators.txt or the SQL system.
/datum/config_entry/flag/loremaster_legacy_system
	protection = CONFIG_ENTRY_LOCKED

/// Handles loading loremasters either via SQL or using the legacy system,
/// based on configs.
/datum/controller/subsystem/player_ranks/proc/load_loremasters()
	PROTECTED_PROC(TRUE)

	if(IsAdminAdvancedProcCall())
		return

	loremaster_controller = new

	if(CONFIG_GET(flag/loremaster_legacy_system))
		loremaster_controller.load_legacy()
		return

	if(!SSdbcore.Connect())
		var/message = "Failed to connect to database in load_loremasters(). Reverting to legacy system."
		log_config(message)
		log_game(message)
		message_admins(message)
		CONFIG_SET(flag/loremaster_legacy_system, TRUE)
		loremaster_controller.load_legacy()
		return

	load_player_rank_sql(loremaster_controller)

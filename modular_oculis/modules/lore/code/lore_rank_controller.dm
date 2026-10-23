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

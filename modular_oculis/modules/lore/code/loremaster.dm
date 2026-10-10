//all clients whom are loremasters
GLOBAL_LIST_EMPTY(loremasters)
GLOBAL_PROTECT(loremasters)

GLOBAL_LIST_EMPTY(loremaster_datums)
GLOBAL_PROTECT(loremaster_datums)

/datum/loremasters
	var/name = "someone's loremaster datum"
	var/client/owner // the actual loremaster, client type
	var/target // the loremaster's ckey

/datum/loremasters/New(ckey)
	if(!ckey)
		QDEL_IN(src, 0)
		CRASH("Loremaster datum created without a ckey")
	target = ckey(ckey)
	name = "[ckey]'s loremaster datum"
	GLOB.loremaster_datums[target] = src
	//set the owner var and load commands
	owner = GLOB.directory[ckey]
	if(owner)
		owner.loremaster_datum = src
		owner.add_loremaster_verbs()
		if(!check_rights_for(owner, R_ADMIN,0)) // don't add admins to loremaster list.
			GLOB.loremasters[owner] = TRUE

/datum/loremasters/proc/remove_loremaster()
	if(owner)
		owner.remove_loremaster_verbs()
		GLOB.loremasters -= owner
		owner.loremaster_datum = null
		owner = null
	log_admin_private("[target] was removed from the rank of mentor.")
	GLOB.loremaster_datums -= target
	qdel(src)

/client
	/// Acts the same way holder does towards admin: it holds the loremaster datum. if set, the guy's a loremaster.
	var/datum/loremasters/loremaster_datum

/client/New()
	. = ..()
	loremaster_datum_set()

/client/Destroy()
	if(GLOB.loremasters[src])
		GLOB.loremasters -= src

	return ..()

/client/proc/loremaster_datum_set()
	loremaster_datum = GLOB.loremasters[ckey]
	if(!loremaster_datum && is_admin(src)) // admin with no loremaster datum? let's fix that
		new /datum/loremasters(ckey)

	if(loremaster_datum)
		loremaster_datum.owner = src
		GLOB.loremasters[src] = TRUE
		add_loremaster_verbs()

/client/proc/add_loremaster_verbs()
	if(loremaster_datum)
		ASSIGN_GAME_VERB(src, /client, cmd_lore_say)

/client/proc/remove_loremaster_verbs()
	UNASSIGN_GAME_VERB(src, /client, cmd_lore_say)


/**
 * Returns whether or not the user is qualified as a mentor.
 *
 * Arguments:
 * * admin_bypass - Whether or not admins can succeed this check, even if they
 * do not actually possess the role. Defaults to `TRUE`.
 */
/client/proc/is_loremaster(admin_bypass = TRUE)
	if(loremaster_datum || (admin_bypass && check_rights_for(src, R_ADMIN)))
		return TRUE

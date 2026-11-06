GLOBAL_VAR_INIT(BACKSTAGE_SEC_COLOR, "#0080FF")
GLOBAL_VAR_INIT(BACKSTAGE_ANTAG_COLOR, "#ff0000")
GLOBAL_VAR_INIT(backstage_allowed, TRUE)	// used with admin verbs to disable backstage - not a config option
GLOBAL_ALIST_EMPTY(ckey_to_backstage_name)

#define BACKSTAGE_LISTEN_PLAYER 1
#define BACKSTAGE_LISTEN_ADMIN 2
#define BACKSTAGE_JOBS list(JOB_CAPTAIN=TRUE, JOB_HEAD_OF_SECURITY=TRUE, JOB_WARDEN=TRUE, JOB_DETECTIVE=TRUE, JOB_SECURITY_OFFICER=TRUE, JOB_CORRECTIONS_OFFICER=TRUE, JOB_BLUESHIELD=TRUE, JOB_ORDERLY=TRUE, JOB_SCIENCE_GUARD=TRUE, JOB_ENGINEERING_GUARD=TRUE, JOB_CUSTOMS_AGENT=TRUE, JOB_BOUNCER=TRUE)

GAME_VERB(/client, backstage, "Backstage OOC", "OOC")
	VERB_ARG(msg, VERB_ARG_TYPE_TEXT, VERB_ARG_SOURCE_INPUT)
	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(src, span_danger("Speech is currently admin-disabled."))
		return

	if(!mob)
		return

	var/is_antag = FALSE
	var/is_security = FALSE

	if(!holder)
		var/job = mob?.mind.assigned_role?.title
		is_security = job && BACKSTAGE_JOBS[job]
		is_antag = length(mob.mind?.antag_datums)
		if(!is_security && !is_antag)
			to_chat(src, span_danger("You're not a security role or an antagonist!"))
			return
		if(!GLOB.backstage_allowed)
			to_chat(src, span_danger("Backstage OOC is globally muted."))
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, span_danger("You cannot use OOC (muted)."))
			return
	if(is_banned_from(ckey, "OOC"))
		to_chat(src, span_danger("You have been banned from OOC."))
		return
	if(QDELETED(src))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = emoji_parse(msg)

	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, span_danger("You have OOC muted."))
		return

	mob.log_talk(raw_msg, LOG_OOC, tag="Backstage OOC")

	var/keyname = key
	var/anon = FALSE

	//Anonimity for players and deadminned admins
	if(!holder || holder.deadmined)
		if(!GLOB.ckey_to_backstage_name[ckey])
			if(is_antag) // check for antag first in case sec is antag, somehow
				GLOB.ckey_to_backstage_name[ckey] = "Operator [pick(GLOB.phonetic_alphabet)] [rand(1, 99)]"
			else // is_security, presumably
				GLOB.ckey_to_backstage_name[ckey] = "Deputy [pick(GLOB.phonetic_alphabet)] [rand(1, 99)]"
		keyname = GLOB.ckey_to_backstage_name[ckey]
		anon = TRUE

	var/list/listeners = list()

	for(var/mob/iterated_mob as anything in GLOB.player_list)
		//Admins with muted OOC do not get to listen to Backstage, but normal players do, as it could be admins talking important stuff to them
		if(iterated_mob.client?.holder && !iterated_mob.client?.holder?.deadmined && iterated_mob.client?.prefs?.chat_toggles & CHAT_OOC)
			listeners[iterated_mob.client] = BACKSTAGE_LISTEN_ADMIN
		else
			var/listener_job = iterated_mob.mind?.assigned_role?.title
			if((listener_job && BACKSTAGE_JOBS[listener_job]) || (length(iterated_mob.mind?.antag_datums))) // if the listener is sec or an antag
				listeners[iterated_mob.client] = BACKSTAGE_LISTEN_PLAYER

	for(var/client/iterated_client as anything in listeners)
		var/mode = listeners[iterated_client]
		var/color
		if ((!anon && CONFIG_GET(flag/allow_admin_ooccolor) && iterated_client?.prefs?.read_preference(/datum/preference/color/ooc_color)))
			color = iterated_client?.prefs?.read_preference(/datum/preference/color/ooc_color)
		else if (is_antag)
			color = GLOB.BACKSTAGE_ANTAG_COLOR
		else // is_security, presumably
			color = GLOB.BACKSTAGE_SEC_COLOR
		var/name = (mode == BACKSTAGE_LISTEN_ADMIN && anon) ? "([key])[keyname]" : keyname
		to_chat(iterated_client, span_oocplain("<font color='[color]'><b><span class='prefix'>BACKSTAGE:</span> <EM>[name]:</EM> <span class='message linkify'>[msg]</span></b></font>"), avoid_highlighting = (iterated_client == src))

/proc/toggle_backstage(toggle = null)
	if(toggle != null) //if we're specifically en/disabling backstage
		if(toggle != GLOB.backstage_allowed)
			GLOB.backstage_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.backstage_allowed = !GLOB.backstage_allowed
	var/list/listeners = list()
	for(var/mob/iterated_mob as anything in GLOB.player_list)
		if(!iterated_mob.client?.holder?.deadmined)
			listeners[iterated_mob.client] = TRUE
		else if(iterated_mob.mind)
			var/datum/mind/mob_mind = iterated_mob.mind
			if(BACKSTAGE_JOBS[mob_mind.assigned_role] || length(mob_mind.antag_datums))
				listeners[iterated_mob.client] = TRUE
	for(var/client/iterated_client as anything in listeners)
		to_chat(iterated_client, span_oocplain("<b>The backstage channel has been globally [GLOB.backstage_allowed ? "enabled" : "disabled"].</b>"))

ADMIN_VERB(togglebackstage, R_ADMIN, "Toggle Backstage OOC", "Toggles Backstage OOC.", ADMIN_CATEGORY_SERVER)
	toggle_backstage()
	log_admin("[key_name(user)] toggled Backstage OOC.")
	message_admins("[key_name_admin(user)] toggled Backstage OOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Backstage OOC", "[GLOB.backstage_allowed ? "Enabled" : "Disabled"]"))

#undef BACKSTAGE_LISTEN_PLAYER
#undef BACKSTAGE_LISTEN_ADMIN
#undef BACKSTAGE_JOBS

ADMIN_VERB(cmd_lore_say, R_LORE, "LSay", "Send a message to other lorewriters", ADMIN_CATEGORY_MAIN)
	VERB_ARG(message, VERB_ARG_TYPE_TEXT, VERB_ARG_SOURCE_INPUT)
	message = emoji_parse(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return

	if(findtext(message, "@"))
		var/list/link_results = check_lsay_links(message)
		if(length(link_results))
			message = link_results[ASAY_LINK_NEW_MESSAGE_INDEX]
			link_results[ASAY_LINK_NEW_MESSAGE_INDEX] = null
			var/list/pinged_admin_clients = link_results[ASAY_LINK_PINGED_ADMINS_INDEX]
			for(var/iter_ckey in pinged_admin_clients)
				var/client/iter_admin_client = pinged_admin_clients[iter_ckey]
				if(!iter_admin_client?.holder)
					continue
				window_flash(iter_admin_client)
				SEND_SOUND(iter_admin_client.mob, sound('sound/misc/asay_ping.ogg'))

	log_lore("[key_name(user)]: [message]")
	message = keywords_lookup(message)
	var/asay_color = user.prefs.read_preference(/datum/preference/color/asay_color)
	var/custom_asay_color = (CONFIG_GET(flag/allow_admin_asaycolor) && asay_color) ? "<font color=[asay_color]>" : "<font color='[DEFAULT_ASAY_COLOR]'>"
	message = "[span_hierophant("[span_prefix("LORE:")] <EM>[key_name_admin(user)]</EM> [ADMIN_FLW(user.mob)]: [custom_asay_color]<span class='message linkify'>[message]")]</span>[custom_asay_color ? "</font>":null]"
	for(var/client/admin as anything in GLOB.admins)
		to_chat(admin,
			type = MESSAGE_TYPE_LORE,
			html = message,
			avoid_highlighting = (admin == user),
			confidential = TRUE,
		)

	BLACKBOX_LOG_ADMIN_VERB("Lsay")

/**
 * Checks a given message to see if any of the words are something we want to treat specially, as detailed below.
 *
 * There are 3 cases where a word is something we want to act on
 * 1. Admin pings, like @adminckey. Pings the admin in question, text is not clickable
 * Returns a list being used as a tuple. Index ASAY_LINK_NEW_MESSAGE_INDEX contains the new message text (with clickable links and such)
 *
 * Arguments:
 * * msg - the message being scanned
 */
/proc/check_lsay_links(msg)
	var/list/msglist = splittext(msg, " ") //explode the input msg into a list
	var/list/pinged_admins = list() // if we ping any admins, store them here so we can ping them after
	var/modified = FALSE // did we find anything?

	var/i = 0
	for(var/word in msglist)
		i++
		if(!length(word))
			continue

		switch(word[1])
			if("@")
				var/stripped_word = ckey(copytext(word, 2))

				// first we check if it's a ckey of an admin
				var/client/client_check = GLOB.directory[stripped_word]
				if(client_check?.holder)
					msglist[i] = "<u>[word]</u>"
					pinged_admins[stripped_word] = client_check
					modified = TRUE
					continue

				// then if not, we check if it's a datum ref

				var/word_with_brackets = "\[[stripped_word]\]" // the actual memory address lookups need the bracket wraps
				var/datum/datum_check = locate(word_with_brackets)
				if(!istype(datum_check))
					continue
				msglist[i] = "<u><a href='byond://?_src_=vars;[HrefToken(forceGlobal = TRUE)];Vars=[word_with_brackets]'>[word]</A></u>"
				modified = TRUE

	if(modified)
		var/list/return_list = list()
		return_list[ASAY_LINK_NEW_MESSAGE_INDEX] = jointext(msglist, " ") // without tuples, we must make do!
		return_list[ASAY_LINK_PINGED_ADMINS_INDEX] = pinged_admins
		return return_list

GLOBAL_LIST_EMPTY(lorelog)
GLOBAL_PROTECT(lorelog)

/proc/log_lore(text, list/data)
	GLOB.lorelog.Add(text)
	logger.Log(LOG_CATEGORY_ADMIN_LORE, text, data)

/datum/log_category/admin_lsay
	category = LOG_CATEGORY_ADMIN_LORE
	master_category = /datum/log_category/admin_private
	config_flag = /datum/config_entry/flag/log_lorechat
	secret = TRUE

/// log game events
/datum/config_entry/flag/log_lorechat
	protection = CONFIG_ENTRY_LOCKED

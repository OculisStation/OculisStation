//Blocks an attempt to connect before even creating our client datum thing.

/world/IsBanned(key, address, computer_id, type, real_bans_only=FALSE)
	debug_world_log("isbanned(): '[args.Join("', '")]'")
	if (!key || (!real_bans_only && (!address || !computer_id)))
		if(real_bans_only)
			return FALSE
		log_access("Failed Login (invalid data): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided invalid or blank information to the server on connection (byond username, IP, and Computer ID.) Provided information for reference: Username:'[key]' IP:'[address]' Computer ID:'[computer_id]'. (If you continue to get this error, please restart byond or contact byond support.)")

	if (type == "world")
		return ..() //shunt world topic banchecks to purely to byond's internal ban system

	var/admin = FALSE
	var/ckey = ckey(key)

	var/client/C = GLOB.directory[ckey]
	if (C && ckey == C.ckey && computer_id == C.computer_id && address == C.address)
		return //don't recheck connected clients.

	//IsBanned can get re-called on a user in certain situations, this prevents that leading to repeated messages to admins.
	var/static/list/checkedckeys = list()
	//magic voodo to check for a key in a list while also adding that key to the list without having to do two associated lookups
	var/message = !checkedckeys[ckey]++

	if(GLOB.admin_datums[ckey] || GLOB.deadmins[ckey])
		admin = TRUE

	// OCULIS EDIT ADDITION START - tracks byond versions in connection logs
	if (!real_bans_only)
		log_client_to_db_connection_log_manual(ckey, address, computer_id, "isbanned", type)
	// OCULIS EDIT ADDITION END
	/* NOVA EDIT REMOVAL START - We have the panic bunker on 24/7, this just makes our method unusable.
	if(!real_bans_only && !admin && CONFIG_GET(flag/panic_bunker) && !CONFIG_GET(flag/panic_bunker_interview))
		var/datum/db_query/query_client_in_db = SSdbcore.NewQuery(
			"SELECT 1 FROM [format_table_name("player")] WHERE ckey = :ckey",
			list("ckey" = ckey)
		)
		if(!query_client_in_db.Execute())
			qdel(query_client_in_db)
			return

		var/client_is_in_db = query_client_in_db.NextRow()
		if(!client_is_in_db)
			var/reject_message = "Failed Login: [ckey] [address]-[computer_id] - New Account attempting to connect during panic bunker, but was rejected due to no prior connections to game servers (no database entry)"
			log_access(reject_message)
			if (message)
				message_admins(span_adminnotice("[reject_message]"))
			qdel(query_client_in_db)
			return list("reason"="panicbunker", "desc" = "Sorry but the server is currently not accepting connections from never before seen players")

		qdel(query_client_in_db)
	*/ // NOVA EDIT REMOVAL END

	//Whitelist
	if(!real_bans_only && !C && CONFIG_GET(flag/usewhitelist))
		if(!check_whitelist(ckey))
			if (admin)
				log_admin("The admin [ckey] has been allowed to bypass the whitelist")
				if (message)
					message_admins(span_adminnotice("The admin [ckey] has been allowed to bypass the whitelist"))
					addclientmessage(ckey,span_adminnotice("You have been allowed to bypass the whitelist"))
			else
				log_access("Failed Login: [ckey] - Not on whitelist")
				return list("reason"="whitelist", "desc" = CONFIG_GET(string/missing_whitelist_message)) // NOVA EDIT CHANGE - SQL-based whitelist. ORIGINAL: return list("reason"="whitelist", "desc" = "\nReason: You are not on the white list for this server")

	//Guest Checking
	if(!real_bans_only && !C && is_guest_key(key))
		if (CONFIG_GET(flag/guest_ban))
			log_access("Failed Login: [ckey] - Guests not allowed")
			return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")
		if (CONFIG_GET(flag/panic_bunker) && SSdbcore.Connect())
			log_access("Failed Login: [ckey] - Guests not allowed during panic bunker")
			return list("reason"="guest", "desc"="\nReason: Sorry but the server is currently not accepting connections from never before seen players or guests. If you have played on this server with a byond account before, please log in to the byond account you have played from.")

	//Population Cap Checking
	var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
	if(!real_bans_only && !C && extreme_popcap && !admin)
		var/popcap_value = GLOB.clients.len
		if(popcap_value >= extreme_popcap && !GLOB.joined_player_list.Find(ckey))
			if(!CONFIG_GET(flag/byond_member_bypass_popcap) || !world.IsSubscribed(ckey, "BYOND"))
				log_access("Failed Login: [ckey] - Population cap reached")
				return list("reason"="popcap", "desc"= "\nReason: [CONFIG_GET(string/extreme_popcap_message)]")

	if(CONFIG_GET(flag/sql_enabled))
		if(!SSdbcore.Connect())
			var/msg = "Ban database connection failure. Key [ckey] not checked"
			log_world(msg)
			if (message)
				message_admins(msg)
		else
			var/list/ban_details = is_banned_from_with_details(ckey, address, computer_id, "Server")
			for(var/i in ban_details)
				if(admin)
					if(text2num(i["applies_to_admins"]))
						var/msg = "Admin [ckey] is admin banned, and has been disallowed access."
						log_admin(msg)
						if (message)
							message_admins(msg)
					else
						var/msg = "Admin [ckey] has been allowed to bypass a matching non-admin ban on [ckey(i["key"])] [i["ip"]]-[i["computerid"]]."
						log_admin(msg)
						if (message)
							message_admins(msg)
							addclientmessage(ckey,span_adminnotice("Admin [ckey] has been allowed to bypass a matching non-admin ban on [i["key"]] [i["ip"]]-[i["computerid"]]."))
						continue
				var/expires = "This is a permanent ban."
				if(i["expiration_time"])
					expires = " The ban is for [DisplayTimeText(text2num(i["duration"]) MINUTES)] and expires on [i["expiration_time"]] (server time)."
				var/desc = {"You, or another user of this computer or connection ([i["key"]]) is banned from playing here.
				The ban reason is: [i["reason"]]
				This ban (BanID #[i["id"]]) was applied by [i["admin_key"]] on [i["bantime"]] during round ID [i["round_id"]].
				[expires]"}
				log_suspicious_login("Failed Login: [ckey] [computer_id] [address] - Banned (#[i["id"]])")
				return list("reason"="Banned","desc"="[desc]")

	. = ..() //default pager ban stuff


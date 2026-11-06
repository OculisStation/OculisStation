GAME_VERB(/mob, irc_verb, "IRC", "IC")
	VERB_ARG(message, VERB_ARG_TYPE_MESSAGE, VERB_ARG_SOURCE_INPUT)
	var/obj/item/modular_computer/our_computer = irc_checks(message) // yeah our check returns a modular computer object, so what, HUH???
	if (!message || !our_computer)
		return

	if (!try_speak(message)) // ensure we pass the vibe check (filters, etc)
		return

	// we now have a modular computer and checks have promised us that it is a viable one, so use it
	//get the program reference from stored files
	var/datum/computer_file/program/chatclient/chat = locate() in our_computer.stored_files
	// let's just flub a UI_act, janky but keeps it all contained (this probably will not work)
	// really jank and we probably shouldn't do this (somehow it works)
	chat.ui_act("PRG_speak", list("message" = message), null, null)

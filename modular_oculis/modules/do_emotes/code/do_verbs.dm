/datum/keybinding/client/communication/do_emote
	hotkey_keys = list("K")
	name = DO_CHANNEL
	full_name = "Do"
	keybind_signal = COMSIG_KB_CLIENT_DO_DOWN

/datum/keybinding/client/communication/do_emote/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(DO_CHANNEL)];")
	winset(user, "tgui_say.browser", "focus=true")
	return TRUE

/datum/keybinding/client/communication/do_emote_longer
	hotkey_keys = list("CtrlK")
	name = "do_longer"
	full_name = "Do (Longer)"
	keybind_signal = COMSIG_KB_CLIENT_DO_LONGER_DOWN

/datum/keybinding/client/communication/do_emote_longer/down(client/user)
	. = ..()
	if(.)
		return
	if(GLOB.say_disabled) // This is here to try to identify lag problems
		to_chat(user, span_danger("Speech is currently admin-disabled."))
		return
	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(user.mob, TYPE_PROC_REF(/mob, emote), "do_emote"))
	return TRUE

GAME_VERB(/mob, do_verb, "Do", "IC")
	VERB_ARG(message, VERB_ARG_TYPE_MESSAGE, VERB_ARG_SOURCE_INPUT)
	if(GLOB.say_disabled) // This is here to try to identify lag problems
		to_chat(src, span_danger("Speech is currently admin-disabled."))
		return
	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(emote), "do_emote", NONE, message, TRUE), SSspeech_controller)

/datum/emote/living/do_emote
	key = "do_emote"
	key_third_person = "do_emote"
	message = null
	mob_type_blacklist_typecache = list(/mob/living/brain)
	emote_type = EMOTE_IMPORTANT

/datum/emote/living/do_emote/run_emote(mob/user, params, type_override, intentional)
	if(!can_run_emote(user))
		to_chat(user, span_warning("You can't emote at this time."))
		return FALSE
	if(SSdbcore.IsConnected() && is_banned_from(user, "Emote"))
		to_chat(user, span_warning("You cannot send emotes (banned)."))
		return FALSE
	else if(user.client?.prefs.muted & MUTE_IC)
		to_chat(user, span_warning("You cannot send IC messages (muted)."))
		return FALSE

	if(!params)
		user.client.start_thinking()
		message = tgui_input_text(user, "Write your do emote.", "Do Emote", null, max_length = MAX_MESSAGE_LEN, multiline = TRUE)
	else
		message = params

	user.client.stop_thinking()
	if(!message)
		return

	if(!user.try_speak(message, mute_bypass = TRUE)) // ensure we pass the vibe check (filters, etc)
		return

	var/name_stub = " (<b>[user]</b>)"
	message = trim(copytext_char(message, 1, (MAX_MESSAGE_LEN - length(name_stub))))
	var/message_with_name = message + name_stub

	user.log_message(message, LOG_EMOTE)

	var/list/viewers = get_hearers_in_view(DEFAULT_MESSAGE_RANGE, user)

	if(istype(user, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/ai = user
		viewers = get_hearers_in_view(DEFAULT_MESSAGE_RANGE, ai.eyeobj)

	var/obj/effect/overlay/holo_pad_hologram/hologram = GLOB.hologram_impersonators[user]
	if(hologram)
		viewers |= get_hearers_in_view(1, hologram)

	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(ai.client && !(ai in viewers) && (ai.eyeobj in viewers))
			viewers += ai

	for(var/mob/ghost as anything in GLOB.dead_mob_list)
		message_with_name = message + name_stub
		if((ghost.client?.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(ghost in viewers))
			to_chat(ghost, "[FOLLOW_LINK(ghost, user)] [span_emote(message_with_name)]")

	for(var/mob/receiver in viewers)
		message_with_name = message + name_stub
		receiver.show_message(span_emote(message_with_name), alt_msg = span_emote(message_with_name))
		if (receiver.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat))
			var/mob/living/silicon/ai/ai = user
			if(istype(user, /mob/living/silicon/ai) && (ai.eyeobj in viewers))
				receiver.create_chat_message(ai.eyeobj, null, message, null, EMOTE_MESSAGE)
			else
				receiver.create_chat_message(user, null, message, null, EMOTE_MESSAGE)

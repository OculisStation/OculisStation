/datum/hud
	/// UI for screentips that appear when you mouse over things
	/// Stored directly as it is used in very hot MouseEntered code
	var/atom/movable/screen/transmission/transmission_text = null

/datum/hud/New(mob/owner)
	. = ..()
	var/datum/preferences/preferences = owner?.client?.prefs
	if(preferences?.read_preference(/datum/preference/toggle/mapvote_hud))
		add_screen_object(/atom/movable/screen/mapvote_hud, HUD_MAPVOTE)

	transmission_text = add_screen_object(/atom/movable/screen/transmission, HUD_TRANSMISSION)

/datum/hud/Destroy()
	transmission_text = null
	return ..()

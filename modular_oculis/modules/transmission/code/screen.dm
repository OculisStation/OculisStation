/atom/movable/screen/transmission
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP,LEFT"
	maptext_height = 480
	maptext_width = 480
	maptext = ""
	layer = TUTORIAL_INSTRUCTIONS_LAYER //Added to make transmissions appear above screentips

/atom/movable/screen/transmission/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_view()

/atom/movable/screen/transmission/proc/update_view(datum/source)
	SIGNAL_HANDLER
	if(!hud || !hud.mymob.canon_client?.view_size) //Might not have been initialized by now
		return
	maptext_width = (view_to_pixels(hud.mymob.canon_client.view_size.getView())[1])



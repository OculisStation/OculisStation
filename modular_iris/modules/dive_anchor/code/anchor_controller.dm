/obj/machinery/computer/anchor_controller
	name = "anchor controller"
	desc = "Used to reposition dive anchors."
	icon_screen = "teleport"
	icon_keyboard = "mining_key"
	circuit = /obj/item/circuitboard/computer/anchor_controller
	///Dive anchor linked to this controller, connected using a multitool
	var/obj/machinery/dive_anchor/anchor
	///Message shown in the UI after a successful or unsuccessful action
	var/message = "Nothing to report."
	///Coordinate values used in the UI, we have to leave room for the transition zones on the space levels, hence starting at 10
	var/ui_x = 10
	var/ui_y = 10
	var/ui_z = 5

/obj/machinery/computer/anchor_controller/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	var/obj/item/multitool/multitool = tool
	if(!(multitool.buffer))
		balloon_alert(user, "buffer is empty")
		return ITEM_INTERACT_BLOCKING
	if(!(istype(multitool.buffer, /obj/machinery/dive_anchor)))
		balloon_alert(user, "buffered machine data is incompatible")
		return ITEM_INTERACT_BLOCKING
	if(istype(multitool.buffer, /obj/machinery/dive_anchor/stationary))
		balloon_alert(user, "[src] refuses the stationary anchor")
		return ITEM_INTERACT_BLOCKING
	anchor = multitool.buffer
	balloon_alert(user, "anchor linked successfully")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/anchor_controller/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AnchorController", name)
		ui.open()

/obj/machinery/computer/anchor_controller/ui_data(mob/user)
	var/list/data = list()
	data["anchor"] = "none connected"
	data["fuel"] = "unknown"
	if(anchor)
		data["anchor"] = anchor.designation
		data["fuel"] = anchor.fuel_charges
	data["x_coord"] = ui_x
	data["y_coord"] = ui_y
	data["z_coord"] = ui_z
	data["message"] = message
	return data

/obj/machinery/computer/anchor_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("adjust-x")
			ui_x = clamp(params["new_x"], 10, 245)
			return TRUE
		if("adjust-y")
			ui_y = clamp(params["new_y"], 10, 245)
			return TRUE
		if("adjust-z")
			ui_z = clamp(params["new_z"], 5, 11) //unreserved z-levels only
			return TRUE
		if("send-home")
			if(!anchor)
				message = "Error: no anchor linked - link one to proceed."
				return
			if(!anchor.home_location)
				message = "Error: linked anchor has no home location - divine intervention required."
				return
			var/turf/home_turf = get_turf(anchor.home_location)
			if(home_turf.is_blocked_turf())
				message = "Error: home location obstructed - remove obstruction and try again."
				return
			anchor.trigger_relocate(home_turf, FALSE)
			message = "Success: anchor moved to home location."
			return TRUE
		if("launch-to-coords")
			if(!anchor)
				message = "Error: no anchor linked - link one to proceed."
				return
			if(anchor.fuel_charges <= 0)
				message = "Error: insufficient fuel for journey - refuel anchor."
				return
			var/turf/target_turf = locate(ui_x, ui_y, ui_z)
			if(!is_spaceruins_level(target_turf.z))
				message = "Error: strange energy detected - try alternative Z coordinate."
				return
			if(!istype(target_turf, /turf/open/space) || target_turf.is_blocked_turf())
				message = "Error: target location obstructed - try alternative location."
				return
			anchor.trigger_relocate(target_turf)
			message = "Success: anchor moved to input coordinates."
			return TRUE

/obj/item/circuitboard/computer/anchor_controller
	name = "Anchor Controller"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/anchor_controller

/datum/design/board/anchor_controller
	name = "Anchor Controller Board"
	desc = "Allows for the construction of circuit boards used to build anchor controllers."
	build_path = /obj/item/circuitboard/computer/anchor_controller
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/techweb_node/dive_anchors
	display_name = "Dive Anchor Controllers"
	description = "Technology for remote control of the spatial manipulation capabilities of dive anchors."
	prerequisite_nodes = list(/datum/techweb_node/consoles)
	unlocked_designs = list(/datum/design/board/anchor_controller)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

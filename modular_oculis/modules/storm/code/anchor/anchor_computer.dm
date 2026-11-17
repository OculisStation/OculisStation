/obj/item/circuitboard/computer/redspace_anchor_control
	name = "Redspace Anchor Control"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/redspace_anchor_computer
	custom_materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 2)

/datum/design/redspace_anchor_computer
	name = "Redspace Anchor Controller"
	desc = "Can be used to toggle and discharge connected redspace anchors."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/gold =SMALL_MATERIAL_AMOUNT * 2)
	build_path = /obj/item/circuitboard/computer/redspace_anchor_control
	category = list(
		RND_SUBCATEGORY_COMPUTER_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/obj/machinery/computer/redspace_anchor_computer
	name = "redspace anchor control computer"
	desc = "Used to control the redspace anchor."
	icon_screen = "comm"
	circuit = /obj/item/circuitboard/computer/redspace_anchor_control
	var/obj/machinery/redspace_anchor/connected_anchor = null

/obj/machinery/computer/redspace_anchor_computer/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	update_appearance()
	if(mapload)
		connect_to_anchor()

/obj/machinery/computer/redspace_anchor_computer/Destroy(force)
	connected_anchor = null
	return ..()

/obj/machinery/computer/redspace_anchor_computer/update_overlays()
	if(connected_anchor?.breaker)
		icon_screen = "comm"
	else
		icon_screen = "syndishuttle"
	return ..()

/obj/machinery/computer/redspace_anchor_computer/ui_status(mob/user, datum/ui_state/state)
	if(HAS_SILICON_ACCESS(user) && connected_anchor?.ai_disabled)
		to_chat(user, span_info("AI control has been disabled."))
	else if(!connected_anchor?.shorted)
		return ..()
	return UI_CLOSE

/obj/machinery/computer/redspace_anchor_computer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RedspaceAnchor", name)
		ui.open()

/obj/machinery/computer/redspace_anchor_computer/ui_data(mob/user)
	var/list/data = list()
	if(!connected_anchor)
		data["no_anchor"] = TRUE
		return data
	data["breaker"] = connected_anchor.breaker
	data["charge_count"] = connected_anchor.charge_count
	data["charging_state"] = connected_anchor.charging_state
	data["on"] = connected_anchor.current_state >= 2 ? TRUE : FALSE
	data["operational"] = (connected_anchor.machine_stat & BROKEN) ? FALSE : TRUE
	data["violetspace_energy"] = connected_anchor.violetspace_energy
	return data

/obj/machinery/computer/redspace_anchor_computer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("gentoggle")
			connected_anchor.breaker = !connected_anchor.breaker
			investigate_log("was toggled [connected_anchor.breaker ? "<font color='green'>ON</font>" : "<font color='red'>OFF</font>"] by [key_name(usr)].", INVESTIGATE_ENGINE)
			if(connected_anchor.violetspace_energy)
				connected_anchor.trigger_unsafe_discharge()
				investigate_log("was overloaded by remaining violetspace energy.", INVESTIGATE_ENGINE)
			connected_anchor.set_power()
			update_appearance()
			. = TRUE
		if("discharge_violetspace")
			if(connected_anchor.violetspace_energy && connected_anchor.can_discharge)
				investigate_log("has discharged violetspace energy by [key_name(usr)].", INVESTIGATE_ENGINE)
				connected_anchor.trigger_safe_discharge()
				. = TRUE

/obj/machinery/computer/redspace_anchor_computer/proc/connect_to_anchor()
	for(var/obj/machinery/redspace_anchor/anchor as anything in SSmachines.get_machines_by_type(/obj/machinery/redspace_anchor))
		if(anchor.z == z)
			connected_anchor = anchor

/obj/machinery/computer/redspace_anchor_computer/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	var/obj/item/multitool/multitool = tool
	if(!(multitool.buffer))
		balloon_alert(user, "buffer is empty")
		return ITEM_INTERACT_BLOCKING
	if(!(istype(multitool.buffer, /obj/machinery/redspace_anchor)))
		balloon_alert(user, "buffered machine data is incompatible")
		return ITEM_INTERACT_BLOCKING
	connected_anchor = multitool.buffer
	balloon_alert(user, "anchor linked successfully")
	return ITEM_INTERACT_SUCCESS

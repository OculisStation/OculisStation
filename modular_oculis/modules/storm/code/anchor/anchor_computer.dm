/obj/item/circuitboard/computer/redspace_anchor_control
	name = "Redspace Anchor Control"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/redspace_anchor_computer

/obj/machinery/computer/redspace_anchor_computer
	name = "redspace anchor control computer"
	desc = "Used to control the redspace anchor."
	icon_screen = "comm"
	circuit = /obj/item/circuitboard/computer/redspace_anchor_control
	var/obj/machinery/redspace_anchor/connected_anchor = null

/obj/machinery/computer/redspace_anchor_computer/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	for(var/obj/machinery/redspace_anchor/anchor as anything in SSmachines.get_machines_by_type(/obj/machinery/redspace_anchor))
		if(anchor.z == z)
			connected_anchor = anchor
	update_appearance()

/obj/machinery/computer/redspace_anchor_computer/update_overlays()
	if(connected_anchor?.breaker)
		icon_screen = "comm"
	else
		icon_screen = "syndishuttle"
	. = ..()

/obj/machinery/computer/redspace_anchor_computer/ui_status(mob/user, datum/ui_state/state)
	if(HAS_SILICON_ACCESS(user) && connected_anchor.ai_disabled)
		to_chat(user, span_info("AI control has been disabled."))
	else if(!connected_anchor.shorted)
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
	data["breaker"] = connected_anchor.breaker
	data["charge_count"] = connected_anchor.charge_count
	data["charging_state"] = connected_anchor.charging_state
	data["on"] = connected_anchor.online
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
			. = TRUE
		if("discharge_violetspace")
			if(connected_anchor.violetspace_energy && connected_anchor.can_discharge)
				investigate_log("has discharged violetspace energy by [key_name(usr)].", INVESTIGATE_ENGINE)
				connected_anchor.trigger_safe_discharge()
				. = TRUE

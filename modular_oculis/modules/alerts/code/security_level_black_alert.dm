/**
 * Black
 *
 * Imminent Storm Surge. Between Delta and Red alert.
 */
/datum/security_level/black
	name = "black"
	name_shortform = "BLCK"
	announcement_color = "purple"
	number_level = SEC_LEVEL_BLACK
	status_display_icon_state = "blackalert"
	fire_alarm_light_color = COLOR_SAMPLE_PURPLE
	lowering_to_configuration_key = /datum/config_entry/string/alert_black_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_black_upto
	sound = 'modular_oculis/modules/alerts/sounds/black_alert.ogg'
	shuttle_call_time_mod = 999999 // No shuttles for you.

/datum/config_entry/string/alert_black_upto
	config_entry_value = "A sector wide Storm-Surge event is in progress. All stations are to engage lockdown protocols. All extravehicular activity is to be immediately halted. Communications and shuttle usage have been disabled by the ongoing event. Security may have weapons unholstered at all times. Random searches are allowed and advised."

// Not really supposed to move it down to black alert.
/datum/config_entry/string/alert_black_downto
	config_entry_value = "A sector wide Storm-Surge event is in progress. All stations are to engage lockdown protocols. All extravehicular activity is to be immediately halted. Communications and shuttle usage have been disabled by the ongoing event. Security may have weapons unholstered at all times. Random searches are allowed and advised."

// Now to do the things black alert does.
/datum/controller/subsystem/shuttle/Initialize()
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_sec_level_change))
	. = ..()

/datum/controller/subsystem/shuttle/proc/on_sec_level_change(datum/source, new_level)
	SIGNAL_HANDLER

	if(new_level == SEC_LEVEL_BLACK)
		deactivate_shuttles()
	else
		reactivate_shuttles()

/datum/controller/subsystem/shuttle/proc/deactivate_shuttles()
	SSshuttle.emergency_no_escape = TRUE
	// Now for the individual shuttles.
	for(var/obj/docking_port/mobile/shuttle in SSshuttle.mobile_docking_ports)
		shuttle.mode = SHUTTLE_DISABLED
	registerTradeBlockade("BLACK_ALERT")
	registerHostileEnvironment("BLACK_ALERT")

/datum/controller/subsystem/shuttle/proc/reactivate_shuttles()
	SSshuttle.emergency_no_escape = FALSE
	for(var/obj/docking_port/mobile/shuttle in SSshuttle.mobile_docking_ports)
		shuttle.mode = SHUTTLE_IDLE
	clearTradeBlockade("BLACK_ALERT")
	clearHostileEnvironment("BLACK_ALERT")

/obj/machinery/telecomms/receiver/check_receive_level(datum/signal/subspace/signal)
	var/current_alert_level = SSsecurity_level.get_current_level_as_number()
	if(current_alert_level == SEC_LEVEL_BLACK)
		return FALSE // Can't get signals during black alert.
	return ..()

/obj/machinery/light/Initialize(mapload)
	. = ..()
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_sec_level_change))

/obj/machinery/light/proc/on_sec_level_change(datum/source, new_level)
	SIGNAL_HANDLER

	if(new_level == SEC_LEVEL_BLACK)
		set_major_emergency_light()
	else
		unset_major_emergency_light()

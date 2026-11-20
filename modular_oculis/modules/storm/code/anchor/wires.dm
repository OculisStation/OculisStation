/datum/wires/redspace_anchor
	holder_type = /obj/machinery/redspace_anchor
	proper_name = "Redspace Anchor"

/datum/wires/redspace_anchor/New(atom/holder)
	wires = list(
		WIRE_POWER1,
		WIRE_POWER2,
		WIRE_POWER3,
		WIRE_POWER4,
		WIRE_POWER5,
		WIRE_AI,
		WIRE_ALARM,
		WIRE_DISCHARGE,
		WIRE_ACTIVATION1,
		WIRE_ACTIVATION2,
		WIRE_ACTIVATION3,
	)
	add_duds(6) // It's a complicated machine. It's gonna have lots of wires.
	..()

/datum/wires/redspace_anchor/interactable(mob/user)
	if(!..())
		return FALSE
	return TRUE

/datum/wires/redspace_anchor/get_status()
	var/obj/machinery/redspace_anchor/anchor = holder
	var/list/status = list()
	status += "The short indicator is [anchor.shorted ? "lit" : "off"]."
	status += "The AI connection light is [!anchor.ai_disabled ? "on" : "off"]."
	status += "The alarm light is [!anchor.alarm_disabled ? "on" : "off"]."
	status += "There [anchor.activation_codes == 1 ? "is" : "are"] [anchor.activation_codes] activation [anchor.activation_codes == 1 ? "light" : "lights"] active."
	return status

/datum/wires/redspace_anchor/on_pulse(wire)
	var/obj/machinery/redspace_anchor/anchor = holder
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2, WIRE_POWER3, WIRE_POWER4, WIRE_POWER5) // Short out for a long time.
			if(!anchor.shorted)
				anchor.shorted = TRUE
				anchor.breaker_toggle(FALSE)
				anchor.update_appearance()
			addtimer(CALLBACK(anchor, TYPE_PROC_REF(/obj/machinery/redspace_anchor, reset), wire), 2 MINUTES)
		if(WIRE_AI) // Disable AI control for a while.
			if(!anchor.ai_disabled)
				anchor.ai_disabled = TRUE
			addtimer(CALLBACK(anchor, TYPE_PROC_REF(/obj/machinery/redspace_anchor, reset), wire), 10 SECONDS)
		if(WIRE_ALARM)
			if(!anchor.alarm_disabled)
				anchor.alarm_disabled = TRUE
			addtimer(CALLBACK(anchor, TYPE_PROC_REF(/obj/machinery/redspace_anchor, reset), wire), 10 SECONDS)
		if(WIRE_DISCHARGE)
			if(anchor.can_discharge && anchor.violetspace_energy)
				anchor.trigger_safe_discharge()
		// Give the hacker a little puzzle to solve to make everyone get violently flung.
		if(WIRE_ACTIVATION1)
			if(anchor.activation_codes == 0)
				anchor.activation_codes = 1
			else
				anchor.activation_codes = 0
		if(WIRE_ACTIVATION2)
			if(anchor.activation_codes == 1)
				anchor.activation_codes = 2
			else
				anchor.activation_codes = 0
		if(WIRE_ACTIVATION3)
			if(anchor.activation_codes == 2)
				if(anchor.current_state == POWER_STATE_ACTIVE)
					anchor.deactivate()
				else if(anchor.current_state == POWER_STATE_PASSIVE)
					anchor.activate()
			anchor.activation_codes = 0

/datum/wires/redspace_anchor/on_cut(wire, mend, source)
	var/obj/machinery/redspace_anchor/anchor = holder
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2, WIRE_POWER3, WIRE_POWER4, WIRE_POWER5)
			anchor.shorted = !mend
			if(anchor.shorted)
				anchor.breaker_toggle(FALSE)
		if(WIRE_AI)
			anchor.ai_disabled = !mend // Enable/disable AI control.
		if(WIRE_ALARM)
			anchor.alarm_disabled = !mend
		if(WIRE_DISCHARGE)
			anchor.can_discharge = mend
		if(WIRE_ACTIVATION1, WIRE_ACTIVATION2, WIRE_ACTIVATION3)
			anchor.can_activate = mend

/datum/wires/redspace_anchor/can_reveal_wires(mob/user)
	if(HAS_TRAIT(user, TRAIT_KNOW_CE_WIRES))
		return TRUE
	return ..()

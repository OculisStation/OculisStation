GLOBAL_LIST_INIT(global_resforms, subtypesof(/mob/living/simple_animal/formic))

/obj/machinery/contactscanner
	name = "formic scanner array"
	icon = 'modular_oculis/modules/contact_science/icons/contact_equipment.dmi'
	icon_state = "contactscanner_off"
	base_icon_state = "contactscanner"
	desc = "A scanning array used for contacting anomalous resonance forms within the Storm. Uses bluespace crystals as fuel, and must be linked to a contact platform."
	circuit = /obj/item/circuitboard/machine/contactscanner
	var/fuel = 0
	var/operation_time = 6
	var/obj/machinery/contactplatform/linkedplatform
	var/contact_scanning = FALSE
	var/active_contact = FALSE
	var/mob/living/simple_animal/formic/contacted_form
	var/scanning_time = 0

/obj/machinery/contactscanner/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "[base_icon_state]_open"
	else if(contact_scanning)
		icon_state = "[base_icon_state]_ready"
	else if(active_contact)
		icon_state = "[base_icon_state]_locked"
	else
		icon_state = "[base_icon_state]_off"
	if(linkedplatform)
		linkedplatform.update_icon_state()

/obj/machinery/contactscanner/RefreshParts()
	. = ..()
	var/energy_rating = 0
	var/efficiency_rating = 0
	for(var/datum/stock_part/part in component_parts)
		energy_rating += part.energy_rating()
		efficiency_rating += part.tier * 0.1

	for(var/obj/item/stock_parts/part in component_parts)
		energy_rating += part.energy_rating

	idle_power_usage = initial(idle_power_usage) * (energy_rating/8)
	active_power_usage = initial(active_power_usage) * (energy_rating/8)
	update_current_power_usage()

	operation_time = initial(operation_time) - efficiency_rating

/obj/machinery/contactscanner/screwdriver_act(mob/user, obj/item/tool)
	if(!active_contact && !contact_scanning) //can only do when not active
		return default_deconstruction_screwdriver(user, tool)
	else
		balloon_alert(user, "deactivate first!")
		return ITEM_INTERACT_FAILURE

/obj/machinery/contactscanner/crowbar_act(mob/user, obj/item/tool)
	if(!active_contact && !contact_scanning) //can only do when not active
		return default_deconstruction_crowbar(user, tool)
	else
		balloon_alert(user, "deactivate first!")
		return ITEM_INTERACT_FAILURE

/obj/machinery/contactscanner/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!active_contact && !contact_scanning) //can only do when not active
		default_unfasten_wrench(user, tool, time = 1 SECONDS)
		return ITEM_INTERACT_SUCCESS
	else
		balloon_alert(user, "deactivate first!")
		return ITEM_INTERACT_FAILURE

/obj/machinery/contactscanner/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	if(panel_open)
		multi_tool.set_buffer(src)
		balloon_alert(user, "saved to multitool buffer")
		to_chat(user, span_notice("You save the data in [multi_tool] buffer. The data can now be linked with a contact platform."))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/contactscanner/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(!istype(tool, /obj/item/stack/ore/bluespace_crystal))
		return NONE
	var/obj/item/stack/ore/bluespace_crystal/fuel_fed = tool
	fuel += fuel_fed.amount
	balloon_alert(user, "fueled")
	user.visible_message("[user] fuels [src] with [fuel_fed].")
	qdel(fuel_fed)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/contactscanner/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	//failed interactions
	if(panel_open)
		return
	if(!linkedplatform)
		audible_message(span_warning("Scanner non-functional; link this scanner to a contact platform first!"))
		visible_message(span_warning("A red diagnostic light blinks on [src]."))
		return
	if(fuel == 0 && !active_contact) //engaging contact takes fuel, make sure it can be shut down without requiring fuel via the !active_contact condition
		audible_message(span_warning("Scanner non-functional; no fuel detected, insert bluespace crystals!"))
		visible_message(span_warning("A blue diagnostic light blinks on [src]."))
		return
	if(contact_scanning)
		audible_message(span_warning("Scanner already operating; it can only be cancelled once operation is complete!"))
		visible_message(span_warning("A green diagnostic light blinks on [src]."))
		return

	//successful interactions
	if(active_contact) //shut down contact
		if(contacted_form.breaching)
			balloon_alert(user, "can't shut it down!")
			return ITEM_INTERACT_FAILURE
		balloon_alert(user, "contact shutting down!")
		if(do_after(user, operation_time SECONDS, src))
			use_power = IDLE_POWER_USE
			active_contact = FALSE
			contacted_form.stop_everything()
			qdel(contacted_form)
			update_icon_state()
			return ITEM_INTERACT_SUCCESS
	else //engage contact
		scanning_time = 0
		use_power = ACTIVE_POWER_USE
		contact_scanning = TRUE
		update_icon_state()
		balloon_alert(user, "scanning for contact signal!")
		return ITEM_INTERACT_SUCCESS

/obj/machinery/contactscanner/proc/summon_forth()
	fuel -= 1
	active_contact = TRUE
	contact_scanning = FALSE
	linkedplatform.summon_formic()
	update_icon_state()

/obj/machinery/contactscanner/proc/fail_spawn()
	audible_message(span_warning("Contact failed, bringing forward a hostile creature instead!"))
	visible_message(span_warning("A yellow diagnostic light blinks on [src]."))
	active_contact = FALSE
	use_power = IDLE_POWER_USE
	update_icon_state()
	return

/obj/machinery/contactscanner/process(seconds_per_tick)
	if(contact_scanning)
		scanning_time += seconds_per_tick
		if(scanning_time >= operation_time * 2)
			summon_forth()
	if(active_contact && QDELETED(contacted_form))
		use_power = IDLE_POWER_USE
		active_contact = FALSE
		update_icon_state()

/obj/item/circuitboard/machine/contactscanner
	name = "Formic Scanner"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/contactscanner
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/obj/item/stack/ore/bluespace_crystal = 1,
		/datum/stock_part/micro_laser = 3,
		/datum/stock_part/scanning_module = 3)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/machinery/contactplatform
	name = "contact platform"
	icon = 'modular_oculis/modules/contact_science/icons/contact_equipment.dmi'
	icon_state = "contactpad_off"
	base_icon_state = "contactpad"
	desc = "A device used to summon forth anomalous resonance forms from the Storm via use of a formic scanner."
	circuit = /obj/item/circuitboard/machine/contactplatform
	var/obj/machinery/contactscanner/linkedscanner
	var/failure_chance = 10

/obj/machinery/contactplatform/crowbar_act(mob/user, obj/item/tool)
	return default_deconstruction_crowbar(user, tool)

/obj/machinery/contactplatform/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 1 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/contactplatform/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	if(istype(multi_tool.buffer, /obj/machinery/contactscanner))
		linkedscanner = multi_tool.buffer
		linkedscanner.linkedplatform = (src)
		balloon_alert(user, "data uploaded from buffer")
		return ITEM_INTERACT_SUCCESS

/obj/machinery/contactplatform/RefreshParts()
	. = ..()
	var/energy_rating = 0
	var/efficiency_rating = 0
	for(var/datum/stock_part/part in component_parts)
		energy_rating += part.energy_rating()
		efficiency_rating += part.tier

	for(var/obj/item/stock_parts/part in component_parts)
		energy_rating += part.energy_rating

	idle_power_usage = initial(idle_power_usage) * (energy_rating/8)
	active_power_usage = initial(active_power_usage) * (energy_rating/8)
	update_current_power_usage()

	failure_chance = initial(failure_chance) - efficiency_rating

/obj/machinery/contactplatform/proc/summon_formic()
	if(prob(failure_chance)) //fail, spawning random hostile mob instead of resonance form. can be prevented with part upgrades
		create_random_mob(get_turf(src), HOSTILE_SPAWN)
		linkedscanner.fail_spawn()
		return
	else //spawn resonance form here
		var/chosen
		chosen = pick(GLOB.global_resforms)
		var/mob/living/simple_animal/formic/spawnedform = new chosen(get_turf(src))
		do_sparks(3, FALSE, get_turf(src))
		linkedscanner.contacted_form = spawnedform
		return

/obj/machinery/contactplatform/update_icon_state()
	. = ..()
	if(linkedscanner)
		if(linkedscanner.active_contact)
			icon_state = "[base_icon_state]_locked"
		else if(linkedscanner.contact_scanning)
			icon_state = "[base_icon_state]_ready"
		else
			icon_state = "[base_icon_state]_off"
	else
		icon_state = "[base_icon_state]_off"

/obj/item/circuitboard/machine/contactplatform
	name = "Contact Platform"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/contactplatform
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/datum/stock_part/capacitor = 2,
		/datum/stock_part/scanning_module = 2)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/contactanalyzer
	name = "formic analyzer"
	desc = "A hand-held resonance scanner which establishes a speech link with anomalous resonance forms and compares their properties with a Nanotrasen database."
	icon = 'modular_oculis/modules/contact_science/icons/contact_equipment.dmi'
	icon_state = "contactremote"
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 0.3, /datum/material/glass=SMALL_MATERIAL_AMOUNT * 0.2)
	interaction_flags_click = NEED_LITERACY|NEED_LIGHT|ALLOW_RESTING
	pickup_sound = 'sound/items/handling/gas_analyzer/gas_analyzer_pickup.ogg'
	drop_sound = 'sound/items/handling/gas_analyzer/gas_analyzer_drop.ogg'

	var/scan_distance = 5
	var/last_scanned

/obj/item/contactanalyzer/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /mob/living/simple_animal/formic) && can_see(user, interacting_with, scan_distance) && do_after(user, 2 SECONDS, src))
		var/mob/living/simple_animal/formic/analyzed_mob = interacting_with
		analyze_form(analyzed_mob, user)
		return ITEM_INTERACT_SUCCESS

/obj/item/contactanalyzer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /mob/living/simple_animal/formic) && can_see(user, interacting_with, scan_distance) && do_after(user, 2 SECONDS, src))
		var/mob/living/simple_animal/formic/analyzed_mob = interacting_with
		analyze_form(analyzed_mob, user)
		return ITEM_INTERACT_SUCCESS

/obj/item/contactanalyzer/proc/analyze_form(mob/living/simple_animal/formic/analyzed_form, mob/living/user)
	playsound(user, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
	user.visible_message(span_notice("[user] uses the formic analyzer on [icon2html(icon, viewers(user))] [analyzed_form]."), span_notice("You use the formic analyzer on [icon2html(icon, user)] [analyzed_form]."))
	var/message = list()

	message += span_notice("<b>" + analyzed_form.nanotrasen_id + "</b>: " + analyzed_form.name)
	message += span_notice("<b>Primary Hazard Label(s):</b> " + analyzed_form.primary_hazard_labels)
	message += span_notice("<b>Secondary Hazard Label(s):</b> " + analyzed_form.secondary_hazard_labels)
	message += span_notice("<b>Database Description:</b> " + analyzed_form.hidden_description)
	message += span_notice("<b>Detected Echoes:</b>")
	for(var/echo in analyzed_form.echoes)
		message += span_notice("'" + echo + "'")

	to_chat(user, boxed_message(jointext(message, "\n")), type = MESSAGE_TYPE_INFO)
	analyzed_form.establish_link(user)
	last_scanned = analyzed_form

/obj/item/contactresonator
	name = "contact resonator"
	desc = "A hand-held resonator which scans anomalous resonance forms for data which may otherwise be undetectable."
	icon = 'modular_oculis/modules/contact_science/icons/contact_equipment.dmi'
	icon_state = "resonator"
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_SUITSTORE
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 0.3, /datum/material/glass=SMALL_MATERIAL_AMOUNT * 0.2)
	interaction_flags_click = NEED_LITERACY|NEED_LIGHT|ALLOW_RESTING
	pickup_sound = 'sound/items/handling/gas_analyzer/gas_analyzer_pickup.ogg'
	drop_sound = 'sound/items/handling/gas_analyzer/gas_analyzer_drop.ogg'

	var/scan_distance = 5

/obj/item/contactresonator/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /mob/living/simple_animal/formic) && can_see(user, interacting_with, scan_distance) && do_after(user, 2 SECONDS, src))
		var/mob/living/simple_animal/formic/analyzed_mob = interacting_with
		resonate_form(analyzed_mob, user)
		return ITEM_INTERACT_SUCCESS

/obj/item/contactresonator/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /mob/living/simple_animal/formic) && can_see(user, interacting_with, scan_distance) && do_after(user, 2 SECONDS, src))
		var/mob/living/simple_animal/formic/analyzed_mob = interacting_with
		resonate_form(analyzed_mob, user)
		return ITEM_INTERACT_SUCCESS

/obj/item/contactresonator/proc/resonate_form(mob/living/simple_animal/formic/analyzed_form, mob/living/user)
	playsound(user, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
	user.visible_message(span_notice("[user] uses the contact resonator on [icon2html(icon, viewers(user))] [analyzed_form]."), span_notice("You use the contact resonator on [icon2html(icon, user)] [analyzed_form]."))
	to_chat(user, boxed_message(jointext(analyzed_form.resonate_info(), "\n")), type = MESSAGE_TYPE_INFO)

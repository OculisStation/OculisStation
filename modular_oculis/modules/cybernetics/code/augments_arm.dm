/obj/item/organ/cyberimp/arm/wristwatch
	name = "internal chronometer"
	desc = "This relatively simple implant consists of a microchip and small flexible display embedded into the wrist, allowing the user to easily tell the date and time anywhere."
	special_desc = "These things are not made for telling the time. They are <i>very good clocks</i>, of course, but you don't get one because you're habitually late to meetings. One installs an internal, cybernetic, wrist-formed, digital clock as visible testament to the fact that they value their time high enough (and more importantly, yours <i>low</i> enough) to turn their timekeeping device into a permanent fixture of their body. Makes a great statement if you're talking to the type who's intimidated by that kind of sordid banality."
	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_WRISTWATCH_R
	valid_zones = list(
		BODY_ZONE_R_ARM = ORGAN_SLOT_WRISTWATCH_R,
		BODY_ZONE_L_ARM = ORGAN_SLOT_WRISTWATCH_L,
	)
	actions_types = list(/datum/action/item_action/organ_action/use)
	icon = 'modular_oculis/modules/cybernetics/icons/newcybers.dmi'
	icon_state = "internalchronometer"
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 3,
	)

/obj/item/organ/cyberimp/arm/wristwatch/ui_action_click(mob/user, actiontype)
	if(organ_flags & ORGAN_FAILING)
		owner.visible_message(span_notice("[owner] glances at [owner.p_their()] wrist."), span_warning("You glance at [src]. The time is @#*%&^% and 999999999 seconds. The date, apparently, is DAYNOTFOUNDday, Febuary 30rd, The Year Of The Staphylococcus Aureus Bacterium. Enlightening."))
		return
	var/thetime = span_notice("You glance at [src]. The time is [server_timestamp(format = "hh:mm and ss seconds. The date is DDD, MMM DD, YYYY.", ic_time = TRUE, twelve_hour_clock = owner.client?.prefs.read_preference(/datum/preference/toggle/twelve_hour))]")
	owner.visible_message(span_notice("[owner] glances at [owner.p_their()] wrist."), thetime)

/obj/item/organ/cyberimp/arm/wristwatch/emp_act(severity)
	. = ..()
	if((organ_flags & ORGAN_FAILING) || . & EMP_PROTECT_SELF)
		return
	organ_flags |= ORGAN_FAILING
	to_chat(owner, span_warning("Internal chronometer timing systems disrupted!"))
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/cyberimp/arm/wristwatch/proc/reboot()
	organ_flags &= ~ORGAN_FAILING
	to_chat(owner, span_notice("Internal chronometer resynchronized."))


/obj/item/organ/cyberimp/arm/wristwatch/left
	zone = BODY_ZONE_L_ARM
	slot = ORGAN_SLOT_WRISTWATCH_L

/datum/augment_item/implant/wristwatch
	name = "Internal Chronometer"
	extra_info = "Tells the time."
	cost = 2
	path = /obj/item/organ/cyberimp/arm/wristwatch
	slot = AUGMENT_SLOT_R_ARM

/datum/augment_item/implant/wristwatch/left
	path = /obj/item/organ/cyberimp/arm/wristwatch/left
	slot = AUGMENT_SLOT_L_ARM

/datum/design/wristwatch
	name = "Internal Chronometer"
	desc = "Simple cybernetic that turns your wrist itself into a wristwatch, so that you can tell the time anywhere, anytime."
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 6 SECONDS
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 3,
	)
	build_path = /obj/item/organ/cyberimp/arm/wristwatch
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/techweb_node/wristwatch
	display_name = "Biomorphological Tempotechnics"
	description = "Timetelling in the age of cybernetic enhancement."
	prerequisite_nodes = list(/datum/techweb_node/cyber/cyber_implants, /datum/techweb_node/holographics)
	unlocked_designs = list(/datum/design/wristwatch)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SERVICE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SCIENCE)

/obj/item/organ/cyberimp/arm/slap
	name = "subdermal ligature attachment package"
	desc = "This palm-implanted cybernetic device uses programmatically controlled nanomechanical bindings to reduce hand injuries by increasing the rigidity and durability of the skin on detection of applied force."
	special_desc = "Such that when you, say, <b>bitch-slap some asshole</b>, it hurts. <b>Badly.</b> The manufacturers would never <i>admit</i> this, of course, because this is a <i>perfectly harmless occupational aid</i> (they say) for cooks and warehouse techs and tradesmen, not people who get assault charges. This somewhat unmarketable fact remains a known selling point nontheless, as such things tend to in cybernetics circles."
	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_WRISTWATCH_R
	valid_zones = list(
		BODY_ZONE_R_ARM = ORGAN_SLOT_PALM_R,
		BODY_ZONE_L_ARM = ORGAN_SLOT_PALM_L,
	)
	icon = 'modular_oculis/modules/cybernetics/icons/newcybers.dmi'
	icon_state = "subdermalligatureattachmentpackage"
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 3,
	)

/datum/design/slapcybernetic
	name = "S.L.A.P."
	desc = "Palm-implanted dermal reinforcement ligatures to increase the durability of the hands."
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 6 SECONDS
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 3,
	)
	build_path = /obj/item/organ/cyberimp/arm/slap
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/techweb_node/slapbooster
	display_name = "Nanomechatronic Bioligatures"
	description = "Peace through Power. Power through really fancy tiny zipties."
	prerequisite_nodes = list(/datum/techweb_node/cyber/cyber_implants, /datum/techweb_node/bio_scan, /datum/techweb_node/sec_equip)
	unlocked_designs = list(/datum/design/slapcybernetic)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SERVICE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SCIENCE)
	discount_experiments = list(/datum/experiment/physical/slap_someone = TECHWEB_TIER_1_POINTS/2)

/datum/augment_item/implant/slapbooster
	name = "Subdermal Ligature Attachment Package"
	extra_info = "Makes slapping with the respective hand into a nonlethal weapon."
	cost = 6
	path = /obj/item/organ/cyberimp/arm/slap
	slot = AUGMENT_SLOT_R_ARM

/datum/augment_item/implant/slapbooster/left
	path = /obj/item/organ/cyberimp/arm/slap/left
	slot = AUGMENT_SLOT_L_ARM

/obj/item/organ/cyberimp/arm/slap/left
	zone = BODY_ZONE_L_ARM
	slot = ORGAN_SLOT_PALM_L

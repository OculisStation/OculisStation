/obj/item/organ/cyberimp/mouth/tastebooster
	name = "gustatory hypersensitizer"
	desc = "This cybernetic implant increases the taste sensitivity of the implantee."
	special_desc = "And massively so. Maybe cut back on the spices if you get one of these."
	w_class = WEIGHT_CLASS_TINY
	slot = ORGAN_SLOT_TASTEBOOSTER
	icon = 'modular_oculis/modules/cybernetics/icons/newcybers.dmi'
	icon_state = "gustatoryhypersensitizer"
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 2,
	)

/obj/item/organ/cyberimp/mouth/tastebooster/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	RegisterSignal(organ_owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(add_boost))
	RegisterSignal(organ_owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(remove_boost))
	var/obj/item/organ/tongue/thetongue = organ_owner.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(istype(thetongue))
		thetongue.taste_sensitivity = 1

/obj/item/organ/cyberimp/mouth/tastebooster/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	UnregisterSignal(organ_owner, list(
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_CARBON_LOSE_ORGAN))
	var/obj/item/organ/tongue/thetongue = organ_owner.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(istype(thetongue))
		thetongue.taste_sensitivity = initial(thetongue.taste_sensitivity)

/obj/item/organ/cyberimp/mouth/tastebooster/proc/add_boost(datum/source, obj/item/organ/tongue/unboosted_tongue)
	if(!istype(unboosted_tongue))
		return
	unboosted_tongue.taste_sensitivity = 1

/obj/item/organ/cyberimp/mouth/tastebooster/proc/remove_boost(datum/source, obj/item/organ/tongue/boosted_tongue)
	if(!istype(boosted_tongue))
		return
	boosted_tongue.taste_sensitivity = initial(boosted_tongue.taste_sensitivity)

/datum/augment_item/organ/mouth/tastebooster
	name = "Gustatory Hypersensitizer"
	extra_info = "Increases taste sensitivity."
	cost = 4
	path = /obj/item/organ/cyberimp/mouth/tastebooster

/datum/design/tastebooster
	name = "Gustatory Hypersensitizer"
	desc = "This cybernetic implant greatly increases the taste sensitivity of the implantee."
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 6 SECONDS
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT*5,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT*5,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT*2,
	)
	build_path = /obj/item/organ/cyberimp/mouth/tastebooster
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/techweb_node/cyber/tastebooster
	display_name = "Gastrointestinal Thingamawidgetry"
	description = "Shove a microchip in your mouth, taste things better. Makes logical sense."
	prerequisite_nodes = list(/datum/techweb_node/food_proc, /datum/techweb_node/cyber/cyber_implants)
	unlocked_designs = list(/datum/design/tastebooster)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SERVICE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SCIENCE)

/obj/item/organ/cyberimp/mouth/musicsynth
	name = "respiratory harmonitron"
	desc = "This cybernetic implant uses the airflow of the trachea to power a generator hooked up to a neurally connected synthesizer and speaker."
	special_desc = "This sort of device is a great way to look like a much better singer than you are."
	w_class = WEIGHT_CLASS_TINY
	slot = ORGAN_SLOT_MUSICSYNTH
	actions_types = list(/datum/action/item_action/organ_action/musicsynth)
	icon = 'modular_oculis/modules/cybernetics/icons/newcybers.dmi'
	icon_state = "respiratoryharmonitron"
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 3,
	)


/datum/augment_item/organ/mouth/musicsynth
	name = "Respiratory Harmonitron"
	extra_info = "Plays music."
	cost = 2
	path = /obj/item/organ/cyberimp/mouth/musicsynth

/datum/action/item_action/organ_action/musicsynth
	name = "Internal Synthesizer"
	desc = "Use your internal synthesizer to play music."
	button_icon = 'modular_oculis/modules/cybernetics/icons/newcybers.dmi'
	button_icon_state = "respiratoryharmonitron"
	var/datum/song/song


/datum/action/item_action/organ_action/musicsynth/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	song.ui_interact(owner)

/datum/action/item_action/organ_action/musicsynth/Grant(mob/grant_to)
	..()
	song = new(grant_to, SSinstruments.synthesizer_instrument_ids, 15)

/datum/action/item_action/organ_action/musicsynth/Remove(mob/remove_from)
	..()
	QDEL_NULL(song)

/datum/design/musicsynth
	name = "Respiratory Harmonitron"
	desc = "This tracheal synthesizer system accepts neural commands, allowing for users to \"sing\" their own backing instrumentation!"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 6 SECONDS
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 3,
	)
	build_path = /obj/item/organ/cyberimp/mouth/musicsynth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/techweb_node/cyber/musicsynth
	display_name = "Neurosynchronous Harmonization"
	description = "Music from your mind! The wonders of modern technology."
	prerequisite_nodes = list(/datum/techweb_node/gas_compression, /datum/techweb_node/cyber/cyber_implants)
	unlocked_designs = list(/datum/design/musicsynth)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SERVICE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SCIENCE)

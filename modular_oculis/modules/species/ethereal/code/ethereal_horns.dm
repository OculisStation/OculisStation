//Horns Organ//
/obj/item/organ/ethereal_horns
	name = "ethereal horns"
	desc = "These seemingly decorative horns are actually sensory organs, albiet somewhat vegistal ones in their current enviroment, for detecting nearby electromagnetic fields. They are also extremely sensitive, a fact that which whatever poor ethereal you took these from is probably heavily aware of."
	icon = 'modular_oculis/modules/species/ethereal/icons/organs.dmi'
	icon_state = "ethereal_horns"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HORNS

	mutantpart_key = FEATURE_HORNS_ETHEREAL
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/ethereal_horns
	use_mob_sprite_as_obj_sprite = TRUE

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/ethereal_horns
	feature_key = FEATURE_HORNS_ETHEREAL
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER,
	)
	color_source = ORGAN_COLOR_OVERRIDE

/datum/bodypart_overlay/mutant/ethereal_horns/override_color(rgb_value)
	return draw_color

/datum/bodypart_overlay/mutant/ethereal_horns/get_global_feature_list()
	return SSaccessories.sprite_accessories[FEATURE_HORNS_ETHEREAL]

/datum/bodypart_overlay/mutant/ethereal_horns/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	return !sprite_datum.is_hidden(human)

//Mutant Toggles

/datum/preference/toggle/mutant_toggle/ethereal_horns
	savefile_key = "ethereal_horns_toggle"
	relevant_mutant_bodypart = FEATURE_HORNS_ETHEREAL

/datum/preference/choiced/mutant_choice/ethereal_horns
	savefile_key = "feature_ethereal_horns"
	relevant_mutant_bodypart = FEATURE_HORNS_ETHEREAL
	type_to_check = /datum/preference/toggle/mutant_toggle/ethereal_horns
	default_accessory_type = /datum/sprite_accessory/ethereal_horns/none

//Sprite Accessories//
/datum/sprite_accessory/ethereal_horns
	icon = 'modular_oculis/modules/species/ethereal/icons/ethereal_horns.dmi'
	color_src = USE_ONE_COLOR
	key = FEATURE_HORNS_ETHEREAL
	organ_type = /obj/item/organ/ethereal_horns
	recommended_species = list(SPECIES_ETHEREAL = 1)

/datum/sprite_accessory/ethereal_horns/is_hidden(mob/living/carbon/human/wearer)
	var/obj/item/clothing/head/worn_head = wearer.head
	var/obj/item/clothing/mask/worn_mask = wearer.wear_mask
	if((worn_head?.flags_inv & HIDEHAIR || worn_mask?.flags_inv & HIDEHAIR))
		return TRUE
	return ..()

/datum/sprite_accessory/ethereal_horns/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	factual = FALSE
	color_src = null

/datum/sprite_accessory/ethereal_horns/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/ethereal_horns/helm
	name = "Helm"
	icon_state = "helm"

/datum/sprite_accessory/ethereal_horns/lunar
	name = "Lunar"
	icon_state = "lunar"

/datum/sprite_accessory/ethereal_horns/inward
	name = "Inward"
	icon_state = "inward"

/datum/sprite_accessory/ethereal_horns/majesty
	name = "Majesty"
	icon_state = "majesty"
	natural_spawn = FALSE

/datum/sprite_accessory/ethereal_horns/clipped
	name = "Clipped"
	icon_state = "clipped"

/datum/sprite_accessory/ethereal_horns/sharp
	name = "Sharp"
	icon_state = "sharp"

//DNA Block//
/datum/dna_block/feature/mutant/ethereal_horns
	feature_key = FEATURE_HORNS_ETHEREAL

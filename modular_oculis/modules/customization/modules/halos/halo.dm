/obj/item/organ/halo
	name = "halo"
	desc = "An intangible pattern of light that manifests above its owner's head. It cannot be touched and possesses no apparent physical volume, fading away when its owner loses consciousness. Beyond that, its nature remains a mystery."
	mutantpart_key = FEATURE_HALO
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HALO
	organ_flags = ORGAN_EXTERNAL | ORGAN_UNREMOVABLE
	bodypart_overlay = /datum/bodypart_overlay/mutant/halo

/obj/item/organ/halo/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	RegisterSignals(organ_owner, list(SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT)), PROC_REF(on_consciousness_change))

/obj/item/organ/halo/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	UnregisterSignal(organ_owner, list(SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT)))

// knockedout covers sleep, knockouts, hard crit and death, so this one pair catches every fade and return
/obj/item/organ/halo/proc/on_consciousness_change(mob/living/carbon/source)
	SIGNAL_HANDLER

	source.update_body_parts()

/datum/bodypart_overlay/mutant/halo
	feature_key = "halo"
	layers = list(EXTERNAL_FRONT = BODY_FRONT_LAYER, EXTERNAL_BEHIND = BODY_BEHIND_LAYER)
	color_source = ORGAN_COLOR_OVERRIDE

/datum/bodypart_overlay/mutant/halo/override_color(rgb_value)
	return draw_color

/datum/bodypart_overlay/mutant/halo/get_global_feature_list()
	return SSaccessories.sprite_accessories[FEATURE_HALO]


// the halo only manifests while its owner is conscious
/datum/bodypart_overlay/mutant/halo/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	var/mob/living/carbon/halo_owner = owner || bodypart_owner.owner
	if(halo_owner && IS_UNCONSCIOUS(halo_owner))
		return FALSE
	return ..()

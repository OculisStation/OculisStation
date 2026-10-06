//this is disabled because remove_client_colour proc appears to not work, like at all
/*
/datum/species/lizard/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()

	RegisterSignal(human_who_gained_species, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	RegisterSignal(human_who_gained_species, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))

/datum/species/lizard/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)

	UnregisterSignal(human, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	UnregisterSignal(human, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))
	human.remove_client_colour(/datum/client_colour/monochrome/lizard)
	return ..()

/datum/species/lizard/proc/on_gained_organ(mob/living/receiver, obj/item/organ/tongue/lizard/forked)
	SIGNAL_HANDLER

	if(!istype(forked))
		return
	receiver.remove_client_colour(/datum/client_colour/monochrome/lizard, REF(src))

/datum/species/lizard/proc/on_removed_organ(mob/living/unreceiver, obj/item/organ/tongue/lizard/forked)
	SIGNAL_HANDLER

	var/obj/item/organ/brain/lizard/liz_brain = unreceiver.get_organ_by_type(/obj/item/organ/brain/lizard)

	if(liz_brain)
		if(!istype(forked))
			return
		unreceiver.add_client_colour(/datum/client_colour/monochrome/lizard)

/datum/client_colour/monochrome/lizard
*/

/datum/species/lizard
	mutantstomach = /obj/item/organ/stomach/lizard
	mutantliver = /obj/item/organ/liver/lizard
	mutant_organs = list(
		/obj/item/organ/heart/second_heart
	)

/datum/species/lizard/on_species_gain(mob/living/carbon/human/lizard, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	MODIFY_PHYSIOLOGY(lizard, TOX, 1.25) //note that this only affects damage, not chems that apply tox
	lizard.add_surgery_speed_mod(type, 1.15)

/datum/species/lizard/on_species_loss(mob/living/carbon/human/former_lizard, datum/species/new_species, pref_load)
	. = ..()
	MODIFY_PHYSIOLOGY(former_lizard, TOX, 0.8)
	former_lizard.remove_surgery_speed_mod(type)

/datum/species/lizard/create_pref_unique_perks()
	var/list/perk_descriptions = list()

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "drumstick-bite",
		SPECIES_PERK_NAME = "Nutritious Regeneration",
		SPECIES_PERK_DESC = "Lizards heal brute damage when well fed.",
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "heart",
		SPECIES_PERK_NAME = "Second Heart",
		SPECIES_PERK_DESC = "Lizards have a secondary heart, they won't die if they lose one",
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "allergies",
		SPECIES_PERK_NAME = "Scaled Body",
		SPECIES_PERK_DESC = "Lizards have a harder time being cut up due to \
							their scales, so surgery on them takes longer.",
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "biohazard",
		SPECIES_PERK_NAME = "Toxin Weakness",
		SPECIES_PERK_DESC = "Lizards have a weakness to toxins, taking additional \
							damage from them, and being worse at purging them from their body.",
	))

	return perk_descriptions

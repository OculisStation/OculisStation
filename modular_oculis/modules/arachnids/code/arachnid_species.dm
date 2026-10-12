/datum/species/arachnid
	name = "Arachnid"
	plural_form = "Arachnids"
	id = SPECIES_ARACHNID
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_ARACHNID_WEB_SURFER
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG

	mutant_organs = list(/obj/item/organ/silkgland)

	sexes = FALSE
	meat = /obj/item/food/meat/slab/spider

	species_language_holder = /datum/language_holder/fly

	mutanttongue = /obj/item/organ/tongue/arachnid
	mutanteyes = /obj/item/organ/eyes/night_vision/arachnid
	mutantheart = /obj/item/organ/heart/arachnid
	mutantliver = /obj/item/organ/liver/arachnid

	COOLDOWN_DECLARE(pesticide_toxin_damage_cooldown)

	exotic_bloodtype = /datum/blood_type/arachnid
	inherent_factions = list(FACTION_SPIDER)
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/arachnid,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/arachnid,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/arachnid,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/arachnid,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/arachnid,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/arachnid,
	)

/datum/species/arachnid/get_default_mutant_bodyparts()
	return list(
		FEATURE_ARACHNID_APPENDAGES = MUTPART_BLUEPRINT("Long", is_randomizable = TRUE),
		FEATURE_ARACHNID_CHELICERAE = MUTPART_BLUEPRINT("Basic", is_randomizable = TRUE),
	)

/datum/species/arachnid/randomize_features()
	var/list/features = ..()
	features[FEATURE_MUTANT_COLOR] = "#e9e9e9"
	return features

/datum/scream_type/arachnid
	name = "Arachnid Scream"
	scream_sounds = list('modular_oculis/modules/arachnids/sounds/arachnid_scream.ogg')

/datum/laugh_type/arachnid
	name = "Arachnid Laugh"
	laugh_sounds = list('modular_oculis/modules/arachnids/sounds/arachnid_laugh.ogg')

/datum/species/arachnid/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(damage_weakness))
	RegisterSignal(human_who_gained_species, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_reagent_expose))

/datum/species/arachnid/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	UnregisterSignal(C, COMSIG_ATOM_EXPOSE_REAGENTS)


/datum/species/arachnid/proc/on_reagent_expose(mob/living/carbon/human/H, list/reagents, datum/reagents/source, methods, volume_modifier, show_message)
	SIGNAL_HANDLER

	if(!(locate(/datum/reagent/toxin/pestkiller) in reagents))
		return NONE
	if(!COOLDOWN_FINISHED(src, pesticide_toxin_damage_cooldown))
		return FALSE
	COOLDOWN_START(src, pesticide_toxin_damage_cooldown, 0.1 SECONDS)

	H.apply_damage(3, TOX)
	H.reagents.remove_reagent(/datum/reagent/toxin/pestkiller, REAGENTS_METABOLISM * 0.1)
	return NONE

/datum/species/arachnid/proc/damage_weakness(datum/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/melee/flyswatter))
		damage_mods += 30 // Yes, a 30x damage modifier

/datum/species/arachnid/get_species_description()
	return "Arachnids are a species of humanoid spiders from a very far away place. \
	They are known for their ability to weave silk, which has saved lives in emergencies."

/datum/species/arachnid/get_species_lore()
	return list(
		"The true origin of Arachnids is still debated to this day. \
		Some say they were born in a lab out of sheer experimentation. \
		Others say they've naturally evolved over countless years. \
		What is actually known, is the fact that they've had to emigrate from a very, very far away place to make it here.",
	)


/datum/species/arachnid/prepare_human_for_preview(mob/living/carbon/human/arachnid)
	arachnid.set_eye_color("#4c4c1c", "#4c4c1c")
	arachnid.dna.features[FEATURE_MUTANT_COLOR] = "#e9e9e9"
	arachnid.dna.mutant_bodyparts[FEATURE_ARACHNID_CHELICERAE] = build_mutant_part("Basic")
	arachnid.dna.mutant_bodyparts[FEATURE_ARACHNID_APPENDAGES] = build_mutant_part("Zigzag")
	regenerate_organs(arachnid, src, visual_only = TRUE)
	arachnid.update_body(is_creating = TRUE)

/datum/species/arachnid/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Sericulture",
			SPECIES_PERK_DESC = "Arachnids have a silk gland organ that connects to their wrists, \
			allowing them to convert nutrition into silk related items and furniture.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Agile",
			SPECIES_PERK_DESC = "Arachnids run slightly faster than other species.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Big Appendages",
			SPECIES_PERK_DESC = "Arachnids have appendages that are not hidden by space suits \
			or MODsuits. This can make concealing your identity harder.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Maybe Too Many Eyes",
			SPECIES_PERK_DESC = "Arachnids cannot equip any kind of eyewear, requiring \
			alternatives like welding helmets or implants. Their eyes have night vision however.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Arachnid Biology",
			SPECIES_PERK_DESC = "Fly swatters and pest killer will deal significantly higher amounts of damage to an Arachnid.",
		),
	)

	return to_add

/datum/reagent/mutationtoxin/arachnid
	name = "Arachnid Mutation Toxin"
	description = "A spidering toxin."
	color = "#3B5EFF" //RGB: 59, 94, 255
	race = /datum/species/arachnid
	taste_description = "webs"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/chemical_reaction/arachnid_mutationtoxin
	results = list(/datum/reagent/mutationtoxin/arachnid = 1)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/mutationtoxin/lizard = 1)
	reaction_tags = REACTION_TAG_HARD


/mob/living/carbon/human/species/arachnid
	race = /datum/species/arachnid

/datum/scream_type/arachnid
	name = "Arachnid Scream"
	scream_sounds = list('modular_oculis/modules/arachnids/sounds/arachnid_scream.ogg')

/datum/laugh_type/arachnid
	name = "Arachnid Laugh"
	laugh_sounds = list('modular_oculis/modules/arachnids/sounds/arachnid_laugh.ogg')

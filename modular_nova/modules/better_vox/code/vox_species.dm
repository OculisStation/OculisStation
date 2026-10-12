/datum/species/vox_primalis
	name = "Vox Primalis"
	id = SPECIES_VOX_PRIMALIS
	can_augment = FALSE
	body_size_restricted = FALSE // IRIS EDIT: allows vox to be rescaled (to fix the char creator)
	digitigrade_customization = DIGITIGRADE_NEVER // We have our own unique sprites!
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	mutantlungs = /obj/item/organ/lungs/nitrogen/vox
	mutantbrain = /obj/item/organ/brain/cybernetic/cortical/vox //reparented vox brain
	meat = /obj/item/food/meat/slab/chicken/human

	mutanttongue = /obj/item/organ/tongue/vox
	payday_modifier = 1.0
	outfit_important_for_life = /datum/outfit/vox
	species_language_holder = /datum/language_holder/vox
	exotic_bloodtype = /datum/blood_type/vox //IRIS EDIT
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	// Vox are cold resistant, but also heat sensitive
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT - 15) // being cold resistant, should make you heat sensitive actual effect ingame isn't much
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 30)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mutant/vox_primalis,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mutant/vox_primalis,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mutant/vox_primalis,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mutant/vox_primalis,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mutant/vox_primalis,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mutant/vox_primalis,
	)
	custom_worn_icons = list(
		LOADOUT_ITEM_HEAD = VOX_PRIMALIS_HEAD_ICON,
		LOADOUT_ITEM_MASK = VOX_PRIMALIS_MASK_ICON,
		LOADOUT_ITEM_SUIT = VOX_PRIMALIS_SUIT_ICON,
		LOADOUT_ITEM_UNIFORM = VOX_PRIMALIS_UNIFORM_ICON,
		LOADOUT_ITEM_GLOVES =  VOX_PRIMALIS_GLOVES_ICON,
		LOADOUT_ITEM_SHOES = VOX_PRIMALIS_FEET_ICON,
		LOADOUT_ITEM_GLASSES = VOX_PRIMALIS_EYES_ICON,
		LOADOUT_ITEM_BELT = VOX_PRIMALIS_BELT_ICON,
		LOADOUT_ITEM_MISC = VOX_PRIMALIS_BACK_ICON,
		LOADOUT_ITEM_EARS = VOX_PRIMALIS_EARS_ICON,
	)

/datum/species/vox_primalis/get_default_mutant_bodyparts()
	return list(
		FEATURE_TAIL = MUTPART_BLUEPRINT("Vox Primalis Tail", is_randomizable = FALSE),
	)

/datum/species/vox_primalis/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only)
	. = ..()
	if(job?.vox_outfit)
		equipping.equipOutfit(job.vox_outfit, visuals_only)
	else
		give_important_for_life(equipping)

/datum/species/vox_primalis/get_custom_worn_icon(item_slot, obj/item/item)
	return item.worn_icon_better_vox

/datum/species/vox_primalis/set_custom_worn_icon(item_slot, obj/item/item, icon/icon)
	item.worn_icon_better_vox = icon

/datum/species/vox_primalis/get_species_description()
	return "The Vox seem to be nomadic, bio-engineered alien creatures that operate in and around human space at the behest of crazed and dreaming gods. \
		In reality, we know them to be originally designed by the Vox Auralis, a wholly-reclusive variety of powerful psychics, and present a cold shoulder to all other known cultures, and generally their only visible role on the galactic stage is to act as auxiliary workforce of which they are functionally suited for. \
		The massive moon-sized arkships that serve as their homes travel meandering and convoluted migratory trails through the Milky Way, and the appearance of their looted and repurposed ships is almost always a cause for alarm."

/datum/species/vox_primalis/get_species_lore()
	return list(placeholder_lore)

/datum/species/vox_primalis/on_species_gain(mob/living/carbon/human/transformer, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	var/vox_color = transformer.dna.features["vox_bodycolor"]
	if(!vox_color || vox_color == "default")
		return
	for(var/obj/item/bodypart/limb as anything in transformer.bodyparts)
		limb.limb_id = "[SPECIES_VOX_PRIMALIS]_[vox_color]"
	transformer.update_body()

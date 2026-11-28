/datum/preference/toggle/mutant_toggle/halo
	savefile_key = "halo_toggle"
	relevant_mutant_bodypart = FEATURE_HALO

/datum/preference/choiced/mutant_choice/halo
	savefile_key = "feature_halo"
	relevant_mutant_bodypart = FEATURE_HALO
	type_to_check = /datum/preference/toggle/mutant_toggle/halo
	default_accessory_type = /datum/sprite_accessory/halo/none

/datum/preference/tri_color/halo
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "halo_color"
	relevant_mutant_bodypart = FEATURE_HALO
	type_to_check = /datum/preference/toggle/mutant_toggle/halo

/datum/preference/toggle/emissive/halo
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "halo_emissive"
	relevant_mutant_bodypart = FEATURE_HALO
	check_mode = TRICOLOR_CHECK_ACCESSORY
	type_to_check = /datum/preference/choiced/mutant_choice/halo

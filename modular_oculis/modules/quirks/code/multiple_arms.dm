GLOBAL_LIST_INIT(hand_pairs, list(
	"One Pair" = 1,
	"Two Pairs" = 2,
	"Three Pairs" = 3,
))

/datum/quirk/multiple_arms
	name = "Multiple Arms"
	desc = "You have multiple arms! (Does not affect character sprite)"
	value = 8
	gain_text = span_notice("You feel more handed.")
	lose_text = span_notice("You feel less handed.")
	medical_record_text = "Patient has multiple arms."
	icon = FA_ICON_HAND_LIZARD
	var/list/given_arms = list()

/datum/quirk_constant_data/multiple_arms
	associated_typepath = /datum/quirk/multiple_arms
	customization_options = list(/datum/preference/choiced/multiple_arms)

/datum/quirk/multiple_arms/add_unique(client/client_source)
	. = ..()

	var/arm_amount = GLOB.hand_pairs[client_source?.prefs.read_preference(/datum/preference/choiced/multiple_arms)]
	var/mob/living/carbon/human/human_holder = quirk_holder

	var/obj/item/bodypart/arm/left/current_left_arm = human_holder.dna.species.bodypart_overrides[BODY_ZONE_L_ARM]
	var/obj/item/bodypart/arm/right/current_right_arm = human_holder.dna.species.bodypart_overrides[BODY_ZONE_R_ARM]

	for(var/i in 1 to arm_amount)
		var/obj/item/bodypart/arm/left/additional_left_arm = new current_left_arm()
		additional_left_arm.held_index = (initial(additional_left_arm.held_index) + (i * 2))
		additional_left_arm.body_zone = null
		additional_left_arm.try_attach_limb(human_holder, TRUE)
		given_arms += REF(additional_left_arm)

		var/obj/item/bodypart/arm/right/additional_right_arm = new current_right_arm()
		additional_right_arm.held_index = (initial(additional_right_arm.held_index) + (i * 2))
		additional_right_arm.body_zone = null
		additional_right_arm.try_attach_limb(human_holder, TRUE)
		given_arms += REF(additional_right_arm)

	var/total_arms = 2 + (2 * arm_amount) // One set + the additional sets.
	human_holder.change_number_of_hands(total_arms)
	human_holder.set_num_hands(total_arms)
	human_holder.set_usable_hands(total_arms)

/datum/quirk/multiple_arms/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	for(var/i in 1 to length(given_arms))
		var/datum/weakref/arm_weakref = given_arms[1]
		var/obj/item/bodypart/arm/removing_arm = arm_weakref.resolve()
		given_arms -= given_arms[1]
		removing_arm?.drop_limb(special = TRUE, move_to_floor = FALSE)
		qdel(removing_arm)
	human_holder.change_number_of_hands(2)
	human_holder.set_num_hands(2)
	human_holder.set_usable_hands(2)

// Preferences.
/datum/preference/choiced/multiple_arms
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "multiple_arms"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	should_update_preview = FALSE

/datum/preference/choiced/multiple_arms/init_possible_values()
	var/list/possible_options = assoc_to_keys(GLOB.hand_pairs)
	return possible_options

/datum/preference/choiced/multiple_arms/create_default_value()
	return "One Pair" // One extra set of arms, total of 4 arms.

/datum/preference/choiced/multiple_arms/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return /datum/quirk/multiple_arms::name in preferences.all_quirks

/datum/preference/choiced/multiple_arms/apply_to_human(mob/living/carbon/human/target, value)
	return

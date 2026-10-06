/obj/item/organ/wings/gizzard
	name = "Natural wings"
	desc = "This should help you fly"
	icon_state = "eggsac"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_GIZZARD
	w_class = WEIGHT_CLASS_BULKY
	organ_flags = ORGAN_ORGANIC | ORGAN_EDIBLE | ORGAN_VIRGIN
	use_mob_sprite_as_obj_sprite = FALSE
	sprite_accessory_override = /datum/sprite_accessory/wings/dragon
	flight_level = WINGS_AIRWORTHY

/obj/item/organ/wings/gizzard/Initialize(mapload)
	. = ..()
	// We're putting this here instead of static variables due to
	// food_reagents being overriden by the parent proc's initialize value.
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)

/obj/item/organ/wings/gizzard/grind_results()
	return null

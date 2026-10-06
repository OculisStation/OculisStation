/datum/quirk/winged
	name = "Functional Wings"
	desc = "Your wings are not just for show, fly and hover with ease!"
	icon = FA_ICON_FEATHER
	value = 10
	gain_text = span_notice("You feel like the sky's the limit!")
	lose_text = span_danger("You feel a little bit more grounded.")
	medical_record_text = "Patient excels at aerial movement."
	mail_goodies = list(/obj/item/storage/fancy/nugget_box)

/datum/quirk/winged/add_unique(client/client_source)
	. = ..()
	var/obj/item/organ/wings/existing_wings = quirk_holder.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(existing_wings)
		existing_wings.flight_level = WINGS_AIRWORTHY
		qdel(existing_wings.GetComponent(/datum/component/jetpack))
		existing_wings.setup_jetpack()
		existing_wings.update_flight(quirk_holder)
		existing_wings.use_stamina = TRUE
	else
		var/obj/item/organ/wings/gizzard/gizzard_wings = new()
		gizzard_wings.Insert(quirk_holder)

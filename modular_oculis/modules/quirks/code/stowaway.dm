/datum/quirk/item_quirk/stowaway
	name = "Stowaway"
	desc = "You wake up inside a random locker with only a crude fake for an ID card. You are not on the crew manifest or on any Nanotrasen records. You also start with a toolbox in case you get stuck. You are an unauthorized personnel, so you are at risk of being arrested if found out."
	value = -6
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_HIDE_FROM_SCAN | QUIRK_EXCLUDES_GHOSTROLES
	icon = FA_ICON_SUITCASE_ROLLING
	medical_record_text = "Patient has a knack for turning up where they aren't supposed to."

/datum/quirk/item_quirk/stowaway/add_unique(client/client_source)
	var/mob/living/carbon/human/stowaway = quirk_holder
	var/obj/item/card/id/trashed = stowaway.get_item_by_slot(ITEM_SLOT_ID) //No ID
	qdel(trashed)

	var/obj/item/card/id/fake_card/card = new(quirk_holder.drop_location()) //a fake ID with two uses for maint doors
	quirk_holder.equip_to_slot_if_possible(card, ITEM_SLOT_ID)
	var/stowaway_alias = client_source?.prefs.read_preference(/datum/preference/text/stowaway/alias)
	var/effective_alias = stowaway_alias || quirk_holder.real_name
	card.register_name(effective_alias)
	stowaway.update_visible_name()

	var/obj/structure/closet/selected_closet = get_unlocked_closed_locker() //Find your new home
	if(selected_closet)
		stowaway.forceMove(selected_closet) //Move in
		stowaway.Immobilize(5 SECONDS, ignore_canstun = TRUE)

	give_item_to_holder(/obj/item/storage/toolbox/mechanical, list(LOCATION_HANDS)) // gives them tools to break free if need be


/datum/quirk/item_quirk/stowaway/post_add()
	to_chat(quirk_holder, span_boldnotice("You've awoken to find yourself inside [GLOB.station_name] without real identification!"))
	force_stowaway_unassigned_role(quirk_holder, quirk_holder.client)


/datum/quirk_constant_data/stowaway
	associated_typepath = /datum/quirk/item_quirk/stowaway
	customization_options = list(/datum/preference/text/stowaway/alias)


/datum/preference/text/stowaway
	abstract_type = /datum/preference/text/stowaway
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	maximum_value_length = 32

/datum/preference/text/stowaway/create_default_value()
	return ""

/datum/preference/text/stowaway/is_accessible(datum/preferences/preferences)
	if(!..())
		return FALSE

	return /datum/quirk/item_quirk/stowaway::name in preferences.all_quirks

/datum/preference/text/stowaway/serialize(input)
	var/trimmed_input = trim("[input]")
	if(!length(trimmed_input))
		return ""
	return sanitize(trimmed_input)

/datum/preference/text/stowaway/is_valid(value)
	if(!istext(value))
		return FALSE

	var/trimmed_value = trim(value)
	if(!length(trimmed_value))
		return TRUE

	return !isnull(reject_bad_name(trimmed_value, allow_numbers = TRUE, strict = TRUE, cap_after_symbols = FALSE))

/datum/preference_middleware/stowaway_alias/pre_set_preference(mob/user, preference, value)
	if(preference != /datum/preference/text/stowaway/alias::savefile_key)
		return FALSE

	var/trimmed_value = trim("[value]")
	if(!length(trimmed_value))
		return FALSE

	if(!isnull(reject_bad_name(trimmed_value, allow_numbers = TRUE, strict = TRUE, cap_after_symbols = FALSE)))
		return FALSE

	if(is_ic_filtered(trimmed_value) || is_soft_ic_filtered(trimmed_value))
		tgui_alert(user, "You cannot set a name that contains a word prohibited in IC chat!")
	else
		tgui_alert(user, "Invalid name.")

	return TRUE

/datum/preference/text/stowaway/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/stowaway/alias
	savefile_key = "stowaway_alias"

/datum/preference/text/stowaway/alias/compile_ui_data(mob/user, value)
	if(length(trim("[value]")))
		return ..()
	return user?.client?.prefs?.read_preference(/datum/preference/name/real_name) || ""

/datum/preference/text/stowaway/alias/apply_to_human(mob/living/carbon/human/target, value)
	return


/obj/item/card/id/fake_card //not a proper ID but still shares a lot of functions
	name = "\"ID Card\""
	desc = "Definitely a legitimate ID card and not a piece of notebook paper with a magnetic strip drawn on it. You'd have to stuff this in a card reader by hand for it to work."
	icon = 'modular_iris/icons/obj/card.dmi'
	icon_state = "counterfeit"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	resistance_flags = FIRE_PROOF | ACID_PROOF
	registered_account = null
	accepts_accounts = FALSE
	registered_name = null
	access = list(ACCESS_MAINT_TUNNELS)
	var/uses = 4

/obj/item/card/id/fake_card/proc/register_name(new_name)
	registered_name = new_name
	name = "[new_name]'s \"ID Card\""
	if(ishuman(loc))
		var/mob/living/carbon/human/human_holder = loc
		human_holder.update_visible_name()
	else if(istype(loc, /obj/item/modular_computer/pda))
		var/obj/item/modular_computer/pda/holder_pda = loc
		if(ishuman(holder_pda.loc))
			var/mob/living/carbon/human/pda_wearer = holder_pda.loc
			if(pda_wearer.wear_id == holder_pda)
				pda_wearer.update_visible_name()

/obj/item/card/id/fake_card/proc/used()
	uses -= 1
	switch(uses)
		if(0)
			icon_state = "counterfeit_torn2"
		if(2, 1)
			icon_state = "counterfeit_torn"
		else
			icon_state = "counterfeit" //in case you somehow repair it to 4+

/obj/item/card/id/fake_card/alt_click_can_use_id(mob/living/user)
	return FALSE //no accounts on fake cards

/obj/item/card/id/fake_card/examine(mob/user)
	. = ..()
	switch(uses)
		if(0)
			. += "It's too shredded to fit in a scanner!"
		if(1)
			. += "It's falling apart!"
		else
			. += "It looks frail!"

/proc/is_stowaway(mob/living/carbon/human/person, client/person_client)
	if(!person)
		return FALSE

	var/client/target_client = person_client || person.client
	var/list/all_quirks = target_client?.prefs.all_quirks

	return person.has_quirk(/datum/quirk/item_quirk/stowaway) || (all_quirks && ("Stowaway" in all_quirks))

/proc/force_stowaway_unassigned_role(mob/living/carbon/human/person, client/person_client)
	if(!person?.mind || is_unassigned_job(person.mind.assigned_role))
		return

	var/datum/job/previous_role = person.mind.assigned_role
	if(previous_role?.title)
		SSjob.FreeRole(previous_role.title)

	person.mind.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))

/proc/process_stowaway_latejoin(mob/living/carbon/human/person, datum/job/current_job, client/person_client)
	if(!person?.mind || !is_stowaway(person, person_client))
		return

	if((current_job?.job_flags & JOB_ASSIGN_QUIRKS) && CONFIG_GET(flag/roundstart_traits))
		SSquirks.AssignQuirks(person, person_client)

	force_stowaway_unassigned_role(person, person_client)

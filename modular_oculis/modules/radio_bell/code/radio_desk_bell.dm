// Subtype of desk bells that gives a radio message each time its rung, with a cooldown. Meant for each department.
/obj/structure/desk_bell/department
	name = "departmental desk bell"
	var/obj/item/radio/radio
	var/department_radio_channel = RADIO_CHANNEL_COMMON
	COOLDOWN_DECLARE(radio_cooldown)

/obj/structure/desk_bell/department/Initialize(mapload)
	. = ..()
	desc += "<br>This one seems to have a radio transmitter attached to it."
	radio = new(src)
	radio.keyslot = new /obj/item/encryptionkey/aas // For all the channels.
	radio.set_listening(FALSE)
	radio.recalculateChannels()

/obj/structure/desk_bell/department/Destroy(force)
	QDEL_NULL(radio)
	return ..()

/obj/structure/desk_bell/department/ring_bell(mob/living/user)
	. = ..()
	play_radio_message(user)

/obj/structure/desk_bell/department/proc/play_radio_message(mob/living/user)
	if(!COOLDOWN_FINISHED(src, radio_cooldown))
		return FALSE
	to_chat(user, span_notice("You request assistance by pressing the bell."))
	radio.talk_into(src, "Assistance requested by [user ? user : "unknown"], at [get_area(src)].", department_radio_channel)
	COOLDOWN_START(src, radio_cooldown, 10 SECONDS)
	return TRUE

/obj/structure/desk_bell/department/medical
	name = "medical desk bell"
	department_radio_channel = RADIO_CHANNEL_MEDICAL

/obj/structure/desk_bell/department/science
	name = "science desk bell"
	department_radio_channel = RADIO_CHANNEL_SCIENCE

/obj/structure/desk_bell/department/engineering
	name = "engineering desk bell"
	department_radio_channel = RADIO_CHANNEL_ENGINEERING

/obj/structure/desk_bell/department/service
	name = "service desk bell"
	department_radio_channel = RADIO_CHANNEL_SERVICE

/obj/structure/desk_bell/department/supply
	name = "supply desk bell"
	department_radio_channel = RADIO_CHANNEL_SUPPLY

/obj/structure/desk_bell/department/security
	name = "security desk bell"
	department_radio_channel = RADIO_CHANNEL_SECURITY

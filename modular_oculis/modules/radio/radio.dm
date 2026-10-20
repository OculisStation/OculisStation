/obj/item/encryptionkey/headset_syndicate/octavia
	name = "octavia radio encryption key"
	flags_1 = parent_type::flags_1 | NO_NEW_GAGS_PREVIEW_1
	channels = list(RADIO_CHANNEL_CYBERSUN = 1, RADIO_CHANNEL_INTERDYNE = 1)
	special_channels = RADIO_SPECIAL_CENTCOM

/obj/item/radio/headset/octavia
	name = "\improper Octavia headset"
	desc = "A bowman headset with a red S on the earpiece, and 'Cybersun Industries' written in small text on the top strap. Protects the ears from flashbangs."
	icon_state = "syndie_headset"
	inhand_icon_state = null
	radio_talk_sound = 'modular_nova/modules/radiosound/sound/radio/syndie.ogg'
	keyslot = new /obj/item/encryptionkey/headset_syndicate/octavia

/obj/item/radio/headset/octavia/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/radio/headset/octavia/command
	name = "\improper Octavia command headset"
	desc = "A commander's bowman headset, to direct your operatives with. It has a red S on the earpiece, and 'Cybersun Industries' written in small text on the top strap."
	command = TRUE

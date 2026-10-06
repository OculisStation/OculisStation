/obj/item/encryptionkey/headset_syndicate/ds2
	name = "ds-2 radio encryption key"
	flags_1 = parent_type::flags_1 | NO_NEW_GAGS_PREVIEW_1
	channels = list(RADIO_CHANNEL_CYBERSUN = 1, RADIO_CHANNEL_INTERDYNE = 1)
	special_channels = RADIO_SPECIAL_CENTCOM

/obj/item/radio/headset/ds2
	name = "\improper DS-2 headset"
	desc = "A bowman headset with a red S on the earpiece, and 'Cybersun Industries' written in small text on the top strap. Protects the ears from flashbangs."
	icon_state = "syndie_headset"
	inhand_icon_state = null
	radio_talk_sound = 'modular_nova/modules/radiosound/sound/radio/syndie.ogg'
	keyslot = new /obj/item/encryptionkey/headset_syndicate/ds2

/obj/item/radio/headset/ds2/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/radio/headset/ds2/command
	name = "\improper DS-2 command headset"
	desc = "A commander's bowman headset, to direct your operatives with. It has a red S on the earpiece, and 'Cybersun Industries' written in small text on the top strap."
	command = TRUE

/datum/emote/living/squeal
	key = "squeal"
	key_third_person = "squeals"
	message = "squeals!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_oculis/modules/emotes/sound/squeal.ogg' // Taken from Monkestation

/datum/emote/living/tailthump
	key = "tailthump"
	key_third_person = "thumps their tail"
	message = "thumps their tail!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_oculis/modules/emotes/sound/tailthump.ogg' // Taken from Monkestation

/datum/emote/living/tailthump/can_run_emote(mob/user, status_check, intentional, params)
	var/obj/item/organ/tail/tail = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(tail)
		return ..()
	return FALSE


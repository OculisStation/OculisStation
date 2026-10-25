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

/datum/emote/living/carbon/human/vomit
	key = "vomit"
	key_third_person = "vomits"
	message = "vomits!"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/vomit/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/carbon_user = user
	if(!istype(user))
		return
	carbon_user.vomit(vomit_flags = (MOB_VOMIT_MESSAGE | MOB_VOMIT_HARM | MOB_VOMIT_STUN | MOB_VOMIT_FORCE))

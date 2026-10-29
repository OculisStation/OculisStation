/obj/item/clothing/mask/nobreath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rebreather)

/obj/item/clothing/mask/nobreath/examine(mob/user)
	. = ..()
	. += span_notice("You could work it into a plain mask with no internals or armor, to give that mask the same trick.")

/obj/item/clothing/mask/nobreath/proc/can_embed_into(obj/item/clothing/mask/mask)
	var/static/list/combat_ratings = list(MELEE, BULLET, LASER, ENERGY, BOMB)
	if((mask.clothing_flags | mask.visor_flags) & MASKINTERNALS)
		return FALSE
	if(HAS_TRAIT(mask, TRAIT_SLIME_REBREATHER))
		return FALSE
	if(mask.item_flags & (ABSTRACT | DROPDEL))
		return FALSE
	var/datum/armor/armor = mask.get_armor()
	for(var/rating in combat_ratings)
		if(armor.get_rating(rating))
			return FALSE
	return TRUE

/obj/item/clothing/mask/nobreath/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	var/obj/item/clothing/mask/mask = interacting_with
	if(!istype(mask))
		return NONE
	if(!can_embed_into(mask))
		to_chat(user, span_warning("[mask] won't take it. It has to be a plain mask with no internals and no armor."))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You work [src] into [mask]. It should keep you breathing now."))
	mask.name = "rebreathing [mask.name]"
	mask.AddElement(/datum/element/rebreather)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/// Keeps the wearer breathing with no air while the mask is on their face.
/datum/element/rebreather

/datum/element/rebreather/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/item/clothing/mask))
		return ELEMENT_INCOMPATIBLE
	ADD_TRAIT(target, TRAIT_SLIME_REBREATHER, ELEMENT_TRAIT(type))
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	var/obj/item/clothing/mask/mask = target
	var/mob/living/carbon/wearer = mask.loc
	if(iscarbon(wearer) && wearer.get_item_by_slot(ITEM_SLOT_MASK) == mask)
		on_equipped(mask, wearer, ITEM_SLOT_MASK)

/datum/element/rebreather/Detach(datum/target)
	. = ..()
	REMOVE_TRAIT(target, TRAIT_SLIME_REBREATHER, ELEMENT_TRAIT(type))
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_ATOM_EXAMINE))

/datum/element/rebreather/proc/on_equipped(obj/item/source, mob/living/carbon/user, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_MASK) || !iscarbon(user))
		return
	ADD_TRAIT(user, TRAIT_NOBREATH, "[CLOTHING_TRAIT]_[REF(source)]")
	user.failed_last_breath = FALSE
	user.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
	user.apply_status_effect(/datum/status_effect/rebreathing)

/datum/element/rebreather/proc/on_dropped(obj/item/source, mob/living/carbon/user)
	SIGNAL_HANDLER

	// wear_mask is only cleared after dropped() runs, and a spare rebreather in a hand shouldn't strip the one on your face
	if(!iscarbon(user) || user.get_item_by_slot(ITEM_SLOT_MASK) != source)
		return
	REMOVE_TRAIT(user, TRAIT_NOBREATH, "[CLOTHING_TRAIT]_[REF(source)]")
	user.remove_status_effect(/datum/status_effect/rebreathing)

/datum/element/rebreather/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("While worn as a mask, it keeps you breathing without any air.")

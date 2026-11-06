// Mask Skins
/datum/atom_skin/holo_mask
	abstract_type = /datum/atom_skin/holo_mask
	change_base_icon_state = TRUE

/datum/atom_skin/holo_mask/blank
	preview_name = "Blank"
	new_icon_state = "blank"

/datum/atom_skin/holo_mask/smile
	preview_name = "Smile"
	new_icon_state = "smile"

/datum/atom_skin/holo_mask/sad
	preview_name = "Frown"
	new_icon_state = "sad"

/datum/atom_skin/holo_mask/clown
	preview_name = "Holo Clown"
	new_icon_state = "clown"

/datum/atom_skin/holo_mask/static
	preview_name = "Static"
	new_icon_state = "static"


/obj/item/clothing/mask/holo_mask
	name = "holo mask"
	desc = "An emitter that allows for the projection of various holographic masks that obscure the face, surely these will only be used with the best of intentions"
	icon = 'modular_oculis/modules/holo_mask/icons/obj/holo_masks_icon.dmi'
	worn_icon = 'modular_oculis/modules/holo_mask/icons/mob/holo_mask_worn.dmi'
	icon_state = "emitter"
	inhand_icon_state = null
	interaction_flags_click = NEED_DEXTERITY
	alternate_worn_layer = BACK_LAYER
	w_class = WEIGHT_CLASS_SMALL
	post_init_icon_state = "emitter"
	var/emitter_on = FALSE
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/mask/holo_mask/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/holo_mask, infinite = TRUE)

/obj/item/clothing/mask/holo_mask/attack_self(mob/user)
	adjust_mask(user)

/obj/item/clothing/mask/holo_mask/proc/adjust_mask(mob/living/carbon/human/user)
	if(!istype(user))
		return

	if(!user.incapacitated)
		if(emitter_on == FALSE) //turns mask off and reveals face
			flags_inv = NONE
			icon_state = "emitter"
			to_chat(user, span_notice("You turn off the emitter"))
			worn_icon_state = "emitter"
			emitter_on = TRUE

		else //turns mask on and hides face
			flags_inv = HIDEFACIALHAIR|HIDESNOUT|HIDEFACE
			icon_state = "blank"
			to_chat(user, span_notice("You turn on the emitter."))
			worn_icon_state = "blank"
			emitter_on = FALSE

		user.update_clothing(ITEM_SLOT_MASK)
		user.refresh_obscured()
		user.regenerate_icons()

/obj/item/clothing/mask/holo_mask/click_alt_secondary(mob/user)
	alternate_worn_layer = (alternate_worn_layer == initial(alternate_worn_layer) ? NONE : initial(alternate_worn_layer))
	user.update_clothing(ITEM_SLOT_MASK)
	balloon_alert(user, "rendering [alternate_worn_layer == initial(alternate_worn_layer) ? "below" : "above"] hair")

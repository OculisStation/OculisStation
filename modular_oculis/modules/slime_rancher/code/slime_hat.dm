/// Moves a human-sized worn hat down onto the slime's head, fits both baby and adult sprites
#define SLIME_HAT_PIXEL_Y -5

GLOBAL_LIST_INIT(strippable_slime_items, create_strippable_list(list(
	/datum/strippable_item/slime_head,
)))

/mob/living/basic/slime
	/// The hat sitting on our head, put on through the strip menu
	var/obj/item/equipped_hat

/mob/living/basic/slime/Destroy()
	equipped_hat?.forceMove(drop_location())
	return ..()

/mob/living/basic/slime/death(gibbed)
	. = ..()
	// an adult "dying" just splits and gets back up as a baby, and babies get to keep their hats
	if(stat == DEAD)
		equipped_hat?.forceMove(drop_location())

/mob/living/basic/slime/Exited(atom/movable/gone, direction)
	if(gone == equipped_hat)
		equipped_hat = null
		regenerate_icons()
	return ..()

/mob/living/basic/slime/regenerate_icons()
	. = ..()
	if(stat == DEAD || isnull(equipped_hat))
		return
	var/mutable_appearance/hat_overlay = equipped_hat.build_worn_icon(default_layer = 0.15, default_icon_file = 'icons/mob/clothing/head/default.dmi')
	SET_PLANE_EXPLICIT(hat_overlay, PLANE_TO_TRUE(plane), src)
	hat_overlay.appearance_flags = RESET_COLOR|KEEP_APART
	hat_overlay.pixel_y += SLIME_HAT_PIXEL_Y
	add_overlay(hat_overlay)

/mob/living/basic/slime/proc/equip_hat(obj/item/item, mob/living/user)
	if(user)
		if(!user.transferItemToLoc(item, src))
			return
		user.visible_message(
			span_notice("[user] puts [item] on [name]'s head."),
			span_notice("You put [item] on [name]'s head."),
		)
	else
		item.forceMove(src)
	equipped_hat = item
	regenerate_icons()
	return TRUE

/datum/strippable_item/slime_head
	key = STRIPPABLE_ITEM_HEAD

/datum/strippable_item/slime_head/get_item(atom/source)
	var/mob/living/basic/slime/slime = source
	if(!istype(slime))
		return

	return slime.equipped_hat

/datum/strippable_item/slime_head/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	var/mob/living/basic/slime/slime = source
	if(!istype(slime))
		return FALSE

	if(slime.stat == DEAD)
		to_chat(user, span_warning("You can't put a hat on a dead slime."))
		return FALSE
	if(slime.equipped_hat)
		user.balloon_alert(user, "already wearing a hat!")
		return FALSE

/datum/strippable_item/slime_head/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/basic/slime/slime = source
	if(!istype(slime))
		return

	slime.equip_hat(equipping, user)

/datum/strippable_item/slime_head/finish_unequip(atom/source, mob/user)
	var/mob/living/basic/slime/slime = source
	if(!istype(slime))
		return

	user.put_in_hands(slime.equipped_hat)
	slime.equipped_hat = null
	slime.regenerate_icons()

#undef SLIME_HAT_PIXEL_Y

/obj/item/meteor_shield_capsule
	name = "meteor defense satellite capsule"
	desc = "A bluespace capsule which a single unit of meteor defense satellite is compressed within. If you activate this capsule, a meteor shield satellite will pop out. You still need to install these."
	icon = 'modular_oculis/modules/meteor_shields/icons/satellite.dmi'
	icon_state = "meteor_sat_capsule"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY

/obj/item/meteor_shield_capsule/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 0.5 SECONDS, /obj/machinery/satellite/meteor_shield)
	register_context()

/obj/item/meteor_shield_capsule/examine(mob/user)
	. = ..()
	. += span_notice("[EXAMINE_HINT("Right-click")] on the capsule while holding it to see a preview of its coverage.")

/obj/item/meteor_shield_capsule/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(held_item == src)
		context[SCREENTIP_CONTEXT_RMB] = "Toggle coverage preview"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/meteor_shield_capsule/Destroy(force)
	if(ismob(loc))
		close_meteor_sat_preview_for(loc, src)
	return ..()

/obj/item/meteor_shield_capsule/dropped(mob/user, silent)
	. = ..()
	close_meteor_sat_preview_for(user, src)

/obj/item/meteor_shield_capsule/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(!.)
		toggle_meteor_sat_preview_for(user, src)
		return TRUE

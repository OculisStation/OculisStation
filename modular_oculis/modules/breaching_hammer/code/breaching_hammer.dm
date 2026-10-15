/obj/item/melee/breaching_hammer
	name = "D-4 tactical hammer"
	desc = "A metallic-plastic composite breaching hammer, looks like a whack with this would severly harm or tire someone. It has a crowbar edge on the other end of it."
	icon = 'modular_nova/modules/sec_haul/icons/peacekeeper/peacekeeper_items.dmi'
	icon_state = "peacekeeper_hammer"
	inhand_icon_state = "peacekeeper_hammer"
	worn_icon_state = "classic_baton"
	lefthand_file = 'modular_nova/modules/sec_haul/icons/peacekeeper/baton/peacekeeper_baton_lefthand.dmi'
	righthand_file = 'modular_nova/modules/sec_haul/icons/peacekeeper/baton/peacekeeper_baton_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 20
	throwforce = 16
	w_class = WEIGHT_CLASS_HUGE
	attack_verb_continuous = list("whacks","breaches","bulldozes","flings","thwachs")
	attack_verb_simple = list("breach","hammer","whack","slap","thwach","fling")
	tool_behaviour = TOOL_CROWBAR

/obj/item/melee/breaching_hammer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/kneejerk)
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)
	AddComponent(/datum/component/item_killsound, \
	allowed_mobs = list(/mob/living/carbon/human), \
	killsound = 'sound/items/weapons/hammer_death_scream.ogg', \
	replace_default_death_sound = TRUE, \
	)

/obj/item/melee/breaching_hammer/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()

	if(!isliving(target))
		MODIFY_ATTACK_FORCE(attack_modifiers, 80)
	return FALSE

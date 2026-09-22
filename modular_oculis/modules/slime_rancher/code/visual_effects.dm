// yoinked from monkestation's slimecore
/obj/effect/abstract/visual_effect
	name = ""
	alpha = 150
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'modular_oculis/modules/slime_rancher/icons/visual_effects.dmi'
	vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	blend_mode = BLEND_INSET_OVERLAY

/obj/effect/abstract/visual_effect/rainbow
	icon_state = "rainbow"

/obj/effect/abstract/visual_effect/bluespace
	icon_state = "bluespace"
	alpha = 210

/obj/effect/abstract/visual_effect/gold
	icon_state = "gold"
	alpha = 210

/atom/movable/proc/add_visual_effect(effect_type)
	if(!ispath(effect_type, /obj/effect/abstract/visual_effect))
		CRASH("tried to pass invalid type ([effect_type]) to add_visual_effect!")
	appearance_flags &= ~KEEP_APART
	appearance_flags |= KEEP_TOGETHER
	vis_contents += new effect_type

/mob/living/basic/mining/watcher/cosmic_entity
	name = "entrenched outcrop"
	desc = "A surprisingly dense looking crystalline outcrop. It seems rooted into the floor."
	icon = 'modular_oculis/modules/event/icons/enemies.dmi'
	icon_state = "cosmic_diamond"
	maxHealth = 600
	health = 600
	melee_damage_lower = 30
	melee_damage_upper = 30
	ai_controller = /datum/ai_controller/basic_controller/watcher/cosmic_entity
	faction = list(FACTION_VIOLET)
	basic_mob_flags = DEL_ON_DEATH

/datum/ai_controller/basic_controller/watcher/cosmic_entity
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/complete_stop
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/watcher/watcher.bt.json"

/mob/living/basic/mining/hivelord/cosmic_entity
	name = "rising hatred"
	desc = "A series of strange purple parasitic creatures."
	faction = list(FACTION_VIOLET)
	basic_mob_flags = DEL_ON_DEATH

/mob/living/basic/mining/hivelord/cosmic_entity/Initialize(mapload)
	. = ..()
	spawn_brood.spawn_type = /mob/living/basic/hivelord_brood/cosmic_entity

/mob/living/basic/hivelord_brood/cosmic_entity
	name = "hatred"
	desc = "Short-lived attack form of the rising hatred. One isn't much of a threat, but..."
	faction = list(FACTION_VIOLET)
	melee_damage_lower = 6
	melee_damage_upper = 6

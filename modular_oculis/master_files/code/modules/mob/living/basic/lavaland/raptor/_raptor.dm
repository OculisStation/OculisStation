// Tamed raptors are faster on lavaland when being ridden.
/mob/living/basic/raptor/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	if(length(buckled_mobs) && SSmapping.level_trait(new_turf.z, ZTRAIT_ASHSTORM))
		add_movespeed_modifier(/datum/movespeed_modifier/lavaland_raptor)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/lavaland_raptor)

/mob/living/basic/raptor/post_buckle_mob(mob/living/buckled_mob)
	. = ..()
	var/turf/our_turf = get_turf(src)
	if(SSmapping.level_trait(our_turf.z, ZTRAIT_ASHSTORM))
		add_movespeed_modifier(/datum/movespeed_modifier/lavaland_raptor)

/mob/living/basic/raptor/post_unbuckle_mob(mob/living/unbuckled_mob)
	. = ..()
	if(!length(buckled_mobs))
		remove_movespeed_modifier(/datum/movespeed_modifier/lavaland_raptor)

/datum/movespeed_modifier/lavaland_raptor
	multiplicative_slowdown = -0.5
	blacklisted_movetypes = MOVETYPES_NOT_TOUCHING_GROUND

// Not easy to make them actually try to dodge goliath tentacles, so like,
// next best thing is giving them 50% block chance if they are currently caught by one?
/mob/living/basic/raptor/check_block(atom/hit_by, damage, attack_text, attack_type, armour_penetration, damage_type)
	. = ..()
	if(. == SUCCESSFUL_BLOCK)
		return
	// Raptors can no longer be entangled by goliath tentacles

/datum/targeting_strategy/basic/exact_match/ignore_friends/raptor

/datum/targeting_strategy/basic/exact_match/ignore_friends/raptor/is_valid_target(mob/living/living_mob, atom/the_target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if (!.)
		return FALSE
	if (ismegafauna(living_mob) || istype(living_mob, /mob/living/basic/raptor))
		return FALSE
	return TRUE

/datum/ai_controller/basic_controller/raptor/aggressive
	blackboard = list(
		BB_INTERACTIONS_WITH_OWNER = list(
			"pecks",
			"nuzzles",
			"wags their tail against",
			"playfully leans against"
		),
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/exact_match/ignore_friends/raptor,
		BB_HUNT_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/raptor),
		BB_MAX_CHILDREN = 5,
		BB_RAPTOR_FLEE_THRESHOLD = 0.1,
		BB_FUCKS = TRUE
	)

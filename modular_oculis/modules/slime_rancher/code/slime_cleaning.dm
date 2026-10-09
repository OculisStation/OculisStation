/// nutrition a dissolved mess gives, same as a wanted item
#define SLIME_CLEAN_NUTRITION 5

/mob/living/basic/slime/proc/can_dissolve(atom/movable/mess)
	var/static/list/dissolvable_cache
	if(isnull(dissolvable_cache))
		dissolvable_cache = typecacheof(list(
			/obj/effect/decal/cleanable/ants,
			/obj/effect/decal/cleanable/ash,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/decal/cleanable/confetti,
			/obj/effect/decal/cleanable/dirt,
			/obj/effect/decal/cleanable/food,
			/obj/effect/decal/cleanable/fuel_pool,
			/obj/effect/decal/cleanable/generic,
			/obj/effect/decal/cleanable/glass,
			/obj/effect/decal/cleanable/glitter,
			/obj/effect/decal/cleanable/greenglow,
			/obj/effect/decal/cleanable/insectguts,
			/obj/effect/decal/cleanable/molten_object,
			/obj/effect/decal/cleanable/shreds,
			/obj/effect/decal/cleanable/vomit,
			/obj/effect/decal/cleanable/wrapping,
			/obj/effect/decal/remains,
			/mob/living/basic/mouse,
			/mob/living/basic/cockroach,
			/obj/item/shard,
			/obj/item/trash,
			/obj/item/food/breadslice/moldy,
			/obj/item/food/pizzaslice/moldy,
			/obj/item/food/egg/rotten,
		))
		// stupid snowflake code to don't touch the slime mutation food subtypes
		for(var/slime_food_subtype in typesof(/mob/living/basic/cockroach/rockroach, /mob/living/basic/cockroach/iceroach, /mob/living/basic/cockroach/gemroach))
			dissolvable_cache[slime_food_subtype] = FALSE

	if(!isturf(mess.loc))
		return FALSE
	return is_type_in_typecache(mess, dissolvable_cache)

/mob/living/basic/slime/proc/set_cleaner_slime(enabled)
	cleaner_slime = !!enabled
	ai_controller?.clear_blackboard_key(BB_SLIME_CLEAN_TARGET)

/mob/living/basic/slime/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, cleaner_slime)) // special setter bc it messes with AI stuff
			set_cleaner_slime(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE
	return ..()

/mob/living/basic/slime/proc/try_dissolve(atom/movable/mess)
	if(!cleaner_slime || !can_dissolve(mess))
		return FALSE
	visible_message(span_notice("[src] dissolves \the [mess]."))
	balloon_alert_to_viewers("cleaned")
	qdel(mess)
	adjust_nutrition(SLIME_CLEAN_NUTRITION)
	return TRUE

/datum/target_source/slime_messes

/datum/target_source/slime_messes/collect_candidates(mob/living/basic/slime/pawn, datum/ai_controller/controller, range)
	. = list()
	for(var/atom/movable/candidate in oview(range, pawn))
		if(pawn.can_dissolve(candidate))
			. += candidate

/datum/targeting_strategy/slime_mess

/datum/targeting_strategy/slime_mess/is_valid_target(mob/living/basic/slime/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	return ismovable(target) && living_mob.can_dissolve(target)

/datum/bt_node/decorator/slime_is_cleaner

/datum/bt_node/decorator/slime_is_cleaner/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return istype(slime_pawn) && slime_pawn.cleaner_slime && !slime_pawn.buckled && !IS_UNCONSCIOUS_OR_CRIT(slime_pawn)

/datum/bt_node/ai_behavior/dissolve_mess

/datum/bt_node/ai_behavior/dissolve_mess/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/atom/movable/mess = controller.blackboard[BB_SLIME_CLEAN_TARGET]
	controller.clear_blackboard_key(BB_SLIME_CLEAN_TARGET)
	if(!istype(slime_pawn) || QDELETED(mess) || !slime_pawn.Adjacent(mess) || !slime_pawn.try_dissolve(mess))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

#undef SLIME_CLEAN_NUTRITION

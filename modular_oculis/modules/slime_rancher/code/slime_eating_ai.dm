/datum/ai_controller/basic_controller/slime
	ai_movement = /datum/ai_movement/basic_avoidance/adaptive
	behavior_tree_json = "modular_oculis/modules/slime_rancher/code/slime.bt.json"

/datum/bt_node/subtree/pet_command/attack/slime
	behavior_tree_json = "modular_oculis/modules/slime_rancher/code/pet_command_attack_slime.bt.json"

/// items the slime wants to eat, from BB_SLIME_WANTED_ITEMS, if it is set
/datum/target_source/slime_wanted_items

/datum/target_source/slime_wanted_items/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/list/wanted_types = controller.blackboard[BB_SLIME_WANTED_ITEMS]
	if(!length(wanted_types))
		return list()
	var/list/candidates = typecache_filter_list(oview(range, pawn), wanted_types)
	for(var/obj/item/slime_extract/extract in candidates)
		if(extract.fresh_from_slime)
			candidates -= extract
	return candidates

/// slimes will also chase down critters they still owe a mutation, hungry or not
/datum/targeting_strategy/slime_food/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	var/mob/living/basic/slime/slimey = living_mob
	// grudges still get fought, these two just don't go looking for a meal
	if(isliving(target) && !(target in controller?.blackboard[BB_BASIC_MOB_RETALIATE_LIST]))
		var/mob/living/candidate = target
		if(slimey.cleaner_slime)
			return FALSE
		if(slimey.cat_slime && candidate.mob_size >= slimey.mob_size)
			return FALSE

	. = ..()
	if(. || isnull(controller) || QDELETED(target))
		return .

	var/list/wanted_mobs = controller.blackboard[BB_SLIME_WANTED_MOBS]
	if(!wanted_mobs?[target.type])
		return FALSE

	return slimey.can_feed_on(target, silent = TRUE, check_adjacent = FALSE) && can_see(slimey, target, vision_range)

/datum/bt_node/decorator/slime_is_wild

/datum/bt_node/decorator/slime_is_wild/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn))
		return FALSE
	return !slime_pawn.is_ranched()

/// Chases like the generic leaf, except it sits still (and stays running) while latched onto or standing next to its target.
/datum/bt_node/ai_behavior/move_to_target/slime_chase

/datum/bt_node/ai_behavior/move_to_target/slime_chase/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(!QDELETED(target) && (pawn.buckled == target || pawn.Adjacent(target)))
		// the moveloop counts every step it doesn't take as a pathing failure, and 10 of those kills the chase
		if(controller.ai_movement.moving_controllers[controller])
			controller.ai_movement.stop_moving_towards(controller)
		movement_failed = FALSE
		return AI_BEHAVIOR_INSTANT
	return ..()

/// these branches only butt in when their key gets freshly set. if one bails partway (pathing gave up,
/// say) the key is still sitting there perfectly valid, so nothing ever re-sets it and the slime
/// wanders right past its target forever. dropping the target on the way out puts that edge back,
/// and the target sits in the ignore list for a few seconds so we pick something else meanwhile.
/datum/bt_node/decorator/bb_key_set/slime_target

/datum/bt_node/decorator/bb_key_set/slime_target/on_child_complete(datum/ai_controller/controller, result)
	var/atom/failed_target = controller.blackboard[key]
	// the parallel bails without resetting its primary, so the feed or melee leaf would sit there "running"
	child.reset_subtree_tick_states()
	if(!QDELETED(failed_target))
		astype(controller, /datum/ai_controller/basic_controller/slime)?.ignore_target(failed_target, SLIME_CHASE_GIVE_UP_TIME)
	controller.clear_blackboard_key(key)

/// for the branches right above random_walk, which loops forever and never lets the selector look back up here on its own
/datum/bt_node/decorator/bb_key_set/slime_target/idle
	observer_abort = BT_ABORT_LOWER_PRIORITY

/datum/bt_node/decorator/bb_key_set/slime_target/idle/on_observed_change(datum/ai_controller/controller, key)
	// the stock check trusts active_execution_index, which is junk inside our big parallel
	if(child_active || !evaluate_for_observer(controller))
		return
	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_DECISIONMAKING, "[controller.pawn] [type]: [src.key] got set while idling, replanning")
	controller.cancel_current_plan()

/// resets a lot of AI stuff so like, it'll get unstuck if AI got softlocked or something. hopefully.
/mob/living/basic/slime/proc/reset_stuck_ai()
	COOLDOWN_RESET(src, ranch_retry_cooldown)
	if(isnull(ai_controller))
		return
	for(var/stale_key in list(
		BB_SLIME_EAT_TARGET,
		BB_CURRENT_TARGET,
		BB_CURRENT_TARGET_HIDING_LOCATION,
		BB_SLIME_ITEM_TARGET,
		BB_SLIME_NUZZLE_TARGET,
		BB_SLIME_BOUNCE_TARGET,
		BB_SLIME_CLEAN_TARGET,
		BB_TEMPORARY_IGNORE_LIST,
		BB_BASIC_MOB_RETALIATE_LIST,
	))
		ai_controller.clear_blackboard_key(stale_key)
	refresh_wanted_targets()
	balloon_alert_to_viewers("shakes [p_themselves()] off")

/// Ignores a target until duration runs out. Never shortens an existing, longer ignore.
/datum/ai_controller/basic_controller/slime/proc/ignore_target(atom/target, duration)
	var/expires_at = world.time + duration
	if(LAZYACCESS(blackboard[BB_TEMPORARY_IGNORE_LIST], target) >= expires_at)
		return
	set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, target, expires_at)
	addtimer(CALLBACK(src, PROC_REF(expire_chase_exclusion), target, expires_at), duration)

/// Drops a chase exclusion we set, unless something longer-lived (a friend peeling us off) overwrote it since.
/datum/ai_controller/basic_controller/slime/proc/expire_chase_exclusion(atom/target, expires_at)
	if(LAZYACCESS(blackboard[BB_TEMPORARY_IGNORE_LIST], target) != expires_at)
		return
	remove_from_blackboard_lazylist_key(BB_TEMPORARY_IGNORE_LIST, target)

/// check to see if we're free to go eat items laying around
/datum/bt_node/decorator/bb_key_set/slime_target/forage
	polling_rate = 1 SECONDS

/// buckled/unconscious have no blackboard signal to hang off of, so poll the whole thing instead of
/// trusting the parent's key signals. otherwise we miss the moment the slime gets back up
/datum/bt_node/decorator/bb_key_set/slime_target/forage/register_observe_signals(atom/pawn)
	return FALSE

/datum/bt_node/decorator/bb_key_set/slime_target/forage/unregister_observe_signals(atom/pawn)
	return

/datum/bt_node/decorator/bb_key_set/slime_target/forage/check_condition(datum/ai_controller/controller)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn) || slime_pawn.buckled || IS_UNCONSCIOUS_OR_CRIT(slime_pawn))
		return FALSE
	return TRUE

/// small chance per tick for a slime to yoink a wanted item right out of an adjacent mob's hands
/// they don't chase people down, to be clear
/datum/bt_node/ai_behavior/snatch_held_item

/datum/bt_node/ai_behavior/snatch_held_item/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!SPT_PROB(15, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/list/wanted_types = controller.blackboard[BB_SLIME_WANTED_ITEMS]
	if(!istype(slime_pawn) || !length(wanted_types))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	for(var/mob/living/neighbor in oview(1, slime_pawn))
		for(var/obj/item/held in neighbor.held_items)
			if(!wanted_types[held.type])
				continue
			var/held_name = "\the [held]" // get this bc eating it might delete the item
			if(!slime_pawn.eat_wanted_item(held, silent = TRUE))
				continue
			slime_pawn.visible_message(
				span_notice("[slime_pawn] snatches [held_name] right out of [neighbor]'s hands!"),
				span_notice("You snatch [held_name] right out of [neighbor]'s hands!")
			)
			slime_pawn.balloon_alert_to_viewers("snatches item out of hand!")
			slime_pawn.set_temporary_mood(SLIME_MOOD_MISCHIEVOUS)
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

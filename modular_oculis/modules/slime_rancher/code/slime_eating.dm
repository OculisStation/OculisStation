/// returns a list of items this slime can eat for mutations (which it hasn't eaten already), plus a breeding pellet if it's not already primed to split
/mob/living/basic/slime/proc/get_wanted_item_types() as /list
	. = list()
	for(var/datum/slime_mutation/mutation as anything in mutation_progress)
		. |= mutation.needed_items
	if(/obj/item/stack/ore/bluespace_crystal in .)
		. |= /obj/item/stack/sheet/bluespace_crystal
	if(!primed_split_cost)
		. |= /obj/item/slime_breeding_pellet

/// returns a list of mob types this slime can drain for mutations, finished quotas included -
/// a pen stocked only with critters still has to be able to feed a slime up to its next outcome
/mob/living/basic/slime/proc/get_wanted_mob_types() as /list
	. = list()
	for(var/datum/slime_mutation/mutation as anything in mutation_progress)
		for(var/mob_type, drain_total in mutation.latch_totals)
			. |= mob_type

/mob/living/basic/slime/proc/refresh_wanted_targets()
	if(isnull(ai_controller))
		return
	ai_controller.override_blackboard_key(BB_SLIME_WANTED_ITEMS, typecacheof(get_wanted_item_types()))
	ai_controller.override_blackboard_key(BB_SLIME_WANTED_MOBS, typecacheof(get_wanted_mob_types()))

/// Eats meal, whether it's sitting on the floor or in someone's hands. Returns TRUE if it was eaten.
/// silent skips the default "slurps up" message, for callers with their own wording (like when it yoinks an item out of your hand).
/mob/living/basic/slime/proc/eat_wanted_item(obj/item/meal, silent = FALSE)
	// bail on the AI's stale target regardless of what happens below - it either just got eaten,
	// or it's not wanted anymore, and either way the AI shouldn't keep whacking it
	if(ai_controller?.blackboard[BB_SLIME_ITEM_TARGET] == meal)
		ai_controller.clear_blackboard_key(BB_SLIME_ITEM_TARGET)

	if(astype(meal, /obj/item/slime_extract)?.fresh_from_slime)
		return FALSE

	if(!(SEND_SIGNAL(src, COMSIG_SLIME_CHECK_WANTED_ITEM, meal) & COMPONENT_SLIME_WANTS_ITEM))
		return FALSE

	var/meal_name = "\the [meal]" // get this bc eating it might delete the item
	var/meal_type = meal.type

	if(isstack(meal))
		var/obj/item/stack/meal_stack = meal
		if(!meal_stack.use(1))
			return FALSE
	else
		var/mob/holder = meal.loc
		if(ismob(holder) && !holder.temporarilyRemoveItemFromInventory(meal))
			return FALSE
		qdel(meal)

	SEND_SIGNAL(src, COMSIG_SLIME_ATE_ITEM, meal_type)
	if(ispath(meal_type, /obj/item/slime_breeding_pellet))
		set_primed_split_cost(SLIME_RANCH_PELLET_SPLIT_COST)
	else if(life_stage == SLIME_LIFE_STAGE_ADULT)
		try_ranch_outcome()

	if(!silent)
		visible_message(
			span_notice("[src] slurps up [meal_name]!"),
			span_notice("You slurp up [meal_name]!")
		)
		balloon_alert_to_viewers("slurps up item")
	playsound(src, 'sound/items/eatfood.ogg', vol = 50, vary = TRUE) // yumy
	adjust_nutrition(5)
	refresh_wanted_targets()
	return TRUE

/// The mutation this slime has fully fed for, if any. Random among ties.
/mob/living/basic/slime/proc/get_unlocked_mutation_type(weight_new_types = FALSE)
	var/list/unlocked = list()
	for(var/datum/slime_mutation/mutation as anything in mutation_progress)
		if(!mutation.is_satisfied())
			continue
		unlocked[mutation.mutates_into] = (weight_new_types && !(mutation.mutates_into in GLOB.obtained_slime_types)) ? 10 : 1

	if(length(unlocked))
		return pick_weight(unlocked)

/mob/living/basic/slime/set_slime_type(new_type = SLIME_TYPE_RANDOM)
	. = ..()
	pending_ranch_mutation = null
	LAZYOR(GLOB.obtained_slime_types, slime_type.type)
	QDEL_LIST(mutation_progress)
	mutation_progress = list()
	for(var/mutation_type in slime_type.possible_mutations)
		var/datum/slime_mutation/mutation = new mutation_type(src)
		mutation_progress += mutation
		for(var/mob_type in mutation.latch_totals)
			LAZYOR(GLOB.unlocked_xenofauna, mob_type)
	refresh_wanted_targets()

/// What this slime turns into when it reproduces. Returning our own type means an ordinary split.
/// Mutating is ranching's job now (see try_ranch_outcome in slime_ranching.dm) - splitting never mutates,
/// except pyrite slimes, who are cursed/blessed to always roll random regardless of how they split.
/// Never returns null - a null here nukes slime_type and takes the mob with it.
/mob/living/basic/slime/get_random_mutation()
	if(transformative_effect == SLIME_TYPE_PYRITE)
		return pick(subtypesof(/datum/slime_type) - /datum/slime_type/rainbow - typesof(/datum/slime_type/unique))
	return slime_type.type

/// lets a slime eat a wanted item just by attacking it - covers both the AI's own melee attack leaf and a player clicking it themselves
/mob/living/basic/slime/on_slime_pre_attack(mob/living/basic/slime/our_slime, atom/target, proximity, modifiers)
	if(isitem(target) && our_slime.eat_wanted_item(target))
		return COMPONENT_HOSTILE_NO_ATTACK
	return ..()

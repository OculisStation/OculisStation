/obj/item/slimecross/reproductive
	effect_desc = "When fed biomass cubes it produces more extracts. Bio bag compatible as well."
	/// Biomass needed to produce another batch of extracts.
	var/biomass_cost = 3
	/// Biomass already eaten toward the next batch.
	var/biomass_eaten = 0

/obj/item/slimecross/reproductive/examine()
	. = ..()
	. += span_danger("It appears to have eaten [biomass_eaten] of [biomass_cost] biomass cubes.")

/obj/item/slimecross/reproductive/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/food/monkeycube))
		balloon_alert(user, "wants biomass!")
		return ITEM_INTERACT_BLOCKING

	if(!istype(tool, /obj/item/stack/biomass) && !istype(tool, /obj/item/storage/bag/xeno))
		return NONE

	if(world.time < last_produce + cooldown)
		to_chat(user, span_warning("[src] is still digesting!"))
		return ITEM_INTERACT_BLOCKING

	var/biomass_needed = biomass_cost - biomass_eaten
	var/biomass_fed = 0
	if(istype(tool, /obj/item/storage/bag/xeno))
		for(var/obj/item/stack/biomass/biomass_cubes in tool)
			var/used_biomass = min(biomass_cubes.amount, biomass_needed - biomass_fed)
			if(!used_biomass)
				continue
			biomass_cubes.use(used_biomass)
			biomass_fed += used_biomass
			if(biomass_fed == biomass_needed)
				break
	else
		var/obj/item/stack/biomass/biomass_cubes = tool
		biomass_fed = min(biomass_cubes.amount, biomass_needed)
		biomass_cubes.use(biomass_fed)

	if(!biomass_fed)
		balloon_alert(user, "no biomass!")
		return ITEM_INTERACT_BLOCKING

	biomass_eaten += biomass_fed
	playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
	to_chat(user, span_notice("You feed [biomass_fed] biomass cube[biomass_fed == 1 ? "" : "s"] to [src], and it pulses gently."))
	if(biomass_eaten < biomass_cost)
		return ITEM_INTERACT_SUCCESS

	biomass_eaten = 0
	var/produced_extracts = rand(1, 4)
	playsound(src, 'sound/effects/splat.ogg', 40, TRUE)
	to_chat(user, span_notice("The extract quivers, then produces [produced_extracts] matching extract[produced_extracts == 1 ? "" : "s"]!"))
	last_produce = world.time
	for(var/i in 1 to produced_extracts)
		new extract_type(drop_location())
	return ITEM_INTERACT_SUCCESS

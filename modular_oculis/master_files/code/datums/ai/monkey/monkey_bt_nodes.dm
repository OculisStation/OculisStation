// SLIME_RANCHER - why do monkeys love breaking lights so much?
/datum/target_source/monkey_press_target/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	. = ..()
	if(!controller.blackboard[BB_MONKEY_PENNED])
		return .
	for(var/obj/machinery/light/light in .)
		. -= light

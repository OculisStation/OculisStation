/mob/living/basic/slime
	var/list/datum/slime_mutation/mutation_progress

/mob/living/basic/slime/Initialize(mapload, new_type, new_life_stage)
	pet_commands |= /datum/pet_command/slime_split
	. = ..()
	ADD_TRAIT(src, TRAIT_DOESNT_SQUASH, INNATE_TRAIT) // so we don't squash iceroaches and such. slimes are soft and squishy it makes sense.
	AddElement(/datum/element/pet_bonus, "jiggle")
	RegisterSignal(src, COMSIG_SLIME_LATCH_DRAINED, PROC_REF(on_ranch_drain))
	RegisterSignal(src, COMSIG_SLIME_CHECK_WANTED_ITEM, PROC_REF(on_check_wanted_pellet))
	RegisterSignal(src, COMSIG_ANIMAL_PET, PROC_REF(on_petted))
	RegisterSignals(src, list(COMSIG_SLIME_ATE_ITEM, COMSIG_LIVING_BEFRIENDED), PROC_REF(on_slime_happy_yay))
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(crush_the_monkey_rebels))

/mob/living/basic/slime/Destroy()
	QDEL_LIST(mutation_progress)
	return ..()

/mob/living/basic/slime/death(gibbed)
	. = ..()
	pending_ranch_mutation = null

// a monkey swinging at one slime gets the whole pen mad at it
/mob/living/basic/slime/proc/crush_the_monkey_rebels(datum/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER
	if(!ismonkey(attacker))
		return
	for(var/mob/living/basic/slime/buddy in oview(SLIME_MONKEY_RALLY_RANGE, src))
		if(buddy.stat)
			continue
		buddy.ai_controller?.set_blackboard_key_assoc_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker, world.time)

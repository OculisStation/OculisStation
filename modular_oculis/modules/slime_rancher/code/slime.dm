/mob/living/basic/slime
	var/list/datum/slime_mutation/mutation_progress
	/// Only goes after mobs smaller than us.
	var/cat_slime = FALSE
	/// How many damaging hits in a row a cat slime has put up with so far
	var/cat_patience_hits = 0
	var/cat_patience_last_hit = 0
	/// Cleans messes and pests instead of hunting.
	var/cleaner_slime = FALSE

/mob/living/basic/slime/Initialize(mapload, new_type, new_life_stage)
	pet_commands |= /datum/pet_command/slime_split
	. = ..()
	ADD_TRAIT(src, TRAIT_DOESNT_SQUASH, INNATE_TRAIT) // so we don't squash iceroaches and such. slimes are soft and squishy it makes sense.
	AddElement(/datum/element/pet_bonus, "jiggle")
	AddElement(/datum/element/strippable, GLOB.strippable_slime_items)
	// on_attacked keeps the grudge list itself, bc a cat slime has to be able to say "nah" to a grudge
	RemoveElement(/datum/element/ai_retaliate)
	RegisterSignal(src, COMSIG_SLIME_LATCH_DRAINED, PROC_REF(on_ranch_drain))
	RegisterSignal(src, COMSIG_SLIME_CHECK_WANTED_ITEM, PROC_REF(on_check_wanted_pellet))
	RegisterSignal(src, COMSIG_ANIMAL_PET, PROC_REF(on_petted))
	RegisterSignal(src, COMSIG_SLIME_ATE_ITEM, PROC_REF(on_slime_happy_yay))
	RegisterSignal(src, COMSIG_LIVING_BEFRIENDED, PROC_REF(on_befriended))
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/mob/living/basic/slime/Destroy()
	QDEL_LIST(mutation_progress)
	return ..()

/mob/living/basic/slime/death(gibbed)
	. = ..()
	pending_ranch_mutation = null

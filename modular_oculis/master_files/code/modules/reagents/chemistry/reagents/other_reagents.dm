///Metabolizes a portion of the reagent after on_mob_life() is called
/datum/reagent/blood/metabolize_reagent(mob/living/carbon/affected_mob, seconds_per_tick, metabolized_volume)
	. = ..()

	if(ishemophage(affected_mob))
		affected_mob.adjust_blood_volume(metabolized_volume * seconds_per_tick, 0, BLOOD_VOLUME_MAXIMUM)

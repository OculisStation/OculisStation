/mob/living/basic/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed && life_stage == SLIME_LIFE_STAGE_ADULT && !blocks_reproduction) // OCULIS EDIT CHANGE - SLIME_RANCHER - ORIGINAL: if(!gibbed && life_stage == SLIME_LIFE_STAGE_ADULT)
		var/mob/living/basic/slime/new_slime = new(drop_location(), slime_type.type)

		new_slime.ai_controller?.set_blackboard_key(BB_SLIME_RABID, TRUE)
		new_slime.regenerate_icons()

		//revives us as a baby
		set_life_stage(SLIME_LIFE_STAGE_BABY)
		SEND_SIGNAL(src, COMSIG_SLIME_SPLIT, new_slime) // OCULIS EDIT ADDITION - SLIME_RANCHER
		revive(HEAL_ALL)
		regenerate_icons()
		update_name()
		return

	if(buckled)
		stop_feeding(silent = TRUE) //releases ourselves from the mob we fed on.

	cut_overlays()

	return ..(gibbed)

/mob/living/basic/slime/gib()
	death(TRUE)
	qdel(src)

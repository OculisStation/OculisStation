// SLIME_RANCHER - penned slimes only respond to voice commands if ur in the same pen as them
/datum/pet_command/respond_to_command(mob/living/speaker, speech_args)
	var/mob/living/basic/slime/slime = astype(weak_parent.resolve())
	if(slime?.pen && !(speaker.loc in slime.pen.turfs))
		return
	return ..()

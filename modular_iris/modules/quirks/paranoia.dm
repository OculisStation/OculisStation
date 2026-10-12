//Quirk ported from https://github.com/Monkestation/Monkestation2.0/pull/313
/datum/quirk/extra_sensory_paranoia
	name = "Extra-Sensory Paranoia"
	desc = "You feel like something wants to kill you... The hallucinations are physical and can harm you! NOT RECOMMENDED FOR NEW PLAYERS!"
	mob_trait = TRAIT_PARANOIA
	value = -8
	icon = FA_ICON_FIRST_AID
	medical_record_text = "Patient shows signs of scopophobia, and appears to suffer from vivid hallucinations."

/datum/quirk/extra_sensory_paranoia/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(ishuman(human_holder))
		human_holder.gain_trauma(/datum/brain_trauma/magic/stalker, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/extra_sensory_paranoia/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(ishuman(human_holder))
		human_holder.cure_trauma_type(/datum/brain_trauma/magic/stalker, TRAUMA_RESILIENCE_ABSOLUTE)

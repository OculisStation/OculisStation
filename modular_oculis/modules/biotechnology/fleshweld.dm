/obj/item/organ
	var/can_bioboost = FALSE
	var/bioboost_start_message = null
	var/bioboost_end_message = null
	var/bioboost_duration = null
	var/bioboost_cooldown = null

/obj/item/organ/proc/start_bioboost()
	organ_flags |= ORGAN_BIOBOOSTED
	if(bioboost_start_message)
		to_chat(owner, bioboost_start_message)

/obj/item/organ/proc/end_bioboost()
	organ_flags &= ~ORGAN_BIOBOOSTED
	if(bioboost_end_message)
		to_chat(owner, bioboost_end_message)

/obj/item/organ/Remove(mob/living/carbon/organ_owner, special, movement_flags)
	end_bioboost()
	. = ..()


/obj/item/organ/bioimplant/fleshwelder
	name = "fleshwelding gland"
	desc = "This bioengineered circulatory organ stimulates immune responses to tissue damage. Overstressing the gland may lead to pain, fatigue, internal bleeding, or poisoning."
	icon_state = "heart-on"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_FLESHWELD
	item_flags = NO_BLOOD_ON_ITEM
	healing_factor = STANDARD_ORGAN_HEALING

	low_threshold_passed = span_info("Your skin crawls and your gut sinks, like drinking far too much cold water.")
	high_threshold_passed = span_warning("There's a abrasive fuzz in your joints and a painful needling in your muscles.")
	now_fixed = span_info("The sense of decomposition fades.")
	now_failing = span_danger("Everything aches. Nothing moves like it should. It feels like you're falling apart!")
	high_threshold_cleared = span_info("The fuzz fades, and the needling retreats.")
	low_threshold_cleared = span_info("The crawling cold fades and your stomach settles down.")

	attack_verb_continuous = list("glands", "welds")
	attack_verb_simple = list("gland", "weld")
	can_bioboost = TRUE
	bioboost_start_message = span_info("Your flesh aches with a revitalizing heat!")
	bioboost_end_message = span_info("The revitalizing heat fades.")

	// meds are stored in the... medicine sac i guess??
	food_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue = 5, /datum/reagent/medicine/fleshsolder = 5)
	var/power = 1
	var/bloodfix = 1
	var/burnfix = 1
	var/bonefix = 0
	var/damage_modifier = 1

/obj/item/organ/bioimplant/fleshwelder/on_life(seconds_per_tick)
	. = ..()
	if(organ_flags & ORGAN_FAILING)
		if(SPT_PROB(10, seconds_per_tick))
			owner.adjust_brute_loss(20)
			to_chat(owner, span_danger("It feels like your blood is frozen!"))
			owner.vomit(VOMIT_CATEGORY_BLOOD)
		return
	if(damage > high_threshold)
		if(SPT_PROB(5, seconds_per_tick))
			to_chat(owner, span_warning("The fuzz flares to an agonizing potency!"))
			owner.adjust_dizzy_up_to(20 SECONDS, 1 MINUTES)
			owner.adjust_jitter_up_to(1 MINUTE, 5 MINUTES)
			if(prob(20))
				owner.vomit(VOMIT_CATEGORY_BLOOD)
	else if(damage > low_threshold)
		if(SPT_PROB(5, seconds_per_tick))
			to_chat(owner, span_warning("You feel cold."))
			owner.emote("shiver")
			owner.adjust_jitter_up_to(20 SECONDS, 2 MINUTES)
	for(var/datum/wound/toweld as anything in owner.all_wounds)
		var/self_damage = toweld.on_fleshweld(power, bloodfix, burnfix, bonefix)
		if(self_damage)
			apply_organ_damage(self_damage * damage_modifier)

/obj/item/organ/bioimplant/fleshwelder/start_bioboost()
	. = ..()
	power *= 10
	damage_modifier *= 20

/obj/item/organ/bioimplant/fleshwelder/end_bioboost()
	. = ..()
	power /= 10
	damage_modifier /= 20

/obj/item/organ/bioimplant/fleshwelder/weak
	name = "weak fleshwelding gland"
	desc = /obj/item/organ/bioimplant/fleshwelder::desc + " This one is only about half as efficient."
	power = 0.5

/datum/design/fleshwelder
	name = "Fleshwelding Gland (Weak)"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/mine_salve = 10, /datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/inverse/aranesp = 10)
	build_path = /obj/item/organ/bioimplant/fleshwelder/weak
	category = list("Bioimplants")

/datum/design/fleshwelder
	name = "Fleshwelding Gland"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/fleshsolder = 15, /datum/reagent/medicine/c2/synthflesh = 15)
	build_path = /obj/item/organ/bioimplant/fleshwelder
	category = list("Bioimplants")

/datum/wound/proc/on_fleshweld(power, bloodfix, burnfix, bonefix)
	return 0

/datum/wound/burn/flesh/on_fleshweld(power, bloodfix, burnfix, bonefix)
	if(burnfix == 0)
		return 0
	infection = min((infection - (0.05 * burnfix * power)), 0)
	flesh_damage = min((flesh_damage - (0.05 * burnfix * power)), 0)
	return 0.2

/datum/wound/slash/flesh/on_fleshweld(power, bloodfix, burnfix, bonefix)
	if(bloodfix == 0)
		return 0
	blood_flow = min((blood_flow -(0.05 * bloodfix * power)), 0)
	return 0.2

/datum/wound/pierce/on_fleshweld(power, bloodfix, burnfix, bonefix)
	if(bloodfix == 0)
		return 0
	blood_flow = min((blood_flow -(0.05 * bloodfix * power)), 0)
	return 0.4 //punctures are harder to clot

/datum/wound/blunt/bone/on_fleshweld(power, bloodfix, burnfix, bonefix)
	if(bonefix == 0)
		return 0
	cryo_progress += 0.5 * power * bonefix
	return 0.5 //bones are quite heavy

// i needed a thematically appropriate reagent to make the fleshwelder out of. so here we have this now. Enjoy!
/datum/reagent/medicine/fleshsolder
	name = "Fleshwelding Serum"
	color = "#226688"
	taste_description = "a draining painful chill that pierces the tongue"
	taste_mult = 20 // it starts to regen your mouth as you drink it! This is quite painful! Fun!
	description = "This experimental serum induces a powerful regenerative effect that repairs wounds over time while causing intense pain, fatigue, and even severe toxicity and organ damage, depending on dosage. 5 units or less is generally safe. Between 5 and 10 units is moderately toxic. Between 10 and 15 units is extremely poisonous to the organs. At dosages above 15 units, critical condition is likely. Potency of regenerative effect is massively increased per dosage tier."
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED | REAGENT_DEAD_PROCESS

/datum/reagent/medicine/fleshsolder/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	switch(current_cycle)
		if(2)
			to_chat(affected_mob, span_warning("You feel cold. Very, very, cold."))
		if(3 to 10)
			fleshweldit(1, 1, 2, 1, affected_mob)
			if(prob(25))
				to_chat(affected_mob, span_warning("Your skin stings with a pervasive chill."))
				affected_mob.adjust_stamina_loss(20)
				affected_mob.adjust_jitter_up_to(20 SECONDS, 5 MINUTES)
		if(11 to 20)
			fleshweldit(2, 1, 2, 2, affected_mob)
			if(prob(35))
				to_chat(affected_mob, span_warning("You feel <i>horrible.</i> Every motion is a struggle."))
				affected_mob.adjust_stamina_loss(30)
				affected_mob.adjust_jitter_up_to(1 MINUTES, 10 MINUTES)
				affected_mob.adjust_eye_blur(2 SECONDS)
				affected_mob.adjust_tox_loss(2, forced = TRUE)
		if(21 to 30)
			fleshweldit(3, 2, 2, 2, affected_mob)
			if(prob(50))
				to_chat(affected_mob, span_danger("HOLY FUCK IT *BURNS!*"))
				affected_mob.adjust_stamina_loss(40)
				affected_mob.emote("scream")
				affected_mob.adjust_eye_blur(2 SECONDS)
				affected_mob.adjust_jitter_up_to(1 MINUTES, 10 MINUTES)
				affected_mob.adjust_tox_loss(5, forced = TRUE)
				for(var/obj/item/organ/ouch as anything in affected_mob.organs)
					if(prob(50))
						ouch.apply_organ_damage(ouch.maxHealth * 0.1)
		if(31 to INFINITY) // more than one full-ass syringe (aka, you chose this you dingus (or severe medical malpractice ig))
			to_chat(affected_mob, span_danger("You think you're falling apart. Suddenly, the pain stops. You can't move. Everything cuts to black."))
			fleshweldit(100, 2, 2, 2, affected_mob)
			affected_mob.adjust_tox_loss(100)
			affected_mob.Unconscious(10 SECONDS)
			volume = 0



/datum/reagent/medicine/fleshsolder/proc/fleshweldit(power, bloodfix, burnfix, bonefix, mob/living/carbon/affected_mob)
	for(var/datum/wound/toweld in affected_mob.all_wounds)
		toweld.on_fleshweld(power, bloodfix, burnfix, bonefix)

/datum/chemical_reaction/medicine/fleshsolder
	results = list(/datum/reagent/medicine/fleshsolder = 2)
	required_reagents = list(/datum/reagent/medicine/polypyr = 1, /datum/reagent/consumable/nutriment/organ_tissue = 1)
	required_temp = 50
	is_cold_recipe = TRUE
	optimal_temp = 30
	optimal_ph_min = 9
	optimal_ph_max = 9.5
	determin_ph_range = 0.5
	temp_exponent_factor = 2
	ph_exponent_factor = 0.5
	thermic_constant = -30
	H_ion_release = -5
	rate_up_lim = 20 //affected by pH too
	purity_min = 0.3
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_HEALING

/datum/micro_organism/cell_line/organs/fleshwelderweak
	desc = "diminished fleshwelding cells"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/iron = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/mutagen = -2,
	)

	resulting_atom = /obj/item/organ/liver

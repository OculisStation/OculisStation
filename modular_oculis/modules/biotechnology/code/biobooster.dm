/obj/item/organ
	var/can_bioboost = FALSE
	var/bioboost_start_message = null
	var/bioboost_end_message = null
	var/bioboost_duration = null
	var/bioboost_cooldown = null

/obj/item/organ/proc/start_bioboost(powermult)
	organ_flags |= ORGAN_BIOBOOSTED
	if(bioboost_start_message)
		to_chat(owner, bioboost_start_message)

/obj/item/organ/proc/end_bioboost(powermult)
	organ_flags &= ~ORGAN_BIOBOOSTED
	if(bioboost_end_message)
		to_chat(owner, bioboost_end_message)

/obj/item/organ/Remove(mob/living/carbon/organ_owner, special, movement_flags)
	end_bioboost()
	. = ..()

/obj/item/organ/bioimplant/biobooster
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

/obj/item/organ/cyberimp/caffinator
	name = "\improper NT-CFFE Caffinator"
	desc = "This coffee-maker integrates into the thigh and uses confidental convertotronological methods to produce delicious coffee from bloodstream nutrients. Refill cup dispenser by activating implant while holding cardboard or empty cups."
	special_desc = "Genuinely, what does convertotronology even mean? That's <b>definitely</b> a neologism and not a real word. It's not even a well-constructed neologism. Who would <b>MANUFACTURE THIS?</b> Question two: who would <b>BUY THIS?</b>"
	icon_state = "nutriment_implant"
	zone = BODY_ZONE_R_LEG
	valid_zones = list(
		BODY_ZONE_R_LEG = ORGAN_SLOT_CAFFINATOR_R,
		BODY_ZONE_L_LEG = ORGAN_SLOT_CAFFINATOR_L,
	)
	slot = ORGAN_SLOT_CAFFINATOR_R
	actions_types = list(/datum/action/item_action/organ_action/use)
	icon = 'modular_oculis/modules/cybernetics/icons/newcybers.dmi'
	icon_state = "ntcffecaffinator"
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 3,
	)
	var/numberofcups = 10
	COOLDOWN_DECLARE(dispense_cooldown)
	var/dispensedreagent = /datum/reagent/consumable/coffee
	var/dispensedamount = 30
	var/cost = 30
	var/cooldown_time = 5 SECONDS

/obj/item/organ/cyberimp/caffinator/ui_action_click()
	if(istype(owner.get_active_held_item(), /obj/item/reagent_containers/cup/glass/coffee))
		var/obj/item/reagent_containers/cup/glass/coffee_cup/recycleit = owner.get_active_held_item()
		if(recycleit.reagents.total_volume != 0)
			owner.balloon_alert(owner, "can't recycle, not empty!")
			return
		owner.visible_message(span_notice("[owner] eats [recycleit]."), span_notice("You eat [recycleit], [src] converting it into usable cup fabrication ingredients."))
		numberofcups += 0.5
		to_chat(owner, span_notice("Microfabricator supplies replenished. [numberofcups] cups now available."))
		qdel(recycleit)
		playsound_if_pref(owner.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE, pref_to_check = /datum/preference/toggle/sound_eating)
		return
	if(istype(owner.get_active_held_item(), /obj/item/stack/sheet/cardboard))
		var/obj/item/stack/sheet/cardboard/thestack = owner.get_active_held_item()
		owner.visible_message(span_notice("[owner] eats some of [thestack]."), span_notice("You eat some of [thestack], [src] converting it into usable cup fabrication ingredients."))
		thestack.use(1)
		numberofcups += 1
		to_chat(owner, span_notice("Microfabricator supplies replenished. [numberofcups] cups now available."))
		playsound_if_pref(owner.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE, pref_to_check = /datum/preference/toggle/sound_eating)
		return
	if(owner.get_active_held_item())
		owner.balloon_alert(owner, "hand full!")
		return
	if(!COOLDOWN_FINISHED(src, dispense_cooldown))
		owner.balloon_alert(owner, "on cooldown!")
		return
	if(numberofcups < 1)
		owner.balloon_alert(owner, "no cups left!")
		return
	COOLDOWN_START(src, dispense_cooldown, cooldown_time)
	owner.adjust_nutrition(-cost)
	var/obj/item/reagent_containers/cup/glass/coffee/ourcup = new(owner.loc)
	ourcup.reagents.clear_reagents()
	fill_cup(ourcup)
	owner.put_in_hands(ourcup)
	playsound(src, 'sound/machines/coffeemaker_brew.ogg', 20, vary = TRUE)
	owner.visible_message(span_notice("[owner]'s reaches down to [owner.p_their()] hip and is suddenly holding [ourcup]!"), span_notice("You reach down to your hip and activate [src], dispensing a delicious beverage right into your hand."))
	numberofcups -= 1
	to_chat(owner, span_notice("[numberofcups] cups now available."))
	return

/obj/item/organ/cyberimp/caffinator/proc/fill_cup(thecup)
	var/obj/item/reagent_containers/thiscup = thecup
	if(!istype(thiscup))
		return
	thiscup.reagents.add_reagent(dispensedreagent, dispensedamount)
	return

/obj/item/organ/cyberimp/caffinator/emp_act(severity)
	. = ..()
	if(numberofcups < 1)
		return
	owner.visible_message(span_danger("[src] in [owner]'s leg malfunctions, dispensing cupfuls of blood!"))
	for(var/i in 1 to floor(numberofcups))
		var/obj/item/reagent_containers/cup/glass/coffee/ourcup = new(owner.loc)
		ourcup.reagents.clear_reagents()
		owner.transfer_blood_to(ourcup, dispensedamount)
	numberofcups = 0
	playsound(src, 'sound/machines/coffeemaker_brew.ogg', 50, vary = TRUE)

/obj/item/organ/cyberimp/caffinator/left
	zone = BODY_ZONE_L_LEG
	slot = ORGAN_SLOT_CAFFINATOR_L

/obj/item/organ/cyberimp/caffinator/unloaded
	numberofcups = 0

/datum/augment_item/implant/caffinator
	name = "NT-CFFE Caffinator"
	extra_info = "Makes coffee from nutrition."
	cost = 2
	path = /obj/item/organ/cyberimp/caffinator
	slot = AUGMENT_SLOT_R_LEG

/datum/augment_item/implant/caffinator/left
	path = /obj/item/organ/cyberimp/caffinator/left
	slot = AUGMENT_SLOT_L_LEG

/datum/design/caffinator
	name = "NT-CFFE Caffinator"
	desc = "This thigh-implanted cybernetic utilizes the very real science of hemosuccoric convertotronology to transmute bloodborne nutrients into tasty and energizing coffee! Contains integrated cup dispenser and cardboard recycler. (Cardboard not included.)"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 6 SECONDS
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 3,
	)
	build_path = /obj/item/organ/cyberimp/caffinator/unloaded
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/techweb_node/cyber/caffinator
	display_name = "Hemosuccoric Convertotronology"
	description = "Blood = Coffee"
	prerequisite_nodes = list(/datum/techweb_node/food_proc, /datum/techweb_node/cyber/cyber_implants)
	unlocked_designs = list(/datum/design/caffinator)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SERVICE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SCIENCE)

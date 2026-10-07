/mob/living/simple_animal/formic/scarlet_ferryman
	name = "Scarlet Ferryman"
	desc = "You can only barely make out the skeleton beneath the cloak."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry.dmi'
	icon_state = "ferry"
	spoken_lang = /datum/language/sylvan

	nanotrasen_id = "NT-ARDB-012"
	primary_hazard_labels = "Causalhazard"
	secondary_hazard_labels = "N/A"
	initial_line = "Willow. Yew. Hawthorn. Fir. Magnolia. Will you hunt for me?"
	hidden_description = "An animate skeleton draped in a deep-red cloak comprised of an unknown leather. Its form, unlike most ARFs, seems to contain a multitude of other, smaller signatures, which it seems to want others to hunt for it. Occasionally, it speaks in a phonetic alphabet comprised of names of tree species."

	dialogue_lines = list(
		"Willow. Magnolia. Tamarack.",
		"The toxin of a slumbering mosquito, the capacitor of the jolt grapes...",
		"Cadaga. Yew. Hawthorn.",
		"Continue your work, and I will continue my pay.",
		"The claw of a golden lobstrosity, the tongue of a dunespider...",
		"We are both scientists, in a certain sense.",
		"What is the value of a life to you?"
	)
	echoes = list(
		"i will hunt for you",
		"what is my task"
	)
	talksound = 'sound/mobs/humanoids/shadow/shadow_wail.ogg'

	var/obj/item/trophy/current_bounty
	var/list/obj/item/trophy/trophies = list( //bounty dialogue is stored in the same list to save time and such
		/obj/item/trophy/dunespider_tongue = "The tongue of a dunespider. Any spider should suffice for transmutation.",
		/obj/item/trophy/jolt_capacitor = "The capacitor of some jolt grapes. Only sholean grapes grown in your wretched vats will metamorphize.",
		/obj/item/trophy/blood_skull = "A skull from within a blood cube. A gelatinous cube should transmute correctly.",
		/obj/item/trophy/catacomb_signet = "The signet of a catacomb turtle. After shifting a turtle, it should be connected with their heart. Banyan. Tamarack.",
		/obj/item/trophy/golden_claw = "The claw of a golden lobstrosity. Any variety of lobstrosity should do for transmuting.",
		/obj/item/trophy/slumbering_toxin = "The nascent poison of a slumbering mosquito. Regular bees can substitute for splicing.",
		/obj/item/trophy/ivynaut_fibre = "The fibre of an ivynaut. You will need a blobbernaut for this transposition.",
		/obj/item/trophy/inversion_board = "The inversion board of a negative cow. A simple bovine will suffice for splicing."
	)
	var/current_reroll = FALSE //is the bounty currently being rerolled

/mob/living/simple_animal/formic/scarlet_ferryman/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "i will hunt for you") //starting dialogue
		last_response = "i will hunt for you"
		echoes -= "what is my task"
		echoes -= "i will hunt for you"
		echoes += "give me a bounty"
		balloon_alert(last_speaker, "new echoes detected!")
		langsay("Very well. Retrieve the weapon. Lacebark. Dule.")
		new /obj/item/gun/energy/plasmacutter/splicer(get_turf(last_speaker))
	if(successful_echo == "what is my task") //starting dialogue
		last_response = "what is my task"
		echoes -= "what is my task"
		echoes -= "i will hunt for you"
		echoes += "give me a bounty"
		balloon_alert(last_speaker, "new echoes detected!")
		langsay("Look down. Grab the weapon. I will ask trophies of you, you will retrieve them. Gerling. Lacebark.")
		new /obj/item/gun/energy/plasmacutter/splicer(get_turf(last_speaker))
	if(successful_echo == "give me a bounty") //get first bounty
		last_response = "give me a bounty"
		get_bounty()
		echoes -= "give me a bounty"
		echoes += "repeat your request"
		echoes += "what is my compensation"
		echoes += "i want a different bounty"
		echoes += "i have your trophy"
		balloon_alert(last_speaker, "new echoes detected!")
	if(successful_echo == "repeat your request") //repeat. really just for convenience
		last_response = "repeat your request"
		langsay(trophies[current_bounty])
	if(successful_echo == "what is my compensation") //check the value of the bounty
		last_response = "what is my compensation"
		langsay("Hmm... [current_bounty.value] of my finest.")
	if(successful_echo == "i want a different bounty") //check the value of the bounty
		last_response = "i want a different bounty"
		if(current_reroll) //to make sure multiple requests cant be spammed
			langsay("Banyan. Pine.")
			return
		langsay("You frustrate me. Very well. Namboca. Banyan.")
		current_reroll = TRUE
		addtimer(CALLBACK(src, PROC_REF(get_bounty)), 10)
		if(!last_speaker.GetComponent(/datum/component/omen))
			last_speaker.AddComponent( \
			/datum/component/omen, \
			incidents_left = 3, \
			luck_mod = 0.3, \
			damage_mod = 0.25, \
			bless_fixable = TRUE, \
			)
			to_chat(last_speaker, span_warning("Charon's curse lurks..."))
	if(successful_echo == "i have your trophy") //check the value of the bounty
		last_response = "i have your trophy"
		if(get_dist(src, last_speaker) > 1) //has to be adjacent
			langsay("Come closer.")
			return
		if(!last_speaker.get_active_held_item()) //edge case if the player isnt holding anything
			langsay("Where?")
			return
		var/obj/item/I = last_speaker.get_active_held_item()
		if(I.type == current_bounty) //is it the right type? if so, pay out
			for(var/i in 1 to current_bounty.value)
				var/obj/item/stack/sheet/mineral/diamond/D = new /obj/item/stack/sheet/mineral/diamond(get_turf(last_speaker))
				D.name = "white-blooded diamond"
				D.desc = "What seems to be a blood-like substance flows within this diamond's... veins?"
			qdel(I)
			langsay("Very good. You will find your payment beneath you. Next...")
			current_reroll = TRUE
			addtimer(CALLBACK(src, PROC_REF(get_bounty)), 10)
		else
			langsay("This is wrong. Bring me a [current_bounty.name].")

/mob/living/simple_animal/formic/scarlet_ferryman/proc/get_bounty()
	current_bounty = pick(trophies)
	langsay(trophies[current_bounty])
	current_reroll = FALSE

/obj/item/gun/energy/plasmacutter/splicer
	name = "dimensional splicer"
	desc = "A specialized plasma cutter which concentrates its energy into realigning the target's dimensional axis, transforming them into something similar from somewhere else. The dimensional computer is only calibrated for certain creatures, and the weapon must be refilled with plasma after use."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry.dmi'
	icon_state = "splicer"
	lefthand_file = 'modular_oculis/modules/contact_science/icons/splicer_lefthand.dmi'
	righthand_file = 'modular_oculis/modules/contact_science/icons/splicer_righthand.dmi'
	inhand_icon_state = "splicer"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/splicer)
	var/upgraded = FALSE

/obj/item/gun/energy/plasmacutter/splicer/item_interaction(mob/living/user, obj/item/tool, list/modifiers) //copied from plasmacutter in order to change the charge amount per plas
	var/charge_multiplier = 0
	if(istype(tool, /obj/item/stack/sheet/mineral/plasma))
		charge_multiplier = 2
	else if(istype(tool, /obj/item/stack/ore/plasma))
		charge_multiplier = 1

	if(!charge_multiplier)
		return NONE

	if(cell.charge == cell.maxcharge)
		balloon_alert(user, "already fully charged!")
		return ITEM_INTERACT_BLOCKING

	var/obj/item/stack/sheet = tool
	if (!sheet.use(1))
		return ITEM_INTERACT_BLOCKING

	cell.give(250 JOULES * charge_multiplier)
	balloon_alert(user, "cell recharged")
	return ITEM_INTERACT_SUCCESS

/obj/item/ammo_casing/energy/plasma/splicer
	e_cost = LASER_SHOTS(2, STANDARD_CELL_CHARGE)
	projectile_type = /obj/projectile/plasma/splicer

/obj/projectile/plasma/splicer
	name = "splicing blast"

	var/list/creature_conversions = list(
		/mob/living/basic/spider = /mob/living/basic/spider/dunespider, //turns spiders into dunespiders
		/mob/living/simple_animal/hostile/ooze/grapes = /mob/living/simple_animal/hostile/ooze/grapes/jolt, //turns grapes into joltgrapes
		/mob/living/simple_animal/hostile/ooze/gelatinous = /mob/living/simple_animal/hostile/ooze/gelatinous/blood, //turns gelcubes into bloodcubes
		/mob/living/basic/turtle = /mob/living/basic/turtle/catacomb, //turns turtles into catacomb turtles
		/mob/living/basic/mining/lobstrosity = /mob/living/basic/mining/lobstrosity/golden, //turns lobstrosities to golden lobs
		/mob/living/basic/mold/electric_mosquito = /mob/living/basic/mold/electric_mosquito/slumbering, //elec mosquito to slumber mosquito
		/mob/living/basic/bee = /mob/living/basic/mold/electric_mosquito/slumbering, //bee to slumber mosquito
		/mob/living/basic/blob_minion/blobbernaut = /mob/living/basic/blob_minion/blobbernaut/ivy, //blobbernaut to ivynaut
		/mob/living/basic/migo = /mob/living/basic/migo/hatsune, //secret. hatsune migo transmutation
		/mob/living/basic/cow = /mob/living/basic/cow/negative //cow to neg. cow
	)

/obj/projectile/plasma/splicer/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!blocked && !pierce_hit)
		for(var/cc in creature_conversions)
			if(istype(target, cc))
				var/mob/living/tfk = target
				if(tfk.ckey) //i dont want this to be a means by which sentient animals can be instagibbed. no fun for anyone
					return
				var/conversion_creature = creature_conversions[cc]
				new conversion_creature(get_turf(target))
				tfk.gib(DROP_ORGANS) //gib the old target and make the New Creachure
				return

/mob/living/basic/spider/dunespider //dunespider. passively molts sand, and sometimes plasma ore. you could farm them, potentially
	name = "dunespider"
	desc = "A giant sandy spider. As it molts, you can see bits of plasma embedded into its skin."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry.dmi'
	icon_state = "dunespider"
	icon_living = "dunespider"
	icon_dead = "dunespider_dead"
	gold_core_spawnable = NO_SPAWN

	var/molt_chance = 0 //chance increases every tick, resets when molting
	var/chance_increase_coefficient = 0.5 //amount that the chance increases
	var/molt_count = 5 //number of sand made when molting
	var/plas_chance = 40 //chance to create plasma ore when molting
	var/plas_count = 5 //number of plasma ore made when plasma-molting

/mob/living/basic/spider/dunespider/Initialize()
	. = ..()
	butcher_results += /obj/item/trophy/dunespider_tongue

/mob/living/basic/spider/dunespider/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(prob(molt_chance) && stat != DEAD)
		molt_chance = 0
		visible_message(span_notice("[src] molts!"))
		var/obj/item/stack/ore/glass/molted = new /obj/item/stack/ore/glass(get_turf(src))
		molted.amount = molt_count
		if(prob(plas_chance))
			var/obj/item/stack/ore/plasma/plasmolted = new /obj/item/stack/ore/plasma(get_turf(src))
			plasmolted.amount = plas_count
	else
		molt_chance += seconds_per_tick * chance_increase_coefficient

/mob/living/simple_animal/hostile/ooze/grapes/jolt //sholean grapes, but sometimes they emit harvestable electricity. you could make a farm of zappy goopies
	name = "jolt grapes"
	desc = "Some sort of mutation of the Sholean Grapes, their slimy, cerulean composition sometimes crackling with electricity. That energy might be harnessable with some cable laid beneath them."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry.dmi'
	icon_state = "jolt_grapes"
	icon_living = "jolt_grapes"
	icon_dead = "jolt_grapes_dead"
	butcher_results = list(/obj/item/trophy/jolt_capacitor) //this is how it's done for mobs that don't otherwise have butcher results, rather than putting it in an initialize

	var/elec_chance = 0 //chance per tick to crackle, giving electricity to cables in a specified range
	var/chance_increase_coefficient = 0.5
	var/elec_power = 3e4 //amount of power added per cable
	var/elec_range = 1 //range of electricity

/mob/living/simple_animal/hostile/ooze/grapes/jolt/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(prob(elec_chance) && stat != DEAD)
		elec_chance = 0
		visible_message(span_warning("[src] crackle!"))
		for(var/obj/structure/cable/C in range(elec_range, get_turf(src)))
			C.powernet.avail += elec_power
	else
		elec_chance += seconds_per_tick * chance_increase_coefficient

/mob/living/simple_animal/hostile/ooze/gelatinous/blood //simple enemy, decent value on the trophy but not much more. some of these are just going to simply be encounters
	name = "blood cube"
	desc = "A gelatinous cube saturated with blood. Gross."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry.dmi'
	icon_state = "blood_cube"
	icon_living = "blood_cube"
	icon_dead = "blood_cube_dead"
	damage_coeff = list(BRUTE = 0.6, BURN = 1, TOX = 0.5, STAMINA = 0, OXY = 1) //a fun little switchup on resistances
	butcher_results = list(/obj/item/trophy/blood_skull)

/mob/living/simple_animal/hostile/ooze/gelatinous/blood/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	spray_blood(get_dir(get_turf(src), get_turf(user)), 10) //spew blood at attackers

/mob/living/basic/turtle/catacomb //gives formaldehyde to nearby player mobs. a nice pet for medical :)
	name = "catacomb turtle"
	desc = "A flora turtle of odd coloration. You feel... preserved?"
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry.dmi'
	icon_state = "catacomb_turtle"
	icon_living = "catacomb_turtle"
	icon_dead = "catacomb_turtle_dead"
	base_icon_state = "catacomb_turtle"
	var/datum/reagent/reagent_to_give = /datum/reagent/toxin/formaldehyde

/mob/living/basic/turtle/catacomb/Initialize()
	. = ..()
	butcher_results += /obj/item/trophy/catacomb_signet
	desc = "A flora turtle of odd coloration. You feel... preserved?" //override randomized description of the turtle

/mob/living/basic/turtle/catacomb/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(stat == DEAD)
		return
	for(var/mob/living/carbon/human/H in range(5, get_turf(src)))
		if(!H.reagents?.has_reagent(reagent_to_give)) //if the body doesn't have forma, add some
			H.reagents?.add_reagent(reagent_to_give, 1)

/mob/living/basic/mining/lobstrosity/golden //lobstrosity made o' gold. in addition to its trophy, it has gold in it
	name = "golden lobstrosity"
	desc = "This crustacean has a shiny, golden sheen to it. You stop to wonder if there's more inside."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry.dmi'
	icon_state = "golden_lobstrosity"
	icon_living = "golden_lobstrosity"
	icon_dead = "golden_lobstrosity_dead"
	maxHealth = 250 //higher health. bit of a tough bastard
	health = 250

/mob/living/basic/mining/lobstrosity/golden/Initialize()
	. = ..()
	butcher_results += /obj/item/trophy/golden_claw
	butcher_results += /obj/item/stack/ore/gold

/mob/living/basic/mining/lobstrosity/golden/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.reagents?.add_reagent(/datum/reagent/gold, 2) //yummy gold!

/mob/living/basic/mold/electric_mosquito/slumbering
	name = "slumbering mosquito"
	desc = "An oversized mosquito which hasnt seemed to fully develop its toxin yet. Who knows what's in there."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry.dmi'
	icon_state = "slumber_mosquito"
	icon_living = "slumber_mosquito"
	icon_dead = "slumber_mosquito_dead"
	butcher_results = list(/obj/item/trophy/slumbering_toxin)
	var/list/datum/reagent/potential_toxins = list( //possible toxins it can have. really just assorted bullshit
		/datum/reagent/toxin/plasma, //anything can be plasma in nanotrasen world
		/datum/reagent/blood, //reverse mosquito!
		/datum/reagent/toxin/chloralhydrate, //lives to the name
		/datum/reagent/mercury, //it can make you immortal
		/datum/reagent/medicine/c2/libital, //healing mosquito!
		/datum/reagent/drug/saturnx, //it can make you invisible! kind of
		/datum/reagent/consumable/condensedcapsaicin, //is it hot in here?
		/datum/reagent/napalm, //i hope it doesn't get hot in here
		/datum/reagent/consumable/superlaughter, //hehe!
		/datum/reagent/ants //ANTS
	)

/mob/living/basic/mold/electric_mosquito/slumbering/Initialize()
	. = ..()
	inject_reagent = pick(potential_toxins)
	RemoveElement(/datum/element/venomous, 0)
	AddElement(/datum/element/venomous, inject_reagent, inject_amount) //replace the previous venomous element with one of our chosen chem

/mob/living/basic/blob_minion/blobbernaut/ivy //ivynaut, blobbernaut which passively produces seeds
	name = "ivynaut"
	desc = "A hulking monster comprised of spore-like plant life. Not to be confused with a blobbernaut, despite their near-identical composition. Seeds occasionally fall out of its shell."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry.dmi'
	icon_state = "ivynaut"
	icon_living = "ivynaut"
	icon_dead = "ivynaut_dead"
	base_icon_state = "ivynaut"
	butcher_results = list(/obj/item/trophy/ivynaut_fibre)

	var/seed_chance = 0
	var/chance_increase_coefficient = 0.25
	var/seed_min = 1
	var/seed_max = 3
	var/obj/item/seeds/seed_list = list()

/mob/living/basic/blob_minion/blobbernaut/ivy/Initialize()
	. = ..()
	seed_list = subtypesof(/obj/item/seeds) //ANY seeds.

/mob/living/basic/blob_minion/blobbernaut/ivy/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(prob(seed_chance) && stat != DEAD)
		seed_chance = 0
		for(var/i in seed_min to rand(seed_min, seed_max))
			var/obj/item/seeds/seeds_to_drop = pick(seed_list)
			new seeds_to_drop(get_turf(src))
		visible_message(span_warning("Seeds fall out of [src]!"))
	else
		seed_chance += seconds_per_tick * chance_increase_coefficient

/mob/living/basic/cow/negative //cow that produces dark matter and sucks nearby mobs in sometimes
	name = "negative cow"
	desc = "Your eyes simply can't adapt to this strange bovine."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry.dmi'
	icon_state = "negative_cow"
	icon_living = "negative_cow"
	icon_dead = "negative_cow_dead"
	base_icon_state = "negative_cow"
	milked_reagent = /datum/reagent/liquid_dark_matter

	var/vortex_chance = 0
	var/chance_increase_coefficient = 0.25
	var/vortex_range = 4

/mob/living/basic/cow/negative/Initialize()
	. = ..()
	butcher_results += /obj/item/trophy/inversion_board

/mob/living/basic/cow/negative/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(prob(vortex_chance) && stat != DEAD)
		vortex_chance = 0
		goonchem_vortex(get_turf(src), 0, vortex_range)
		visible_message(span_warning("[src] releases a gravitational pulse!"))
	else
		vortex_chance += seconds_per_tick * chance_increase_coefficient

/obj/item/trophy
	name = "scarlet trophy"
	desc = "You shouldn't be seeing this, scientist."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry_trophies.dmi'
	icon_state = "dunespider_tongue"
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 4
	throw_range = 5
	var/value = 0 //how much the ferryman pays for the trophy

/obj/item/trophy/dunespider_tongue
	name = "dunespider tongue"
	desc = "A small, forked, plasma-diluted tongue. It's still wriggling a bit."
	value = 2
	custom_materials = list(/datum/material/plasma=SMALL_MATERIAL_AMOUNT * 0.5)

/obj/item/trophy/jolt_capacitor
	name = "jolt capacitor"
	desc = "A rough chunk of metal once crackling with electricity, though it's dormant now. You could upgrade a dimensional splicer with it."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry_trophies.dmi'
	icon_state = "jolt_capacitor"
	value = 4
	custom_materials = list(/datum/material/titanium=SMALL_MATERIAL_AMOUNT * 0.5)

/obj/item/trophy/jolt_capacitor/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/item/gun/energy/plasmacutter/splicer))
		var/obj/item/gun/energy/plasmacutter/splicer/to_upgrade = interacting_with
		if(!to_upgrade.upgraded) //if it's not already upgraded, apply it
			to_upgrade.upgraded = TRUE
			playsound(user, 'sound/items/deconstruct.ogg', 30, TRUE)
			to_upgrade.can_charge = TRUE
			balloon_alert(user, "charger compatibility upgrade installed!")
			qdel(src)
		else
			balloon_alert(user, "already upgraded!")

/obj/item/trophy/blood_skull
	name = "blood-saturated skull"
	desc = "This skull's very marrow is infused with visceral fluid. Gross."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry_trophies.dmi'
	icon_state = "blood_saturated_skull"
	value = 3
	custom_materials = list(/datum/material/bone=SMALL_MATERIAL_AMOUNT * 0.5)

/obj/item/trophy/catacomb_signet
	name = "catacomb signet"
	desc = "A stone signet with a small gemstone. It glows ever-so-faintly."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry_trophies.dmi'
	icon_state = "catacomb_symbol"
	value = 2
	custom_materials = list(/datum/material/stone=SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/diamond=SMALL_MATERIAL_AMOUNT * 0.5)

/obj/item/trophy/golden_claw
	name = "golden claw"
	desc = "The shining, golden claw of an equally golden lobstrosity. It could make for a sharp weapon."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry_trophies.dmi'
	icon_state = "golden_claw"
	value = 3
	custom_materials = list(/datum/material/bone=SMALL_MATERIAL_AMOUNT, /datum/material/gold=SMALL_MATERIAL_AMOUNT * 0.5)

	//can be used as a crude melee weapon
	force = 12
	throwforce = 6
	attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED
	armour_penetration = 15

/obj/item/trophy/slumbering_toxin
	name = "nascent toxin"
	desc = "A strange liquid, not yet to reach its proper form. Perhaps it never will. Your subconscious recommends against drinking it."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry_trophies.dmi'
	icon_state = "slumbering_toxin"
	value = 3
	custom_materials = list(/datum/material/bone=SMALL_MATERIAL_AMOUNT * 0.5)

	var/list/datum/reagent/potential_toxins = list( //copied from the mosquito
		/datum/reagent/toxin/plasma, //anything can be plasma in nanotrasen world
		/datum/reagent/blood, //reverse mosquito!
		/datum/reagent/toxin/chloralhydrate, //lives to the name
		/datum/reagent/mercury, //it can make you immortal
		/datum/reagent/medicine/c2/libital, //healing mosquito!
		/datum/reagent/drug/saturnx, //it can make you invisible! kind of
		/datum/reagent/consumable/condensedcapsaicin, //is it hot in here?
		/datum/reagent/napalm, //i hope it doesn't get hot in here
		/datum/reagent/consumable/superlaughter, //hehe!
		/datum/reagent/ants //ANTS
	)

/obj/item/trophy/slumbering_toxin/attack_self(mob/user) //drink up!
	if(isliving(user) && do_after(user, 1 SECONDS, src))
		var/mob/living/living_user = user
		living_user.reagents?.add_reagent(pick(potential_toxins), 5)
		playsound(src, 'sound/effects/chemistry/bufferadd.ogg', 30, TRUE)
		to_chat(user, span_warning("You drink from the strange substance, and watch as it replenishes itself. You feel weird."))

/obj/item/trophy/ivynaut_fibre
	name = "ivynaut fibre"
	desc = "A thick, stretchy fibre. Its pores are visible and... breathing?"
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry_trophies.dmi'
	icon_state = "ivynaut_fibre"
	value = 3
	custom_materials = list(/datum/material/biomass=SMALL_MATERIAL_AMOUNT * 0.5)

/obj/item/trophy/inversion_board
	name = "inversion board"
	desc = "A strange machine board. This probably isn't compatible with your machinery."
	icon = 'modular_oculis/modules/contact_science/icons/scarlet_ferry_trophies.dmi'
	icon_state = "inversion_board"
	value = 2
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/plasma=SMALL_MATERIAL_AMOUNT * 0.5)

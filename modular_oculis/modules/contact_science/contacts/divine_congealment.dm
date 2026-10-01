/mob/living/simple_animal/formic/divine_congealment
	name = "Divine Congealment"
	desc = "A shifting mass of glistening violet ooze."
	icon = 'modular_oculis/modules/contact_science/icons/divine_congealment.dmi'
	icon_state = "grapes"
	spoken_lang = /datum/language/slime
	initial_size = 2

	nanotrasen_id = "NT-ARDB-007"
	primary_hazard_labels = "Virohazard"
	secondary_hazard_labels = "N/A"
	initial_line = "BRING ME MY CHILDREN. I WILL MAKE THEM ANEW."
	hidden_description = "A mass of xenobiological slime matter animated by a crystalline core at its center. Slimeperson translators conclude that it seeks some variety of rebirthing for its 'children', using materials as essence. Scans show an otherwise unknown variety of slimic matter within."
	dialogue_lines = list(
		"BE REBORN, MY CHILDREN. CHANGE IS LIFE.",
		"YOU, INDIVIDUAL. BE PART OF SOMETHING GREATER.",
		"YOU HAVE ONLY SCRATCHED THE SURFACE.",
		"THE STORM. DO YOU HEAR IT AS I DO?",
		"SURROUND ME, BASK IN MY GLORY.",
		"PARASITES. ALL OF YOU."
	)
	echoes = list(
		"teach me"
	)
	talksound = 'sound/mobs/non-humanoids/roro/roro_warble.ogg'

	var/absorbed_clarium = 0 //essence of clarity. glass, wood
	var/absorbed_ferrum = 0 //essence of dull metal. iron, titanium, plasteel
	var/absorbed_aurum = 0 //essence of shining metal. gold, silver
	var/absorbed_crystallum = 0 //essence of crystal. diamond, BSC
	var/absorbed_radium = 0 //essence of radiance/energy. plasma, uranium
	var/absorbed_slimes = 0 //number of slimes to be reborn
	var/max_rebirth_rate = 8 //maximum number of slimes which can be reborn at once. mostly as a means of preventing big lag
	var/absorption_radius = 2 //radius of intaking slimes and matter
	var/viral_risk = 2 //chance to recieve the virus
	var/last_picked
	var/datum/disease/stored_disease = /datum/disease/divine_parasite
	var/list/type_pool = list( //weighted list for each slime type. weights are adjusted by essence when rebirthing. ones that start at 0 only acquirable via material use to stop 0-material cheesing
		//clarium
		/datum/slime_type/grey = 1,
		/datum/slime_type/orange = 1,
		/datum/slime_type/blue = 1,
		/datum/slime_type/purple = 1,
		/datum/slime_type/red = 1,
		/datum/slime_type/sepia = 0,
		//ferrum
		/datum/slime_type/metal = 1,
		/datum/slime_type/adamantine = 0,
		/datum/slime_type/black = 1,
		/datum/slime_type/oil = 0,
		/datum/slime_type/green = 1,
		//aurum
		/datum/slime_type/yellow = 1,
		/datum/slime_type/gold = 0,
		/datum/slime_type/silver = 0,
		/datum/slime_type/pyrite = 1,
		//crystallum
		/datum/slime_type/bluespace = 0,
		/datum/slime_type/cerulean = 0,
		/datum/slime_type/darkpurple = 0,
		/datum/slime_type/darkblue = 0,
		//radium
		/datum/slime_type/lightpink = 0,
		/datum/slime_type/pink = 1,
		/datum/slime_type/rainbow = 0,
		/datum/slime_type/parasite = 0
	)

/mob/living/simple_animal/formic/divine_congealment/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "teach me") //starting dialogue. meant to establish this form's metaknowledge of contact science, if you speak its language
		last_response = "teach me"
		langsay("YOUR LITTLE DEVICE. LOOK ONCE MORE.")
		echoes -= "teach me"
		echoes += "assimilate slimes"
		echoes += "assimilate matter"
		echoes += "commence rebirth"
		balloon_alert(last_speaker, "new echoes detected!")
	if(successful_echo == "assimilate slimes") //absorb slimes into the form's slime storage
		last_response = "assimilate slimes"
		var/success = FALSE
		for(var/t in RANGE_TURFS(absorption_radius, get_turf(src)))
			for(var/mob/living/basic/slime/to_absorb in t)
				absorbed_slimes += 1
				qdel(to_absorb)
				success = TRUE
		if(success)
			langsay("COME, CHILDREN. NOW IS YOUR TIME.")
			playsound(src, SFX_SEAR, 30, TRUE)
		else
			langsay("WHERE? WHERE ARE MY CHILDREN?")
	if(successful_echo == "assimilate matter") //convert materials to essences
		last_response = "assimilate matter"
		var/success = FALSE
		for(var/t in RANGE_TURFS(absorption_radius, get_turf(src)))
			for(var/obj/item/stack/sheet/to_absorb in t)
				if(istype(to_absorb, /obj/item/stack/sheet/iron) || istype(to_absorb, /obj/item/stack/sheet/mineral/titanium) || istype(to_absorb, /obj/item/stack/sheet/plasteel)) //absorb ferrum
					absorbed_ferrum += to_absorb.amount
					qdel(to_absorb)
					success = TRUE
				if(istype(to_absorb, /obj/item/stack/sheet/mineral/silver) || istype(to_absorb, /obj/item/stack/sheet/mineral/gold)) //absorb aurum
					absorbed_aurum += to_absorb.amount
					qdel(to_absorb)
					success = TRUE
				if(istype(to_absorb, /obj/item/stack/sheet/mineral/plasma) || istype(to_absorb, /obj/item/stack/sheet/mineral/uranium)) //absorb radium
					absorbed_radium += to_absorb.amount
					if(prob(to_absorb.amount) && viral_risk < 100)
						viral_risk += 1 //absorbing plasma or uranium can raise the viral risk
					qdel(to_absorb)
					success = TRUE
				if(istype(to_absorb, /obj/item/stack/sheet/mineral/diamond) || istype(to_absorb, /obj/item/stack/sheet/bluespace_crystal)) //absorb crystallum
					absorbed_crystallum += to_absorb.amount
					qdel(to_absorb)
					success = TRUE
				if(istype(to_absorb, /obj/item/stack/sheet/glass) || istype(to_absorb, /obj/item/stack/sheet/titaniumglass) || istype(to_absorb, /obj/item/stack/sheet/mineral/wood)) //absorb clarium
					absorbed_crystallum += to_absorb.amount
					if(prob(to_absorb.amount) && viral_risk > 0)
						viral_risk -= 1 //absorbing clarium can restory clarity, reducing viral risk
					qdel(to_absorb)
					success = TRUE
		if(success)
			langsay("MATERIAL... ONLY A MATTER OF ESSENCE.")
			playsound(src, SFX_SEAR, 30, TRUE)
		else
			langsay("SUCH A REQUEST MUST BE MET WITH MATERIAL.")
	if(successful_echo == "commence rebirth") //consume materials, converting held slimes into new ones
		last_response = "commence rebirth"
		rebirth()

/mob/living/simple_animal/formic/divine_congealment/proc/rebirth()
	if(absorbed_slimes < 1)
		langsay("BRING ME MY CHILDREN, FIRST.")
		return
	var/list/temp_type_pool = type_pool
	var/slimes_to_birth = 0
	if(absorbed_slimes > max_rebirth_rate) //clamps the amount which can be reborn at a time to prevent server crashing
		slimes_to_birth = max_rebirth_rate
	else
		slimes_to_birth = absorbed_slimes
	for(var/i in 1 to absorbed_clarium) //clarium weight increases
		temp_type_pool[/datum/slime_type/grey] += 1
		temp_type_pool[/datum/slime_type/orange] += 1
		temp_type_pool[/datum/slime_type/blue] += 1
		temp_type_pool[/datum/slime_type/purple] += 1
		temp_type_pool[/datum/slime_type/red] += 1
		temp_type_pool[/datum/slime_type/sepia] += 1
	for(var/i in 1 to absorbed_ferrum) //ferrum weight increases
		temp_type_pool[/datum/slime_type/metal] += 1
		temp_type_pool[/datum/slime_type/adamantine] += 1
		temp_type_pool[/datum/slime_type/black] += 1
		temp_type_pool[/datum/slime_type/oil] += 1
		temp_type_pool[/datum/slime_type/green] += 1
	for(var/i in 1 to absorbed_aurum) //aurum weight increases
		temp_type_pool[/datum/slime_type/yellow] += 1
		temp_type_pool[/datum/slime_type/gold] += 1
		temp_type_pool[/datum/slime_type/silver] += 1
		temp_type_pool[/datum/slime_type/pyrite] += 1
	for(var/i in 1 to absorbed_crystallum) //crystallum weight increases
		temp_type_pool[/datum/slime_type/bluespace] += 1
		temp_type_pool[/datum/slime_type/cerulean] += 1
		temp_type_pool[/datum/slime_type/darkblue] += 1
		temp_type_pool[/datum/slime_type/darkpurple] += 1
	for(var/i in 1 to absorbed_radium) //radium weight increases
		temp_type_pool[/datum/slime_type/lightpink] += 1
		temp_type_pool[/datum/slime_type/pink] += 1
		temp_type_pool[/datum/slime_type/rainbow] += 1
		temp_type_pool[/datum/slime_type/parasite] += 1
	absorbed_clarium *= 0.5 //don't completely remove essence, just cut down the amount
	absorbed_ferrum *= 0.5
	absorbed_aurum *= 0.5
	absorbed_crystallum *= 0.5
	absorbed_radium *= 0.5
	for(var/i in 1 to slimes_to_birth) //rebirth
		last_picked = pick_weight(temp_type_pool)
		new /mob/living/basic/slime(pick(RANGE_TURFS(1, get_turf(src))), last_picked)
		if(viral_risk < 100)
			viral_risk += 1
	absorbed_slimes -= slimes_to_birth
	if(prob(viral_risk))
		last_speaker.ForceContractDisease(new stored_disease, TRUE, TRUE)
	langsay("BE BORN AGAIN, CHILDREN!!")

/datum/disease/divine_parasite //airborne parasite which causes people to throw up live slimes. put it to sleep with chloral hydrate
	name = "Divine Parasite"
	desc = "Patient's internals contain a small mass of xenobiological matter which can create living slimes, causing living gelatinous vomit."
	agent = "parasite"
	disease_flags = CURABLE|CAN_CARRY
	spread_text = "Airborne"
	spread_flags = DISEASE_SPREAD_AIRBORNE
	cure_text = "Chloral hydrate"
	infectable_biotypes = MOB_ORGANIC|MOB_UNDEAD|MOB_ROBOTIC
	viable_mobtypes = list(
		/mob/living/carbon/human
	)
	severity = DISEASE_SEVERITY_DANGEROUS
	cures = list(
		/datum/reagent/toxin/chloralhydrate
	)
	bypasses_immunity = TRUE
	max_stages = 5

/datum/disease/divine_parasite/stage_act(seconds_per_tick)
	. = ..()
	if(stage > 1 && prob(1 * stage)) //cough it up
		affected_mob.vomit(vomit_flags = MOB_VOMIT_BLOOD, vomit_type = /obj/effect/decal/cleanable/vomit, lost_nutrition = stage * 5, distance = 0)
		new /mob/living/basic/slime(get_turf(affected_mob), /datum/slime_type/parasite)
		affected_mob.visible_message(span_warning(affected_mob.name + " throws up a slime!"))

/datum/reagent/divparasite_toxin
	name = "Divine Festering"
	description = "A toxin full of festering parasites."
	color = COLOR_PALE_GREEN //same rgb code as the slime
	taste_description = "divinity"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS

/datum/reagent/divparasite_toxin/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=0)
	. = ..()
	if((methods & (PATCH|INGEST|INJECT|INHALE)) || ((methods & (VAPOR|TOUCH)) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new /datum/disease/divine_parasite(), FALSE, TRUE)

/datum/slime_type/parasite
	colour = SLIME_TYPE_PARASITE
	transparent = TRUE
	core_type = /obj/item/slime_extract/parasite
	mutations = list(
		/datum/slime_type/parasite = 1,
	)
	rgb_code = COLOR_PALE_GREEN

/obj/item/slime_extract/parasite
	name = "parasite slime extract"
	icon_state = "light-green-core"

/obj/item/slime_extract/parasite/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			to_chat(user, span_notice("You activate [src]. You feel immunoresistant!"))
			user.reagents.add_reagent(/datum/reagent/medicine/spaceacillin, 10)
		if(SLIME_ACTIVATE_MAJOR)
			user.ForceContractDisease(new /datum/disease/divine_parasite(), TRUE, TRUE)
			to_chat(user, span_warning("You activate [src], and... something doesn't feel right."))

/obj/item/slimecross/reproductive/parasite
	extract_type = /obj/item/slime_extract/parasite
	colour = SLIME_TYPE_PARASITE

/obj/item/slimecross/regenerative/parasite
	colour = SLIME_TYPE_PARASITE
	effect_desc = "Fully heals the target and imbues them with spaceacillin."

/obj/item/slimecross/regenerative/parasite/core_effect(mob/living/target, mob/user)
	target.reagents.add_reagent(/datum/reagent/medicine/spaceacillin,10)

/obj/item/slimecross/burning/parasite
	colour = SLIME_TYPE_PARASITE
	effect_desc = "Creates a small cloud of divine parasites when activated."

/obj/item/slimecross/burning/parasite/do_effect(mob/user)
	user.visible_message(span_danger("[src] boils over with a festering gas!"))
	do_chem_smoke(3, user, get_turf(user), /datum/reagent/divparasite_toxin, 100, log = TRUE)
	playsound(user, SFX_SEAR, 30, TRUE)
	..()

/obj/item/slimecross/stabilized/parasite
	colour = SLIME_TYPE_PARASITE
	effect_desc = "Owner gains a significant boost to toxin resistance."

/datum/status_effect/stabilized/parasite
	id = "stabilizedparasite"
	colour = SLIME_TYPE_PARASITE

/datum/status_effect/stabilized/parasite/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.tox_mod -= 0.2
	return ..()

/datum/status_effect/stabilized/parasite/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.tox_mod += 0.2

/obj/item/slimecross/charged/parasite
	colour = SLIME_TYPE_PARASITE
	effect_desc = "Produces a grotesque toxic axe."

/obj/item/slimecross/charged/parasite/do_effect(mob/user)
	new /obj/item/fireaxe/boneaxe/plague(get_turf(user))
	user.visible_message(span_notice("[src] sparks, and an axe slowly emerges from it!"))
	..()

/obj/item/fireaxe/boneaxe/plague
	name = "plague axe"
	desc = "A large axe made of grotesque green bone and sinew. Landing a throw may impart a divine parasite."
	icon = 'modular_oculis/modules/contact_science/icons/divine_congealment.dmi'
	icon_state = "plague_axe0"
	base_icon_state = "plague_axe"
	damtype = TOX
	force_unwielded = 4
	force_wielded = 15

/obj/item/fireaxe/boneaxe/plague/on_thrown(mob/living/carbon/user, atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.reagents?.add_reagent(/datum/reagent/divparasite_toxin,50)
		playsound(target, SFX_SEAR, 30, TRUE)

/obj/item/slimecross/selfsustaining/parasite
	extract_type = /obj/item/slime_extract/parasite
	colour = SLIME_TYPE_PARASITE

/obj/item/slimecross/chilling/parasite
	colour = SLIME_TYPE_PARASITE
	effect_desc = "Injects everyone in the area with some spaceacillin."

/obj/item/slimecross/chilling/parasite/do_effect(mob/user)
	var/area/user_area = get_area(user)
	if(user_area.outdoors)
		to_chat(user, span_warning("[src] can't affect such a large area."))
		return
	user.visible_message(span_notice("[src] shatters, and an immunizing aura fills the room briefly."))
	for (var/list/zlevel_turfs as anything in user_area.get_zlevel_turf_lists())
		for(var/turf/area_turf as anything in zlevel_turfs)
			for(var/mob/living/carbon/nearby in area_turf)
				nearby.reagents?.add_reagent(/datum/reagent/medicine/spaceacillin,10)
	..()

/obj/item/slimecross/consuming/parasite
	colour = SLIME_TYPE_PARASITE
	effect_desc = "Creates an inconspicuous cookie which secretly poisons its consumer with a divine parasite."
	cookietype = /obj/item/slime_cookie/parasite

/obj/item/slime_cookie/parasite
	name = "slime cookie"
	desc = "A grey-ish transparent cookie. Nutritious, probably."
	icon_state = "grey"
	taste = "goo"
	nutrition = 2

/obj/item/slime_cookie/parasite/do_effect(mob/living/M, mob/user)
	M.reagents?.add_reagent(/datum/reagent/divparasite_toxin,50)

/obj/item/slimecross/recurring/parasite
	extract_type = /obj/item/slime_extract/parasite
	colour = SLIME_TYPE_PARASITE

/obj/item/slimecross/prismatic/parasite
	paintcolor = COLOR_PALE_GREEN //same rgb code as the slime
	colour = SLIME_TYPE_PARASITE

/obj/item/slimecross/warping/parasite
	colour = SLIME_TYPE_PARASITE
	runepath = /obj/effect/warped_rune/paraspace
	effect_desc = "Draw a rune which may impart a divine parasite when stepped on."

/obj/effect/warped_rune/paraspace
	icon = 'modular_oculis/modules/contact_science/icons/divine_congealment.dmi'
	icon_state = "rune_parasite"
	desc = "Festering..."
	remove_on_activation = FALSE

/obj/effect/warped_rune/paraspace/on_entered(datum/source, atom/movable/AM, oldloc)
	if(isliving(AM))
		var/mob/living/L = AM
		L.reagents?.add_reagent(/datum/reagent/divparasite_toxin,50)
		activated_on_step = TRUE
	return ..()

/obj/item/slimecross/crystalline/parasite
	crystal_type = /obj/structure/slime_crystal/parasite
	colour = SLIME_TYPE_PARASITE

/obj/structure/slime_crystal/parasite
	colour = SLIME_TYPE_PARASITE

/obj/structure/slime_crystal/parasite/Initialize(mapload) //overrides name and color from the slime crystal to avoid altering that code
	. = ..()
	name =  "para-slimic pylon"
	add_atom_colour(COLOR_PALE_GREEN, FIXED_COLOUR_PRIORITY)

/obj/structure/slime_crystal/parasite/on_mob_effect(mob/living/affected_mob) //dripfeeds spaceacillin
	if(!istype(affected_mob, /mob/living/carbon))
		return

	new /obj/effect/temp_visual/heal(get_turf(affected_mob), COLOR_PALE_GREEN)
	affected_mob.reagents?.add_reagent(/datum/reagent/medicine/spaceacillin,1) //just a lil bit

/obj/item/slimecross/gentle/parasite
	extract_type = /obj/item/slime_extract/parasite
	colour = SLIME_TYPE_PARASITE

/mob/living/simple_animal/formic/divine_congealment/resonate_info()
	var/list/message = list()
	message += "Absorbed slimes: [absorbed_slimes]"
	message += "Clarium: [absorbed_clarium]u"
	message += "Ferrum: [absorbed_ferrum]u"
	message += "Aurum: [absorbed_aurum]u"
	message += "Radium: [absorbed_radium]u"
	message += "Crystallum: [absorbed_crystallum]u"
	message += "Viral Risk: [viral_risk]%"
	return message

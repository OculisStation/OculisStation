/mob/living/simple_animal/formic/mirror_in_multitudes
	name = "Mirror in Multitudes"
	desc = "A glowing, mirror-like crystal. It reminds you of the Supermatter, and its voice sounds like a radio broadcast."
	icon = 'modular_oculis/modules/contact_science/icons/mirror_of_multitudes.dmi'
	icon_state = "shard"

	nanotrasen_id = "NT-ARDB-011"
	primary_hazard_labels = "Sanguihazard"
	secondary_hazard_labels = "Non-hostile manifestation"
	initial_line = "{-Are you afraid?-}"
	hidden_description = "A series of crystals akin in material composition to the Supermatter, though it is notably safe to touch and has no hallucinogenic effect. It is placed on a simple iron pedestal which is somehow inseparable from it. Its verbal expressions seem to come from radio broadcasts, though some scientists believe there may be a throughline or communication not yet understood."

	dialogue_lines = list(
		"{2.718281828459045235360287471352}",
		"{3.141592653589793238462643383279}",
		"{1.414213562373095048801688724209}",
		"{1.732050807568877293527446341505}",
		"{2.23606797749978969640917366873}",
		"{-Light's speed is limited. When a star dies, its death is not immediately seen. It is as if its image is imprinted for a time, unchanging from such a distance-}",
		"{2.6651441426902251886502972498731}",
		"{0.596347362323194074341078499369}"
	)
	echoes = list(
		"do you want to play"
	)
	talksound = 'sound/items/radio/radio_receive.ogg'

	var/games_num = 3
	var/games_played = 0
	var/base_mirrors = 1
	var/mirrors_per_game = 1 //multiplied by game #. the more games, the more mirrors
	var/mirrors_left = 0
	var/game_active = FALSE
	var/game_cost = 5
	var/hint_cost = 20
	var/list/obj/item/multitudemirror/active_mirrors = list()

/mob/living/simple_animal/formic/mirror_in_multitudes/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "do you want to play") //starting dialogue
		last_response = "do you want to play"
		langsay("{-What game?-}")
		echoes -= "do you want to play"
		echoes += "hide and seek"
		balloon_alert(last_speaker, "new echoes detected!")
	if(successful_echo == "hide and seek") //game initiation dialogue
		last_response = "hide and seek"
		langsay("{-Great! I'll hide!-}")
		echoes -= "hide and seek"
		addtimer(CALLBACK(src, PROC_REF(initiate_game)), 5)
	if(successful_echo == "i want to play again") //game initiation dialogue
		last_response = "i want to play again"
		langsay("{-The vulture stalks the potential carrion. Even though the prey is alive, the vulture anticipates its death.-}")
		echoes -= "i want to play again"
		addtimer(CALLBACK(src, PROC_REF(initiate_game)), 5)
	if(successful_echo == "give me a hint") //spend blood to get a single signal faxed
		last_response = "give me a hint"
		last_speaker.adjust_blood_volume(hint_cost, maximum = BLOOD_VOLUME_NORMAL)
		last_speaker.add_splatter_floor(get_turf(last_speaker), FALSE)
		for(var/obj/item/multitudemirror/hinting_mirror in active_mirrors)
			last_speaker.create_splatter(get_dir(get_turf(last_speaker), get_turf(hinting_mirror)))
			last_speaker.spray_blood(get_dir(get_turf(last_speaker), get_turf(hinting_mirror)), 10)
			hinting_mirror.hint_effect()
		to_chat(last_speaker, span_warning("Jets of blood spray in multiple directions from your body. Shortcuts have their own tolls."))
		var/obj/item/multitudemirror/coord_hint_mirror = pick(active_mirrors)
		langsay("{-[coord_hint_mirror.x], [coord_hint_mirror.y], [coord_hint_mirror.z]-}")
	if(successful_echo == "what do i do") //extra hint as to the objective
		if(last_response == "what do i do")
			langsay("{-Help me! Please!-}")
			return
		last_response = "what do i do"
		langsay("{-Find my children, please! I beg of you!-}")
	if(successful_echo == "i want it to be over") //final interaction
		last_response = "i want it to be over"
		langsay("{-And even though they are afraid, they continue anyways, because the only thing worse is to give up.-}")
		addtimer(CALLBACK(src, PROC_REF(reward)), 10)

/mob/living/simple_animal/formic/mirror_in_multitudes/proc/reward()
	do_sparks(3, TRUE, get_turf(src))
	new /obj/item/mockerymirror(get_turf(src))
	playsound(src, 'sound/effects/magic/staff_healing.ogg', 50, TRUE, -2, TRUE, FALSE)
	qdel(src)

/mob/living/simple_animal/formic/mirror_in_multitudes/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(game_active && mirrors_left < 1)
		complete_game()

/mob/living/simple_animal/formic/mirror_in_multitudes/resonate_info()
	var/list/message = list()
	message += "Mirrors left: [mirrors_left] mirrors"
	message += "Games left: [games_num - games_played] games"
	return message

/mob/living/simple_animal/formic/mirror_in_multitudes/proc/initiate_game()
	game_active = TRUE
	var/mirror_num = base_mirrors + mirrors_per_game * (games_played + 1)
	mirrors_left += mirror_num
	active_mirrors = list() //empty the list
	for(var/i in 1 to mirror_num)
		var/obj/item/multitudemirror/created_mirror = new /obj/item/multitudemirror(get_random_station_turf())
		created_mirror.origin_mirror = src
		created_mirror.code = rand(1, 100)
		created_mirror.set_frequency(sanitize_frequency(rand(MIN_FREE_FREQ, MAX_FREE_FREQ), free = TRUE))
		created_mirror.desc += " {[created_mirror.frequency], [created_mirror.code]}."
		active_mirrors += created_mirror
	for(var/obj/item/multitudemirror/m in active_mirrors)
		last_speaker.create_splatter(get_dir(get_turf(last_speaker), get_turf(m)))
		last_speaker.spray_blood(get_dir(get_turf(last_speaker), get_turf(m)), 10)
		do_sparks(3, TRUE, get_turf(m))
	to_chat(last_speaker, span_warning("Tiny jets of blood spray in multiple directions from your body. You feel the presence of the multitudes lurking in the station."))
	last_speaker.adjust_blood_volume(game_cost, maximum = BLOOD_VOLUME_NORMAL)
	echoes += "give me a hint"
	echoes += "what do i do"
	balloon_alert(last_speaker, "new echoes detected!")

/mob/living/simple_animal/formic/mirror_in_multitudes/proc/complete_game()
	game_active = FALSE
	games_played += 1
	echoes -= "give me a hint"
	echoes -= "what do i do"
	if(games_played < games_num)
		echoes += "i want to play again"
	else
		echoes += "i want it to be over"
	langsay("{-Yet so vain is man and so blinded by his vanity-}")
	balloon_alert(last_speaker, "new echoes detected!")

/obj/item/multitudemirror
	name = "odd mirror"
	desc = "This mirror looks normal, but you can't help but feel a bit exhausted around it. It whispers a signal to you..."
	icon = 'modular_nova/master_files/icons/obj/hhmirror.dmi'
	icon_state = "hhmirror"
	resistance_flags = INDESTRUCTIBLE
	w_class = WEIGHT_CLASS_SMALL

	var/code = DEFAULT_SIGNALER_CODE
	var/frequency = FREQ_SIGNALER
	var/datum/radio_frequency/radio_connection
	var/effect_radius = 2
	var/blood_drain = -5
	var/mob/living/simple_animal/formic/mirror_in_multitudes/origin_mirror
	var/hint_type
	var/has_signal = FALSE

/obj/item/multitudemirror/Initialize(mapload)
	. = ..()
	set_frequency(frequency)
	START_PROCESSING(SSprocessing, src)
	hint_type = rand(1, 4)
	hint_effect()

/obj/item/multitudemirror/proc/hint_effect() //hint effect depending on a randomized hint type value. meant to be inconsequential but disruptive enough to make an easy hint
	var/area/this_area = get_area(src)
	if(hint_type == 1 && !has_signal) //mockery of an exploration signal. the easiest to find
		AddComponent(/datum/component/gps, "Distant Signal")
		has_signal = TRUE
	if(hint_type == 2) //remove charge from the area's apc. spoooky
		this_area.apc.set_no_charge()
	if(hint_type == 3) //fuck with area's lights, probability-wise 25% of them
		var/list/obj/machinery/light/b_lights = this_area.apc.get_lights()
		for(var/obj/machinery/light/breakable in b_lights)
			if(prob(25))
				breakable.break_light_tube(FALSE)
	if(hint_type == 4) //haunt the mirror. has an unusual color and different flavor so it isnt confused too much with rev haunting
		AddComponent(/datum/component/haunted_item, \
			haunt_color = "#ffffff", \
			haunt_duration = rand(20, 40) SECONDS, \
			aggro_radius = rand(5), \
			spawn_message = span_warning("The mirror begins to hover, its form shifting and contorting..."), \
			despawn_message = span_warning("The mirror settles to the floor, returning to its normal shape."), \
		)

/obj/item/multitudemirror/process(seconds_per_tick)
	for(var/mob/living/M in range(effect_radius, src)) //the sanguihazard in question
		M.adjust_blood_volume(blood_drain * seconds_per_tick, maximum = BLOOD_VOLUME_NORMAL)
	if(!origin_mirror)
		do_sparks(3, TRUE, get_turf(src))
		qdel(src)

/obj/item/multitudemirror/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)
	return

/obj/item/multitudemirror/receive_signal(datum/signal/signal)
	if(!signal)
		return FALSE
	if(signal.data["code"] != code)
		return FALSE
	origin_mirror.mirrors_left -= 1
	do_sparks(3, TRUE, get_turf(src))
	playsound(src, 'sound/effects/magic/staff_healing.ogg', 50, TRUE, -2, TRUE, FALSE)
	qdel(src)
	return TRUE

/obj/item/mockerymirror
	name = "mockery mirror"
	desc = "A soft, shifting mirror. You feel like it could be anything else just as much as it can be this mirror if it peered into another object. Brave, or maybe just foolish."
	icon = 'modular_nova/master_files/icons/obj/hhmirror.dmi'
	icon_state = "hhmirror"
	resistance_flags = INDESTRUCTIBLE
	w_class = WEIGHT_CLASS_SMALL

	var/is_used = FALSE
	var/list/item_blacklist = list( //stuff that it cant copy
		/obj/item/book/granter/crafting_recipe/dusting/summoning_flute, //no duping the thing it feeds on
		/obj/item/disk/nuclear, //yeah, no. this would be stupid for nukies and such
		/obj/item/mockerymirror, //this would be hilarious but also no
		/obj/item/multitudemirror, //no to the hint mirrors either. this wouldnt be too big an issue but its not really fun either so
		/obj/item/holosynth_pen //holosynth pens have weird technical problems when it comes to there being multiple or ones with empty traits
	)

/obj/item/mockerymirror/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(istype(interacting_with, /obj/item) && !is_used)
		if(item_blacklist.Find(interacting_with.type))
			balloon_alert(user, "the mirror rejects the item...")
			return
		var/obj/item/I = interacting_with
		new I.type(get_turf(src))
		playsound(src, 'sound/effects/magic/staff_healing.ogg', 50, TRUE, -2, TRUE, FALSE)
		balloon_alert(user, "the mirror shines!")
		is_used = TRUE
		desc = "The mirror has hardened, and seems to refuse you. Perhaps its function can be restored with the reflection of a truly terrible book from the planet... why did your mind even wander there?"
		return
	if(istype(interacting_with, /obj/item/book/granter/crafting_recipe/dusting/summoning_flute) && is_used)
		is_used = FALSE
		desc = initial(desc)
		playsound(src, 'sound/effects/magic/staff_healing.ogg', 50, TRUE, -2, TRUE, FALSE)
		do_sparks(3, TRUE, get_turf(interacting_with))
		qdel(interacting_with)
		balloon_alert(user, "the mirror glistens!")

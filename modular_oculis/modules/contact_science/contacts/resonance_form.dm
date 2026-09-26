/mob/living/simple_animal/formic
	name = "anomalous resonance form"
	desc = "An anomalous contact, brought forth from the Storm."
	wander = 0
	density = 0
	mob_biotypes = MOB_SPECIAL

	var/nanotrasen_id = "NT-ARDB-000"
	var/primary_hazard_labels = "Cognitohazard"
	var/secondary_hazard_labels = "Conceptual alteration"
	var/initial_line = "Hello!"
	var/hidden_description = "ooOOoo"
	var/list/dialogue_lines = list(
		"Hello!",
		"Goodbye!"
	)
	var/list/echoes = list(
		"who are you"
	)
	var/dialogue_timer_current = 0
	var/dialogue_timer = 30
	var/interaction_cooldown_current = 0
	var/interaction_cooldown = 2
	var/dialogue_delay = 4
	var/list/active_links
	var/last_response = "None"
	var/mob/living/carbon/human/last_speaker
	var/awaiting_response
	var/rotation_target
	var/hearing_range = 9
	var/anchored_turf
	var/breaching = FALSE
	var/datum/language/spoken_lang = /datum/language/common

/mob/living/simple_animal/formic/Initialize(mapload)
	. = ..()
	langsay(initial_line)
	add_traits(list(TRAIT_GODMODE, TRAIT_IMMOBILIZED, TRAIT_AGENDER, TRAIT_NO_STAGGER), src)
	anchored_turf = get_turf(src)
	GLOB.global_resforms -= src
	if(GLOB.global_resforms.len < 1) //refill list
		GLOB.global_resforms = subtypesof(/mob/living/simple_animal/formic)

/mob/living/simple_animal/formic/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(interaction_cooldown_current > 0)
		interaction_cooldown_current -= seconds_per_tick
	if(dialogue_timer_current < dialogue_timer)
		dialogue_timer_current += seconds_per_tick
		if(dialogue_timer_current >= dialogue_timer)
			perform_dialogue()
	if(rotation_target)
		dir = get_cardinal_dir(src, rotation_target)
	if(get_turf(src) != anchored_turf)
		do_teleport(src, anchored_turf, 0, channel = TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)
		balloon_alert(src, "containment anchor engaged!")

/mob/living/simple_animal/formic/proc/perform_dialogue()
	dialogue_timer_current = 0
	if(interaction_cooldown_current > 0) //don't speak if there was recent interaction to prevent awkward dialogue spam
		return
	var/performed_dialogue = pick(dialogue_lines)
	langsay(performed_dialogue)

/mob/living/simple_animal/formic/proc/langsay(var/spoken) //easy way to make a mob speak in their lang variable. will be used for a translator in future(?)
	say(spoken, language = spoken_lang)

/mob/living/simple_animal/formic/proc/respond_to_command(mob/living/carbon/human/source, list/hearing_args)
	SIGNAL_HANDLER
	rotation_target = source
	var/haystack = hearing_args[SPEECH_MESSAGE]
	if(interaction_cooldown_current <= 0 && get_dist(src, source) <= hearing_range) //brief cooldown to ensure interactions are not spammed, and a hearing distance check
		interaction_cooldown_current = interaction_cooldown
		for(var/needle in echoes)
			if(findtext(haystack, needle)) //success
				dialogue_timer_current = 0 //resets dialogue timer to also prevent awkward dialogue spam
				awaiting_response = needle
				last_speaker = source
				addtimer(CALLBACK(src, PROC_REF(echo_success)), dialogue_delay, TIMER_UNIQUE | TIMER_DELETE_ME) //short delay to make dialogue seem more natural
				return

/mob/living/simple_animal/formic/proc/echo_success() //put interactions here
	var/successful_echo = awaiting_response
	if(successful_echo == "who are you")
		langsay("Insert response here.")
		last_response = "who are you"
	return

/mob/living/simple_animal/formic/proc/establish_link(mob/living/target)
	rotation_target = target
	if(!active_links) //if list is not made yet, make it. errors otherwise because list doesnt exist yet
		RegisterSignal(target, COMSIG_MOB_SAY, PROC_REF(respond_to_command))
		active_links = list(target)
		balloon_alert(target, "speech linked!")
		return
	if(!active_links.Find(target)) //if target is not already linked to this resonant form
		RegisterSignal(target, COMSIG_MOB_SAY, PROC_REF(respond_to_command))
		active_links += target
		balloon_alert(target, "speech linked!")
	else
		balloon_alert(target, "speech already linked!")

/mob/living/simple_animal/formic/proc/stop_everything() //function for stopping effects when cutting the connection
	return

/mob/living/simple_animal/formic/proc/resonate_info() //function for returning hidden info for the resonator. do not include in resforms with no specified info to share
	var/list/message = list()
	message += "No hidden data detected." //replace this with the actual info
	return message

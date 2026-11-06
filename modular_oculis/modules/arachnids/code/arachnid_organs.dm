/obj/item/organ/eyes/night_vision/arachnid
	name = "arachnid eyes"
	desc = "So many eyes!"
	icon = 'modular_oculis/modules/arachnids/icons/organs.dmi'
	eye_icon = 'modular_oculis/modules/arachnids/icons/bodyparts.dmi'
	eye_icon_state = "arachnideyes"
	icon_state = "arachnid_eyeballs"
	no_glasses = TRUE
	blink_animation = FALSE
	low_light_cutoff = list(20, 15, 0)
	medium_light_cutoff = list(35, 30, 0)
	high_light_cutoff = list(50, 40, 0)

/obj/item/organ/eyes/night_vision/arachnid/get_emissive_overlays(mutable_appearance/eye_left, mutable_appearance/eye_right, atom/spokesman)
	. = list()

	. += emissive_appearance(eye_left.icon, eye_left.icon_state, spokesman, -EYES_LAYER, alpha = eye_left.alpha, effect_type = EMISSIVE_NO_BLOOM)
	. += emissive_appearance(eye_right.icon, eye_right.icon_state, spokesman, -EYES_LAYER, alpha = eye_right.alpha, effect_type = EMISSIVE_NO_BLOOM)

/obj/item/organ/heart/arachnid
	name = "arachnid heart"

/obj/item/organ/liver/arachnid
	name = "arachnid liver"
	desc = "Smells faintly of copper."
	food_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue = 5, /datum/reagent/copper = 5)

/obj/item/organ/liver/arachnid/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick)
	. = ..()
	if((. & COMSIG_MOB_STOP_REAGENT_TICK) || (organ_flags & ORGAN_FAILING))
		return
	if(chem.type == /datum/reagent/toxin/pestkiller)
		organ_owner.take_damage(4 * seconds_per_tick, TOX)

/obj/item/organ/tongue/arachnid
	name = "arachnid tongue"
	desc = "The tongue of an Arachnid. Mostly used for lying."
	say_mod = "chitters"
	modifies_speech = TRUE
	disliked_foodtypes = FRUIT | VEGETABLES // Okay listen, i don't actually know what irl spiders don't like to eat and i'm pretty tired of looking for answers. <--- LOKA HERE, arachnids in my headcanon don't like vegetables so we'll do that
	liked_foodtypes = GORE | MEAT | BUGS | GROSS
	emote_sounds = list(
		/datum/emote/living/scream::key = 'modular_oculis/modules/arachnids/sounds/arachnid_scream.ogg',
		/datum/emote/living/laugh::key = 'modular_oculis/modules/arachnids/sounds/arachnid_laugh.ogg',
	)

/obj/item/organ/tongue/arachnid/modify_speech(datum/source, list/speech_args) //This is flypeople speech
	var/static/regex/fly_buzz = new("z+", "g")
	var/static/regex/fly_buZZ = new("Z+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
		message = replacetext(message, "s", "z")
		message = replacetext(message, "S", "Z")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/tongue/arachnid/get_possible_languages()
	return ..() + /datum/language/buzzwords

/obj/item/organ/arachnid_appendages
	name = "arachnid appendages"
	desc = "Extra limbs that go on your back, they don't actually work for walking sadly."
	icon = 'modular_oculis/modules/arachnids/icons/organs.dmi'
	icon_state = "arachnid_appendages"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	mutantpart_key = FEATURE_ARACHNID_APPENDAGES
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/arachnid_appendages
	use_mob_sprite_as_obj_sprite = TRUE

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/arachnid_appendages
	feature_key = FEATURE_ARACHNID_APPENDAGES
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_BEHIND = BODY_BEHIND_LAYER,
	)

/datum/bodypart_overlay/mutant/arachnid_appendages/get_global_feature_list()
	return SSaccessories.sprite_accessories[FEATURE_ARACHNID_APPENDAGES]

/datum/bodypart_overlay/mutant/arachnid_appendages/get_base_icon_state()
	return sprite_datum.icon_state //i hate you

/datum/bodypart_overlay/mutant/arachnid_appendages/can_draw_on_bodypart(mob/living/carbon/human/human)
	. = ..()
	return TRUE //show them anyway no matter what you're wearing


/obj/item/organ/arachnid_chelicerae
	name = "arachnid chelicerae"
	desc = "Some fang things, spooky."

	zone = BODY_ZONE_HEAD

	slot = ORGAN_SLOT_EXTERNAL_SNOUT

	mutantpart_key = FEATURE_ARACHNID_CHELICERAE
	restyle_flags = EXTERNAL_RESTYLE_FLESH // @_@ i dunno if chelicerae fall under fleshy but it's 05:20AM and i'm tired.

	bodypart_overlay = /datum/bodypart_overlay/mutant/arachnid_chelicerae
	use_mob_sprite_as_obj_sprite = TRUE

/datum/bodypart_overlay/mutant/arachnid_chelicerae
	feature_key = FEATURE_ARACHNID_CHELICERAE
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_BEHIND = BODY_BEHIND_LAYER,
	)

/datum/bodypart_overlay/mutant/arachnid_chelicerae/get_global_feature_list()
	return SSaccessories.sprite_accessories[FEATURE_ARACHNID_CHELICERAE]

/datum/bodypart_overlay/mutant/arachnid_chelicerae/get_base_icon_state()
	return sprite_datum.icon_state //i still hate you

/datum/bodypart_overlay/mutant/arachnid_chelicerae/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner, is_husked = FALSE)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDESNOUT)

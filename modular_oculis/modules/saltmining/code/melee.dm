
// CONTAINS THE PILE BUNKER, SICKLE, FUNNY GARDENER SHOVEL, THEN ADMIN PILE BUNKER

//aforementioned pile bunker

/obj/item/kinetic_crusher/pilebunker
	icon_state = "pb_spike"
	inhand_icon_state = "pb_spike"
	icon = 'modular_oculis/modules/saltmining/icons/bunker_item_64x.dmi'
	lefthand_file = 'modular_oculis/modules/saltmining/icons/melee_left_hand.dmi'
	righthand_file = 'modular_oculis/modules/saltmining/icons/melee_right_hand.dmi'
	name = "proto-kinetic pile bunker"
	desc = "An absolute beast of a crusher, designed to inflict as much damage as possible in a single strike, \
	with little regard for the user's own safety or physical ability to handle the weapon. Takes a short \
	moment to wind up a blow, and the spike has to be retracted after each use."
	worn_icon = 'icons/mob/clothing/belt.dmi'
	worn_icon_state = "gun"
	force = 0 //You can't hit stuff unless wielded
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = NONE
	base_pixel_x = -5
	pixel_x = -5
	throwforce = 0
	throw_speed = 0
	armour_penetration = 100 //yknow what fuck you, its a pile bunker
	hitsound = 'sound/items/weapons/sonic_jackhammer.ogg'
	attack_verb_continuous = list("impales", "stabs", "destroys", "strikes")
	attack_verb_simple = list("impale", "stab", "destroy", "strike")
	sharpness = SHARP_POINTY
	charge_time = 5 SECONDS //be patient, its alot of damage :)
	detonation_damage = 295 //add the five for a perfect 300 damage, enough to kill all basic enemies
	backstab_bonus = 200 //if you land a backstab it does 500 instead
	force_wielded = 5 //hit the crusher mark or suffer no damage
	var/armed = FALSE //is the weapon armed?
	var/windup_time = 0.5 SECONDS//IN SECONDS HOW LONG YOU NEED TO HOLD STILL TO STRIKE
	var/potentialrange = 1 //should be set same as melee range, essentially a fall back so if somebody teleports / moves away from the user, itll still cancel the attack
	var/spikeretracttime = 3 SECONDS //how long for the spike to retract?

/obj/item/kinetic_crusher/pilebunker/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=force_wielded)

/obj/item/kinetic_crusher/pilebunker/update_reskin(datum/atom_skin/crusher_skin/default_skin_typepath)
	return null

/obj/item/kinetic_crusher/pilebunker/recharge_projectile()
	if(!charged)
		charged = TRUE
		update_appearance()
		playsound(src.loc, 'sound/items/weapons/autoguninsert.ogg', 60, TRUE)

/obj/item/kinetic_crusher/pilebunker/attack(mob/living/target, mob/living/carbon/user)
	if(!armed)
		to_chat(user, span_warning("The pilebunker is not armed, re-arm it! (Right click while unarmed!)"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, span_warning("[src] is too heavy to use with one hand! You fumble and drop everything."))
		user.drop_all_held_items()
		return COMPONENT_CANCEL_ATTACK_CHAIN
	user.visible_message(
		span_boldwarning("[user] plants their feet firmly to the ground and  winds up an attack!"),
		span_boldwarning("You plant your feet firmly to the ground and wind up an attack!"),
	)
	if(do_after(user, windup_time, src) && (get_dist(user, target) <= potentialrange)) //this uses a snowflake variable because of the admin bunker lol
		armed = FALSE
		update_appearance()
		var/datum/status_effect/crusher_damage/C = target.has_status_effect(/datum/status_effect/crusher_damage)
		if(!C)
			C = target.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = target.health
		..()
		for(var/t in trophies)
			if(!QDELETED(target))
				var/obj/item/crusher_trophy/T = t
				T.on_melee_hit(target, user)
		if(!QDELETED(C) && !QDELETED(target))
			C.total_damage += target_health - target.health //we did some damage, but let's not assume how much we did
	else
		user.visible_message(
			span_boldwarning("[user] stumbles as their stance is broken!"),
			span_boldwarning("You stumble as your stance is broken!"),
		)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/kinetic_crusher/pilebunker/afterattack(mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!isliving(target))
		return
	for(var/obj/item/crusher_trophy/crusher_trophy as anything in trophies)
		crusher_trophy.on_melee_hit(target, user)
	if(QDELETED(target))
		return
	var/datum/status_effect/crusher_mark/mark = target.has_status_effect(/datum/status_effect/crusher_mark)
	if(!mark)
		return
	var/boosted_mark = mark.boosted
	if(!target.remove_status_effect(mark))
		return
	var/datum/status_effect/crusher_damage/crusher_damage_effect = target.has_status_effect(/datum/status_effect/crusher_damage) || target.apply_status_effect(/datum/status_effect/crusher_damage)
	var/target_health = target.health
	var/combined_damage = detonation_damage
	for(var/obj/item/crusher_trophy/crusher_trophy as anything in trophies)
		combined_damage += crusher_trophy.on_mark_detonation(target, user)
	if(QDELETED(target))
		return
	if(!QDELETED(crusher_damage_effect))
		crusher_damage_effect.total_damage += target_health - target.health
		playsound(user, 'sound/items/weapons/blastcannon.ogg', 100, TRUE)
		shake_camera(user, 10, 3)
		var/atom/throw_target = get_edge_target_turf(user, get_dir(target, user))
		user.throw_at(throw_target, 3, 5, gentle = FALSE)
	new /obj/effect/temp_visual/explosion/fast(get_turf(target))
	var/backstabbed = FALSE
	var/def_check = target.getarmor(type = BOMB)
	if(check_behind(user, target) || boosted_mark)
		backstabbed = TRUE
		combined_damage += backstab_bonus
		playsound(user, backstab_sound, 100, TRUE) //Seriously who spelled it wrong
	if(!QDELETED(crusher_damage_effect))
		crusher_damage_effect.total_damage += combined_damage
	SEND_SIGNAL(user, COMSIG_LIVING_CRUSHER_DETONATE, target, src, backstabbed)
	target.apply_damage(combined_damage, BRUTE, blocked = def_check)

/obj/item/kinetic_crusher/pilebunker/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!armed)
		playsound(user, 'sound/vehicles/mecha/hydraulic.ogg', 100, TRUE)
		if(do_after(user, spikeretracttime, src, IGNORE_USER_LOC_CHANGE | IGNORE_SLOWDOWNS))
			armed = TRUE
			update_appearance()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	. = ..()

/obj/item/kinetic_crusher/pilebunker/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	if(!armed)
		icon_state = "pb_spike"
		inhand_icon_state = "pb_spike"
	else
		icon_state = "pb"
		inhand_icon_state = "pb"
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON_STATE)

//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//

//Sickle, for rewarding consistency with bleed damage

/datum/status_effect/stacking/saw_bleed/sickle //For Sickle, essentially weaker saw
	id = "sickle_bleed"
	tick_interval = 6
	delay_before_decay = 60 //these take longer to decay
	overlay_file = 'icons/effects/bleed.dmi'
	overlay_state = "bleed"
	bleed_damage = 125 //weaker than cleaving saw bleed due to being more available

/obj/item/kinetic_crusher/sickle
	icon_state = "crushersickle"
	inhand_icon_state = "crushersickle"
	worn_icon_state = "crushersickle_belt"
	icon = 'modular_oculis/modules/saltmining/icons/melee_item.dmi'
	worn_icon = 'modular_oculis/modules/saltmining/icons/melee_item.dmi' //this is stored in the Melee items file even though its a worn sprite, simply because its the ONLY weapon worn sprite for melees
	lefthand_file = 'modular_oculis/modules/saltmining/icons/melee_left_hand.dmi'
	righthand_file = 'modular_oculis/modules/saltmining/icons/melee_right_hand.dmi'
	name = "proto-kinetic sickle"
	desc = "A simple yet effective design change was to curve the blade far more drastically, which \
	has resulted in a crusher that is capable of digging deep through the natural armor of local fauna \
	and cutting into veins and arteries, allowing the sickle design to cause extra damage through extreme blood loss. \
	It can be wielded with one hand and clips to the belt!"
	force = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	armour_penetration = 10
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	backstab_sound = list('sound/effects/wounds/pierce1.ogg', 'sound/effects/wounds/pierce2.ogg', 'sound/effects/wounds/pierce3.ogg')
	attack_verb_continuous = list("slashes", "slices", "cleaves", "chops", "swipes")
	attack_verb_simple = list("cleave", "slice", "cut", "swipe", "slash")
	sharpness = SHARP_EDGED
	charged = TRUE
	charge_time = 10
	detonation_damage = 25 //40 on a detonation 60 on a backstab but you get 125 bonus if you whack do three marks
	backstab_bonus = 20
	acts_as_if_wielded = TRUE

/obj/item/kinetic_crusher/sickle/Initialize(mapload)
	. = ..()
	qdel(GetComponent(/datum/component/two_handed))

/obj/item/kinetic_crusher/sickle/update_icon_state() //this fixes trying to two hand the sickle making it dissapear
	. = ..()
	if(base_icon_state == initial(base_icon_state))
		inhand_icon_state = "crushersickle"

/obj/item/kinetic_crusher/sickle/examine(mob/living/user)
	. += span_notice("Mark a large creature with a destabilizing force with right-click, then hit them in melee to do <b>[force + detonation_damage]</b> damage.")
	. += span_notice("Does <b>[force + detonation_damage + backstab_bonus]</b> damage if the target is backstabbed, instead of <b>[force + detonation_damage]</b>.")
	. += span_notice("Does <b> 4 </b> stack of bleed on mark detonation, <b> 6 </b> for a backstab. upon reaching <b> 10 </b> stacks of bleed, deals <b> 125 </b> extra damage.")
	for(var/t in trophies)
		var/obj/item/crusher_trophy/T = t
		. += span_notice("It has \a [T] attached, which causes [T.effect_desc()].")

/obj/item/kinetic_crusher/sickle/afterattack(mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!isliving(target))
		return
	for(var/obj/item/crusher_trophy/crusher_trophy as anything in trophies)
		crusher_trophy.on_melee_hit(target, user)
	if(QDELETED(target))
		return
	var/datum/status_effect/crusher_mark/mark = target.has_status_effect(/datum/status_effect/crusher_mark)
	if(!mark)
		return
	var/boosted_mark = mark.boosted
	if(!target.remove_status_effect(mark))
		return
	var/datum/status_effect/crusher_damage/crusher_damage_effect = target.has_status_effect(/datum/status_effect/crusher_damage) || target.apply_status_effect(/datum/status_effect/crusher_damage)
	var/target_health = target.health
	var/combined_damage = detonation_damage
	var/datum/status_effect/stacking/saw_bleed/sickle/existing_bleed = target.has_status_effect(/datum/status_effect/stacking/saw_bleed/sickle)
	if(existing_bleed)
		existing_bleed.add_stacks(4)
	else
		target.apply_status_effect(/datum/status_effect/stacking/saw_bleed/sickle, 4)
	for(var/obj/item/crusher_trophy/crusher_trophy as anything in trophies)
		combined_damage += crusher_trophy.on_mark_detonation(target, user)
	if(QDELETED(target))
		return
	if(!QDELETED(crusher_damage_effect))
		crusher_damage_effect.total_damage += target_health - target.health
	new /obj/effect/temp_visual/kinetic_blast(get_turf(target))
	var/backstabbed = FALSE
	var/def_check = target.getarmor(type = BOMB)
	if(check_behind(user, target) || boosted_mark)
		backstabbed = TRUE
		combined_damage += backstab_bonus
		existing_bleed = target.has_status_effect(/datum/status_effect/stacking/saw_bleed/sickle) //updates the var to check for existing bleed again (which should absolutely exist)
		if(existing_bleed)
			existing_bleed.add_stacks(2)
		else
			target.apply_status_effect(/datum/status_effect/stacking/saw_bleed/sickle, 2)
		playsound(user, pick(backstab_sound), 100, TRUE)
	if(!QDELETED(crusher_damage_effect))
		crusher_damage_effect.total_damage += combined_damage
	SEND_SIGNAL(user, COMSIG_LIVING_CRUSHER_DETONATE, target, src, backstabbed)
	target.apply_damage(combined_damage, BRUTE, blocked = def_check)

//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//

//The 'Gardener' Shovel - SCREAMING EAGLES!!!!!

/obj/item/shovel/gardener
	name = "'Gardener' Tactical Shovel"
	desc = "A specially designed shovel for digging extra fast, and tactically caving in the skulls of the local fauna."
	icon = 'modular_oculis/modules/saltmining/icons/melee_item.dmi'
	lefthand_file = 'modular_oculis/modules/saltmining/icons/melee_left_hand.dmi'
	righthand_file = 'modular_oculis/modules/saltmining/icons/melee_right_hand.dmi'
	hitsound = 'modular_oculis/modules/saltmining/sound/shovelthwack.ogg'
	icon_state = "gardener"
	inhand_icon_state = "gardener"
	slot_flags = NONE //Nope, no belt storage lol
	icon_angle = 135
	force = 13 //matches that of a toolbox
	throwforce = 10
	sharpness = NONE //GOD BLESS AMERICA, HIT EM WITH THE FLAT SIDE OF IT
	tool_behaviour = TOOL_SHOVEL
	toolspeed = 0.05 //super fast tactical shovel!!!! seriously though you spent money on THIS?? fine, you can have a fast shovel!
	usesound = 'sound/effects/shovel_dig.ogg'
	attack_verb_continuous = list("gardens", "beats", "thwacks", "thumps")
	attack_verb_simple = list("garden", "beat", "thwack", "thump")
	var/lavafauna_bonus = 27 //totals 40 damage versus lavaland fauna
	var/random_crit_damage = 150 //break their knee caps
	var/random_crit_pvp_damage = 7 //not alot, but it is extra damage
	var/critchance = 15 //chance to crit, lower is higher. Set to 1 for guranteed, do not set to 0.

/obj/item/shovel/gardener/examine(mob/living/user)
	. = ..()
	. += span_notice("SCREAMING EAGLES!!! You have the strangest feeling it might randomly 'crit' against anything you hit... the numbers 1 in [critchance] resonate in your head... whatever the fuck all that means.")

/obj/item/shovel/gardener/attack(mob/living/target, mob/living/carbon/human/user)
	var/crit = rand(1,critchance)
	if(target.has_faction(list(FACTION_MINING, FACTION_BOSS)))
		force += lavafauna_bonus
		if(crit == 1) //RANDOM CRIT!!!
			force += random_crit_damage
			playsound(target, 'modular_oculis/modules/saltmining/sound/randomcrit.ogg', 100, TRUE)
			target.balloon_alert_to_viewers("<font color='green'>CRITICAL HIT!</font>")
	else if (crit == 1) //RANDOM CRIT!!! BUT AGAINST A PERSON!!!
		force += random_crit_pvp_damage
		playsound(target, 'modular_oculis/modules/saltmining/sound/randomcrit.ogg', 100, TRUE)
		target.balloon_alert_to_viewers("<font color='green'>CRITICAL HIT!</font>")
	. = ..()
	if(target.has_faction(list(FACTION_MINING, FACTION_BOSS))) //we then run through again and fix the damage
		force -= lavafauna_bonus
		if(crit == 1) //undo random crit damage
			force -= random_crit_damage
	else if (crit == 1)
		force -= random_crit_pvp_damage
	return FALSE
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//

//Admin only Pile bunker, because its funny

/obj/item/kinetic_crusher/pilebunker/looong //does not need to mark people :trollface:
	icon_state = "THEpilebunker_spike"
	inhand_icon_state = "THEpilebunker_spike"
	icon = 'modular_oculis/modules/saltmining/icons/meme_bunker_256x32.dmi'
	lefthand_file = 'modular_oculis/modules/saltmining/icons/meme_bunker_left_hand.dmi'
	righthand_file = 'modular_oculis/modules/saltmining/icons/meme_bunker_right_hand.dmi'
	name = "Slightly longer than usual pilebunker"
	desc = "A significantly more destructive pilebunker that can mark and obliterate people without needing to mark targets. Unleash the truth with the almighty truthbunker."
	force_wielded = 100000
	force = 100000
	w_class = WEIGHT_CLASS_TINY
	worn_icon_state = ""
	slot_flags = NONE
	base_pixel_x = -126
	pixel_x = -126
	inhand_x_dimension = -194
	armour_penetration = 1000
	attack_verb_continuous = list("continues to truthbunker")
	attack_verb_simple = list("truthbunkers")
	sharpness = SHARP_EDGED
	windup_time = 0
	reach = 30 //to the great beyond
	potentialrange = 30
	spikeretracttime = 0 SECONDS //instant lol
	var/dev_explosion_size = 1 //vars for easy editting of the explosion, incase you dont want to explode
	var/heavy_explosion_size = 5
	var/light_explosion_size = 10
	var/flame_explosion_size = 15
	var/flash_explosion_size = 3

/obj/item/kinetic_crusher/pilebunker/looong/update_wielding()
	AddComponent(/datum/component/two_handed, force_unwielded = 100000, force_wielded = force_wielded)

/obj/item/kinetic_crusher/pilebunker/looong/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	if(!armed)
		icon_state = "THEpilebunker_spike"
		inhand_icon_state = "THEpilebunker_spike"
	else
		icon_state = "THEpilebunker"
		inhand_icon_state = "THEpilebunker"
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON_STATE)

/obj/item/kinetic_crusher/pilebunker/looong/attack(mob/living/target, mob/living/carbon/user)
	playsound(user, 'sound/items/weapons/blastcannon.ogg', 200, TRUE) //so loud...
	var/atom/throw_target = get_edge_target_turf(user, get_dir(target, user))
	user.throw_at(throw_target, 100, 1000, spin = 100, gentle = FALSE) //yeets you into oblivion
	explosion(target, devastation_range = 1, heavy_impact_range = 5, light_impact_range = 10, flame_range = 15, flash_range = 3, adminlog = FALSE)
	var/atom/throw_opponent = get_edge_target_turf(target, get_dir(user, target))
	target.throw_at(throw_opponent, 100, 1000, spin = 100, gentle = FALSE) //yeets THEM into oblivion
	new /obj/effect/temp_visual/explosion/fast(get_turf(target))
	explosion(target, devastation_range = dev_explosion_size, heavy_impact_range = heavy_explosion_size, light_impact_range = light_explosion_size, flame_range = flame_explosion_size, flash_range = flash_explosion_size, adminlog = FALSE)
	return ..()

/obj/item/kinetic_crusher/pilebunker/looong/examine(mob/living/user)
	. += span_notice("<b>you have a feeling you might want to be in god mode before using this. Death will be instant for your target... ALSO ITS VERY EXPLOSIVE SO BEWARE OF USING IT NEAR A LOCATION YOU WANT TO KEEP INTACT!! IF YOU WANT TO EDIT THE EXPLOSION SEARCH IN VARIABLES FOR 'EXPLOSION'</b>")

/obj/item/kinetic_crusher/pilebunker/looong/fire_kinetic_blast() //does nothing, and cannot mark targets

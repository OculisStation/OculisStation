//Hunter magic, a rare drop from the surplus necro crate that grants you five spells for fighting lavaland fauna (only for use on lavaland)

/obj/item/huntermagicbook //why do i not use a granter book subtype? because it grants five spells at once, so this is a work around for all the problems a multi-spell granting book would cause
	name = "Mysterious Annotated Journal"
	desc = "An old, partially burnt miners jounral, full of notes and ramblings. At just a glance it seems to be something about harvesting the power of the Necropolis for ones own use."
	icon = 'modular_oculis/modules/saltmining/icons/MagicBook.dmi'
	icon_state = "huntermagic"

/obj/item/huntermagicbook/attack_self(mob/user)
	var/datum/action/cooldown/spell/pointed/projectile/fireball/hunter/new_spell1 = new(user)
	var/datum/action/cooldown/spell/conjure_item/infinite_guns/hunter/new_spell2 = new(user)
	var/datum/action/cooldown/spell/conjure/the_traps/hunter/new_spell3 = new(user)
	var/datum/action/cooldown/spell/touch/smite/hunter/siphon/new_spell4 = new(user)
	var/datum/action/cooldown/spell/touch/smite/hunter/new_spell5 = new(user)
	if(locate(new_spell1) in user.actions) //while theoretically you could relearn every spell if you somehow didnt have spell1, that would probably be an issue that should never occur...
		to_chat(user, span_warning("You already know how to harvest the energy of the Necropolis! Don't drive yourself insane like the previous owner."))
		return FALSE
	to_chat(user, span_notice("You open the book and take a closer read over the old miners notes, learning to control the powers of the Necropolis for yourself. However the inside is mixed with odd symbols and obviously mad ramblings, this could take a bit to decipher..."))
	playsound(user, 'sound/effects/page_turn/pageturn3.ogg', 100, TRUE)
	for(var/i in 1 to 3)
		if(do_after(user, 3 SECONDS))
			playsound(user, 'sound/effects/page_turn/pageturn3.ogg', 100, TRUE)
			to_chat(user, span_notice("You turn the page, taking a moment to slowly decipher and seperate the true knowledge from mad ramblings of the previous owner."))
		else
			to_chat(user, span_warning("You are interrupted, and you loose your spot. You will have to start from the beginning again..."))
			return FALSE
	to_chat(user, span_notice("As you finish, the book completely burns away into the air. You have a feeling next time you are within vicinity of the Necropolis, you will be able to harness it's power for yourself."))
	new_spell1.Grant(user)
	new_spell2.Grant(user)
	new_spell3.Grant(user)
	new_spell4.Grant(user)
	new_spell5.Grant(user)
	qdel(src)

/datum/action/cooldown/spell/pointed/projectile/fireball/hunter //Less of a combat spell and actually just here for mining (hilarious i know because its a subtype of fireball, one of the most lethal spells)
	name = "Energy Shards"
	desc = "Channel the energy of the Necropolis into small shards capable of mining rocka"
	button_icon_state = "charge"
	background_icon_state = "bg_demon"
	sound = 'sound/effects/magic/magic_missile.ogg'
	school = SCHOOL_EVOCATION
	cooldown_time = 5 SECONDS //very low cooldown on this one
	invocation = ""
	invocation_type = NONE //spell will probably be used often, will be annoying if you invoke everytime
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	active_msg = "You channel a bit of Necropolis energy into shards strong enough to break rocks."
	deactive_msg = "You crush the energy shards in your hand, returning it to where it came from."
	cast_range = 10
	projectile_amount = 5
	projectiles_per_fire = 1
	projectile_type = /obj/projectile/plasma/kineticshotgun/rockbreaker //yeeeup, just those shotgun pellets... its basically just a fast plasma cutter projectile so itll be just fine im sure
	var/failure_message = "The power of the Necropolis is too weak to create any meaningful shards of energy here!"

/datum/action/cooldown/spell/pointed/projectile/fireball/hunter/can_cast_spell(feedback = TRUE)
	var/owner_area = get_area(owner)
	if(!is_hunter_magic_allowed(owner_area))
		if(feedback)
			to_chat(owner, span_warning(failure_message), type = MESSAGE_TYPE_WARNING)
		return FALSE
	return ..()

/datum/action/cooldown/spell/conjure_item/infinite_guns/hunter //This is the primary damage dealing hunter spell, doing good damage and having low cooldown
	name = "Necropolis Flames"
	desc = "Gather the energy of the Necropolis into your hand and send it out as \
	fireballs that specialize in downing fauna."
	cooldown_time = 15 //short cooldown
	button_icon_state = "arcane_barrage"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	var/failure_message = "You can't seem to gather enough Necropolis energy here to cast this!"
	item_type = /obj/item/gun/magic/wand/arcane_barrage/hunter

/obj/item/gun/magic/wand/arcane_barrage/hunter
	name = "Necropolis Flame"
	desc = "The energy of the Necropolis, channeled into a lethal, fauna killing flame, and its yours to control."
	fire_sound = 'sound/effects/magic/fireball.ogg'
	fire_sound_volume = 30 //dont want to be too loud
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "arcane_barrage"
	inhand_icon_state = "arcane_barrage"
	base_icon_state = "arcane_barrage"
	icon_angle = 90
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	slot_flags = null
	item_flags = DROPDEL | ABSTRACT | NOBLUDGEON
	flags_1 = NONE
	weapon_weight = WEAPON_HEAVY
	max_charges = 30
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/hunter

/obj/item/ammo_casing/magic/arcane_barrage/hunter
	projectile_type = /obj/projectile/magic/arcane_barrage/hunter

/obj/projectile/magic/arcane_barrage/hunter
	name = "necropolis fireball"
	icon_state = "arcane_barrage"
	damage = 5
	damage_type = BRUTE //why is it brute? because lava fauna is resistant to fire damage.
	hitsound = 'sound/effects/magic/mm_hit.ogg'
	lavafauna_mod = 4 //does 20 damage per shot to lavaland fauna, meaning a full arcane hunter barrage will do 600 damage total, enough for two goliaths

/datum/action/cooldown/spell/conjure_item/infinite_guns/hunter/can_cast_spell(feedback = TRUE)
	var/owner_area = get_area(owner)
	if(!is_hunter_magic_allowed(owner_area))
		if(feedback)
			to_chat(owner, span_warning(failure_message), type = MESSAGE_TYPE_WARNING)
		return FALSE
	return ..()


/datum/action/cooldown/spell/conjure/the_traps/hunter //Light crowd control, heavy area denial
	name = "Fauna Traps"
	desc = "Summon a number of anti-Fauna traps that do heavy damage to fauna that steps on them."
	cooldown_time = 30 SECONDS
	invocation = "WATCH YOUR STEP!"
	background_icon_state = "bg_demon"
	garbled_invocation_prob = 0
	summon_radius = 2
	summon_type = /obj/structure/trap/damage/hunter
	summon_lifespan = 1 MINUTES
	summon_amount = 5
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	var/failure_message = "The power of the Necropolis is too weak here to create any traps!"

/obj/structure/trap/damage/hunter
	name = "fauna trap"
	desc = "A trap that will errupt under fauna and deal heavy damage. Does only minor damage to non-fauna."
	icon_state = "ward"
	alpha = 200 //visible for you and others, because its not like fauna are going to avoid stepping on them (elites are excluded but im sure you could still bait one to step in them)

/obj/structure/trap/damage/hunter/trap_effect(mob/living/victim)
	if(victim.has_faction(list(FACTION_MINING, FACTION_BOSS)))
		victim.adjust_brute_loss(175) //enough to kill a goliath in two, but one shot watchers
	else
		to_chat(victim, span_bolddanger("You stumble as the ground beneath you churns, but doesn't quite erupt like you expect.")) //People are barely affected by it
		victim.adjust_brute_loss(5)
	var/obj/structure/flora/rock/style_random/giant_rock = new(get_turf(src))
	QDEL_IN(giant_rock, 5 SECONDS)

/datum/action/cooldown/spell/conjure/the_traps/hunter/can_cast_spell(feedback = TRUE)
	var/owner_area = get_area(owner)
	if(!is_hunter_magic_allowed(owner_area))
		if(feedback)
			to_chat(owner, span_warning(failure_message), type = MESSAGE_TYPE_WARNING)
		return FALSE
	return ..()

/datum/action/cooldown/spell/touch/smite/hunter //Problematic enemy deletion button, heavy damage strike versus bosses
	name = "Necropolis Smite"
	desc = "Focus hard and channel extreme amounts of energy from the Necropolis into your hand and unleash it upon your target in the form of a punch! Lesser foes will succumb immedietly, but stronger ones may be able to withstand the attack!"
	button_icon_state = "gib"
	background_icon_state = "bg_demon"
	sound = 'sound/effects/magic/disintegrate.ogg'
	cooldown_time = 1.5 MINUTES
	invocation = "PERISH!"
	garbled_invocation_prob = 0
	sparks_amt = 9
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	hand_path = /obj/item/melee/touch_attack/smite/hunter
	var/failure_message = "The power of the Necropolis is too weak to gather into a meaningful strike here!"

/datum/action/cooldown/spell/touch/smite/hunter/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	if(victim.has_faction(FACTION_BOSS)) //we check this first because while all lavaland fauna are FACTION_MINING not all lavaland fauna is FACTION_BOSS, and we dont want to be gibbing bosses (not that they can be usually)
		new /obj/effect/temp_visual/explosion/fast(get_turf(victim))
		to_chat(caster, span_bolddanger("The volatile energy of the Necropolis flies from your hand and into your foe, however it manages to contain the energy, though is clearly heavily injured by doing so!"))
		victim.adjust_brute_loss(500)
		return TRUE
	if(victim.has_faction(FACTION_BOSS)) //this is checked second, so essentially if the boss tag isnt found, then we resort to checking if mining is, then we gib
		new /obj/effect/gibspawner(get_turf(victim))
		new /obj/effect/temp_visual/explosion/fast(get_turf(victim))
		to_chat(caster, span_bolddanger("The volatile energy of the Necropolis flies from your hand and into your foe, whos body ripples violently before exploding in a shower of gore!"))
		victim.gib(DROP_ALL_REMAINS)
		return TRUE
	else //if boss tag isnt found nor the mining tag, then we just harm as if it was a basic target
		to_chat(victim, span_bolddanger("The volatile Necropolis energy flies off [caster.name]'s hand and at you, with some intense stinging!")) //People are not as affected by it compared to fauna
		to_chat(caster, span_bolddanger("The volatile Necropolis energy flies off your hand and at [victim.name], but bounces off rather undwerwhelmingly."))
		victim.adjust_fire_loss(30) //does only 30 burn damage to people, not very good for a 1:30 cooldown spell.
	return TRUE

/obj/item/melee/touch_attack/smite/hunter
	name = "\improper Supercharged Necropolis Energy"
	desc = "It swirls around your hand violently, as if ready to burst at any moment!"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"

/datum/action/cooldown/spell/touch/smite/hunter/can_cast_spell(feedback = TRUE)
	var/owner_area = get_area(owner)
	if(!is_hunter_magic_allowed(owner_area))
		if(feedback)
			to_chat(owner, span_warning(failure_message), type = MESSAGE_TYPE_WARNING)
		return FALSE
	return ..()

/datum/action/cooldown/spell/touch/smite/hunter/siphon //specialized version of hunter smite that is more available and meant for sustaining yourself
	name = "Lifesteal Strike"
	desc = "Surround your fist with leeching Necropolis energy and strike a foe to siphon their life force for yourself!"
	button_icon_state = "scream_for_me"
	sound = 'sound/effects/magic/staff_healing.ogg'
	cooldown_time = 45 SECONDS
	invocation = "SUSTAIN ME!"
	sparks_amt = 4
	hand_path = /obj/item/melee/touch_attack/smite/hunter/siphon

/datum/action/cooldown/spell/touch/smite/hunter/siphon/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	if(victim.has_faction(list(FACTION_MINING, FACTION_BOSS))) //this works on bosses and regular mining fauna the same, unlike hunter smite
		new /obj/effect/temp_visual/cleave(get_turf(victim))
		playsound(caster, 'sound/effects/wounds/pierce3.ogg', 100, TRUE)
		to_chat(caster, span_bolddanger("The leeching energy of the Necropolis flies into your foe, causing blood to spray out of them and onto you, which quickly absorbs into you. You feel alot better!"))
		victim.adjust_brute_loss(175) //can kill watchers instantly, not quite goliaths
		caster.adjust_brute_loss(-30) //heal for 30 brute
		caster.adjust_fire_loss(-30) //heal for 30 burn
		caster.adjust_tox_loss(-15, forced = TRUE) //heal for 15 toxin loss, incase you maybe overdosed, which this wont stop you from dying probably but will at least stall it a lil
		caster.adjust_oxy_loss(-50) //heal for 50 oxygen damage if you somehow attained that and are still conscious
		return TRUE //Just for note, this is only 5 more burn and brute healing than a legion core would get you (if not implanted) so with this on a 45 second cooldown it should probably be pretty balanced.
	else //This still does pretty much NOTHING to people, and wont heal you for targetting them
		to_chat(victim, span_bolddanger("The leeching Necropolis energy flies off [caster.name]'s hand and at you, but dispels as soon as it hits you.")) //People are not as affected by it compared to fauna
		to_chat(caster, span_bolddanger("The leeching Necropolis energy flies off your hand and at [victim.name], but bounces off and dissipates with no effect."))
	return TRUE

/obj/item/melee/touch_attack/smite/hunter/siphon
	name = "\improper Leeching Necropolis Energy"
	desc = "It swirls around your hand slowly, as if waiting to extract something..."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "scream_for_me"
	inhand_icon_state = "disintegrate"




/proc/is_hunter_magic_allowed(area)
	var/static/list/allowed_areas_typecache
	if(isnull(allowed_areas_typecache))
		allowed_areas_typecache = zebra_typecacheof(list(
			/area/forestplanet = TRUE,
			/area/icemoon = TRUE,
			/area/lavaland = TRUE,
			/area/ocean = TRUE,
			/area/ruin = TRUE,
			/area/ruin/interdyne_planetary_base = FALSE,
			/area/ruin/unpowered/ash_walkers = FALSE,
			/area/ruin/unpowered/primitive_catgirl_den = FALSE,
		))
	return is_type_in_typecache(area, allowed_areas_typecache)

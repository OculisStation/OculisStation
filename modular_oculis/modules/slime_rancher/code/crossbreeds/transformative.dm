/mob/living/basic/slime
	/// Transformative extracts stuck onto us, oldest first. Our babies get all of them.
	var/list/datum/slime_transformation/transformations
	/// Every transformation's color mixed into one, for the warping core drawn inside us.
	var/transformation_color
	/// Extra babies we make per split.
	var/extra_babies = 0
	/// A split leaves us an adult.
	var/keeps_parent_adult = FALSE
	/// Never splits and never mutates.
	var/blocks_reproduction = FALSE
	/// Added on top of every bit of charge we build up on our own.
	var/extra_charge = 0
	/// Nutrition doesn't drain over time.
	var/stops_hunger = FALSE
	/// Alpha we use instead of our color's whenever we aren't latched onto someone.
	var/stealth_alpha

/// Gives us a transformation. Returns the new datum, or null if we already have that one or are full.
/mob/living/basic/slime/proc/add_transformation(datum/slime_transformation/transformation_type, mob/living/user)
	if(length(transformations) >= SLIME_MAX_TRANSFORMATIONS || (locate(transformation_type) in transformations))
		return null
	var/datum/slime_transformation/transformation = new transformation_type(src, user)
	LAZYADD(transformations, transformation)

	var/count = length(transformations)
	var/red = 0
	var/green = 0
	var/blue = 0
	var/saturation = 0
	var/lightness = 0
	for(var/datum/slime_transformation/mixed_in as anything in transformations)
		var/list/rgb = rgb2num(mixed_in.overlay_color)
		var/list/hsl = rgb2num(mixed_in.overlay_color, COLORSPACE_HSL)
		red += rgb[1]
		green += rgb[2]
		blue += rgb[3]
		saturation += hsl[2]
		lightness += hsl[3]
	// a straight average of bright colors looks like shit, so the average only picks the hue
	var/list/averaged = rgb2num(rgb(red / count, green / count, blue / count), COLORSPACE_HSL)
	transformation_color = rgb(averaged[1], saturation / count, lightness / count, space = COLORSPACE_HSL)

	regenerate_icons()
	return transformation

/mob/living/basic/slime/Destroy()
	QDEL_LIST(transformations)
	return ..()

/mob/living/basic/slime/examine(mob/user)
	. = ..()
	for(var/datum/slime_transformation/transformation as anything in transformations)
		. += span_notice(transformation.desc)

/mob/living/basic/slime/regenerate_icons()
	. = ..()
	if(stealth_alpha)
		if(isliving(buckled))
			alpha = slime_type.transparent ? SLIME_TRANSPARENCY_ALPHA : src::alpha
		else
			alpha = stealth_alpha
	if(stat == DEAD)
		return
	if(transformation_color)
		var/mutable_appearance/warping_core = mutable_appearance('modular_iris/modules/research/icons/slimecrossing.dmi', "warping", MOB_BELOW_PIGGYBACK_LAYER)
		warping_core.color = transformation_color
		add_overlay(warping_core)
	if(cat_slime)
		var/mutable_appearance/cat_ears = mutable_appearance('modular_oculis/modules/slime_rancher/icons/slime_cat_ears.dmi', "cat_ears-[life_stage]")
		cat_ears.color = slime_type.rgb_code
		add_overlay(cat_ears)

/mob/living/basic/slime/set_buckled(new_buckled)
	. = ..()
	// not COMSIG_LIVING_SET_BUCKLED, that fires before buckled changes, so regenerate_icons() would still see the old meal
	if(stealth_alpha)
		regenerate_icons()

/datum/slime_transformation
	/// Shown to anyone examining the slime.
	var/desc
	/// Our share of the color of the warping core drawn inside the slime.
	var/overlay_color
	var/mob/living/basic/slime/our_slime

/datum/slime_transformation/New(mob/living/basic/slime/our_slime, mob/living/user)
	src.our_slime = our_slime
	RegisterSignal(our_slime, COMSIG_SLIME_SPLIT, PROC_REF(on_split))
	on_apply(user)

/datum/slime_transformation/Destroy()
	our_slime = null
	return ..()

/datum/slime_transformation/proc/on_apply(mob/living/user)
	return

/datum/slime_transformation/proc/on_split(mob/living/basic/slime/source, mob/living/basic/slime/baby)
	SIGNAL_HANDLER
	baby.add_transformation(type)

/obj/item/slimecross/transformative
	name = "transformative extract"
	desc = "It seems to stick to any slime it comes in contact with."
	effect = "transformative"
	icon = 'modular_iris/modules/research/icons/slimecrossing.dmi'
	icon_state = "transformative"
	effect_desc = "Use on a slime to permanently change it."
	/// The transformation this extract sticks onto a slime.
	var/datum/slime_transformation/transformation_type

/obj/item/slimecross/transformative/examine(mob/user)
	. = ..()
	. += span_notice("A slime can hold [SLIME_MAX_TRANSFORMATIONS] of these at once, and passes them all on to its babies.")

/obj/item/slimecross/transformative/interact_with_atom(mob/living/basic/slime/target, mob/living/user, list/modifiers)
	if(!isslime(target))
		return NONE
	if(target.stat == DEAD)
		target.balloon_alert(user, "it's dead!")
		return ITEM_INTERACT_BLOCKING
	if(locate(transformation_type) in target.transformations)
		target.balloon_alert(user, "already has that one!")
		return ITEM_INTERACT_BLOCKING
	if(!target.add_transformation(transformation_type, user))
		target.balloon_alert(user, "can't take any more!")
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_notice("[user] presses [src] into [target], and it sinks right in."), span_notice("You press [src] into [target], and it sinks right in."))
	playsound(target, 'sound/effects/blob/attackblob.ogg', 50, TRUE)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/slimecross/transformative/grey
	colour = SLIME_TYPE_GREY
	transformation_type = /datum/slime_transformation/grey
	effect_desc = "Use on a slime to make it split into one extra baby every time."

/datum/slime_transformation/grey
	desc = "It splits into one extra baby."
	overlay_color = COLOR_SLIME_GREY

/datum/slime_transformation/grey/on_apply(mob/living/user)
	our_slime.extra_babies++

/obj/item/slimecross/transformative/orange
	colour = SLIME_TYPE_ORANGE
	transformation_type = /datum/slime_transformation/orange
	effect_desc = "Use on a slime to make its electric shocks set people on fire too."

/datum/slime_transformation/orange
	desc = "Anyone it shocks also catches fire."
	overlay_color = COLOR_SLIME_ORANGE
	var/fire_stacks = 2

/datum/slime_transformation/orange/on_apply(mob/living/user)
	RegisterSignal(our_slime, COMSIG_SLIME_SHOCKED, PROC_REF(on_shocked))

/datum/slime_transformation/orange/proc/on_shocked(mob/living/basic/slime/source, mob/living/carbon/target)
	SIGNAL_HANDLER
	target.adjust_fire_stacks(fire_stacks)
	target.ignite_mob()

/obj/item/slimecross/transformative/purple
	colour = SLIME_TYPE_PURPLE
	transformation_type = /datum/slime_transformation/purple
	effect_desc = "Use on a slime to make it slowly heal on its own."

/datum/slime_transformation/purple
	desc = "It slowly heals on its own."
	overlay_color = COLOR_SLIME_PURPLE
	var/heal_per_second = 0.25

/datum/slime_transformation/purple/on_apply(mob/living/user)
	RegisterSignal(our_slime, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/slime_transformation/purple/proc/on_life(mob/living/basic/slime/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(source.stat != DEAD)
		source.adjust_brute_loss(-heal_per_second * seconds_per_tick)

/obj/item/slimecross/transformative/blue
	colour = SLIME_TYPE_BLUE
	transformation_type = /datum/slime_transformation/blue
	effect_desc = "Use on a slime to stop it from ever splitting or mutating, so all it makes is extracts."

/datum/slime_transformation/blue
	desc = "It never splits and never mutates."
	overlay_color = COLOR_SLIME_BLUE

/datum/slime_transformation/blue/on_apply(mob/living/user)
	var/datum/status_effect/slime_reproducing/windup = our_slime.has_status_effect(/datum/status_effect/slime_reproducing)
	windup?.interrupt()
	our_slime.blocks_reproduction = TRUE
	our_slime.primed_split_cost = 0
	our_slime.pending_ranch_mutation = null
	our_slime.refresh_wanted_targets()

/obj/item/slimecross/transformative/metal
	colour = SLIME_TYPE_METAL
	transformation_type = /datum/slime_transformation/metal
	effect_desc = "Use on a slime to give it 30% more health."

/datum/slime_transformation/metal
	desc = "It can take a lot more punishment."
	overlay_color = COLOR_SLIME_METAL
	var/health_multiplier = 1.3

/datum/slime_transformation/metal/on_apply(mob/living/user)
	our_slime.maxHealth *= health_multiplier
	our_slime.health *= health_multiplier

/obj/item/slimecross/transformative/yellow
	colour = SLIME_TYPE_YELLOW
	transformation_type = /datum/slime_transformation/yellow
	effect_desc = "Use on a slime to make it build up electric charge three times as fast."

/datum/slime_transformation/yellow
	desc = "It builds up electric charge three times as fast."
	overlay_color = COLOR_SLIME_YELLOW
	var/extra_charge = 2

/datum/slime_transformation/yellow/on_apply(mob/living/user)
	our_slime.extra_charge += extra_charge

/obj/item/slimecross/transformative/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	transformation_type = /datum/slime_transformation/darkpurple
	effect_desc = "Use on a slime to make it turn plasma in the air into oxygen, healing itself as it does."

/datum/slime_transformation/darkpurple
	desc = "It turns plasma in the air into oxygen, and heals as it does."
	overlay_color = COLOR_SLIME_DARK_PURPLE
	/// Moles of plasma an adult converts per tick. Babies manage half.
	var/plasma_per_tick = 20
	var/heal_per_mole = 0.1

/datum/slime_transformation/darkpurple/on_apply(mob/living/user)
	RegisterSignal(our_slime, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/slime_transformation/darkpurple/proc/on_life(mob/living/basic/slime/source)
	SIGNAL_HANDLER
	if(source.stat == DEAD)
		return
	var/datum/gas_mixture/environment = source.loc.return_air()
	var/amount = source.life_stage == SLIME_LIFE_STAGE_ADULT ? plasma_per_tick : plasma_per_tick * 0.5
	if(environment?.moles[/datum/gas/plasma] < amount)
		return
	environment.moles[/datum/gas/plasma] -= amount
	environment.assert_gas(/datum/gas/oxygen)
	environment.moles[/datum/gas/oxygen] += amount
	environment.garbage_collect()
	source.adjust_brute_loss(-amount * heal_per_mole)

/obj/item/slimecross/transformative/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	transformation_type = /datum/slime_transformation/darkblue
	effect_desc = "Use on a slime to make it a cleaner. It eats messes, trash and pests, and stops hunting anything else."

/datum/slime_transformation/darkblue
	desc = "It eats messes and pests instead of hunting."
	overlay_color = COLOR_SLIME_DARK_BLUE

/datum/slime_transformation/darkblue/on_apply(mob/living/user)
	our_slime.set_cleaner_slime(TRUE)

/obj/item/slimecross/transformative/silver
	colour = SLIME_TYPE_SILVER
	transformation_type = /datum/slime_transformation/silver
	effect_desc = "Use on a slime to stop its nutrition from draining over time. It can still feed."

/datum/slime_transformation/silver
	desc = "It never gets hungrier over time."
	overlay_color = COLOR_SLIME_SILVER

/datum/slime_transformation/silver/on_apply(mob/living/user)
	// not hunger_disabled - that one stops it from feeding at all, and a slime that can't feed makes no extracts
	our_slime.stops_hunger = TRUE

/obj/item/slimecross/transformative/sepia
	colour = SLIME_TYPE_SEPIA
	transformation_type = /datum/slime_transformation/sepia
	effect_desc = "Use on a slime to make it move faster."

/datum/slime_transformation/sepia
	desc = "It moves faster."
	overlay_color = COLOR_SLIME_SEPIA

/datum/slime_transformation/sepia/on_apply(mob/living/user)
	our_slime.add_movespeed_modifier(/datum/movespeed_modifier/transformative_sepia)

/datum/movespeed_modifier/transformative_sepia
	multiplicative_slowdown = -0.3

/obj/item/slimecross/transformative/cerulean
	colour = SLIME_TYPE_CERULEAN
	transformation_type = /datum/slime_transformation/cerulean
	effect_desc = "Use on a slime to make it split into grown adults instead of babies, and stay an adult itself."

/datum/slime_transformation/cerulean
	desc = "It splits into grown adults, and stays one itself."
	overlay_color = COLOR_SLIME_CERULEAN

/datum/slime_transformation/cerulean/on_apply(mob/living/user)
	our_slime.keeps_parent_adult = TRUE

/datum/slime_transformation/cerulean/on_split(mob/living/basic/slime/source, mob/living/basic/slime/baby)
	. = ..()
	// an adult that "split" by dying is already a baby by now, and dying doesn't get you a free adult
	if(source.life_stage != SLIME_LIFE_STAGE_ADULT)
		return
	baby.set_life_stage(SLIME_LIFE_STAGE_ADULT)
	baby.update_name()
	baby.regenerate_icons()

/obj/item/slimecross/transformative/pyrite
	colour = SLIME_TYPE_PYRITE
	transformation_type = /datum/slime_transformation/pyrite
	effect_desc = "Use on a slime to make its babies come out a random color, though never rainbow."

/datum/slime_transformation/pyrite
	desc = "Its babies come out a random color, but never rainbow."
	overlay_color = COLOR_SLIME_PYRITE

/datum/slime_transformation/pyrite/on_split(mob/living/basic/slime/source, mob/living/basic/slime/baby)
	. = ..()
	baby.set_slime_type(pick(subtypesof(/datum/slime_type) - /datum/slime_type/rainbow - typesof(/datum/slime_type/unique)))

/obj/item/slimecross/transformative/red
	colour = SLIME_TYPE_RED
	transformation_type = /datum/slime_transformation/red
	effect_desc = "Use on a slime to make its attacks deal 10% more damage."

/datum/slime_transformation/red
	desc = "It hits a little harder."
	overlay_color = COLOR_SLIME_RED
	var/damage_multiplier = 1.1

/datum/slime_transformation/red/on_apply(mob/living/user)
	our_slime.melee_damage_lower *= damage_multiplier
	our_slime.melee_damage_upper *= damage_multiplier

/obj/item/slimecross/transformative/green
	colour = SLIME_TYPE_GREEN
	transformation_type = /datum/slime_transformation/green
	effect_desc = "Use on a slime to let it turn itself into a luminescent whenever it likes. Only does anything for a slime with a player in control."

/datum/slime_transformation/green
	desc = "If it has a mind of its own, it can choose to become a luminescent."
	overlay_color = COLOR_SLIME_GREEN
	var/datum/action/innate/become_luminescent/luminescent_action

/datum/slime_transformation/green/on_apply(mob/living/user)
	luminescent_action = new(src)
	luminescent_action.Grant(our_slime)

/datum/slime_transformation/green/Destroy()
	QDEL_NULL(luminescent_action)
	return ..()

/datum/action/innate/become_luminescent
	name = "Luminescent Evolution"
	desc = "Permanently become a luminescent, with one of your own extracts already inside you."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/hud/screen_alert.dmi'
	button_icon_state = "slimed"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/become_luminescent/Activate()
	var/mob/living/basic/slime/slime = owner
	var/mob/living/carbon/human/luminescent = new(slime.drop_location())
	luminescent.fully_replace_character_name(null, slime.real_name)
	luminescent.underwear = "Nude"
	luminescent.undershirt = "Nude"
	luminescent.socks = "Nude"
	luminescent.dna.features[FEATURE_MUTANT_COLOR] = slime.slime_type.rgb_code
	luminescent.dna.features[FEATURE_MUTANT_COLOR_TWO] = slime.slime_type.rgb_code
	luminescent.dna.features[FEATURE_MUTANT_COLOR_THREE] = slime.slime_type.rgb_code
	luminescent.set_species(/datum/species/jelly/luminescent)

	luminescent.put_in_active_hand(new slime.slime_type.core_type(luminescent))
	var/datum/action/innate/integrate_extract/integrate = locate() in luminescent.actions
	integrate.Trigger()

	slime.mind?.transfer_to(luminescent)
	qdel(slime)

/obj/item/slimecross/transformative/pink
	colour = SLIME_TYPE_PINK
	transformation_type = /datum/slime_transformation/pink
	effect_desc = "Use on a slime to make it a cat slime. It grows cat ears, and only hunts things smaller than itself."

/datum/slime_transformation/pink
	desc = "It only hunts things smaller than itself. Also, it has cat ears."
	overlay_color = COLOR_SLIME_PINK

/datum/slime_transformation/pink/on_apply(mob/living/user)
	our_slime.cat_slime = TRUE

/obj/item/slimecross/transformative/oil
	colour = SLIME_TYPE_OIL
	transformation_type = /datum/slime_transformation/oil
	effect_desc = "Use on a slime to make it douse whatever it latches onto in welding fuel."

/datum/slime_transformation/oil
	desc = "It douses whatever it latches onto in fuel."
	overlay_color = COLOR_SLIME_OIL
	var/fire_stacks = 2

/datum/slime_transformation/oil/on_apply(mob/living/user)
	RegisterSignal(our_slime, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_set_buckled))

/datum/slime_transformation/oil/proc/on_set_buckled(mob/living/basic/slime/source, mob/living/meal)
	SIGNAL_HANDLER
	if(isliving(meal))
		meal.adjust_fire_stacks(fire_stacks)

/obj/item/slimecross/transformative/black
	colour = SLIME_TYPE_BLACK
	transformation_type = /datum/slime_transformation/black
	effect_desc = "Use on a slime to make it nearly invisible, except while it is latched onto something."

/datum/slime_transformation/black
	desc = "It is nearly invisible, except while it feeds."
	overlay_color = COLOR_SLIME_BLACK
	var/stealth_alpha = 64

/datum/slime_transformation/black/on_apply(mob/living/user)
	our_slime.stealth_alpha = stealth_alpha

/obj/item/slimecross/transformative/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	transformation_type = /datum/slime_transformation/lightpink
	effect_desc = "Use on a slime to let ghosts take control of it. Whoever controls it is told to serve you."

/datum/slime_transformation/lightpink
	desc = "Something from beyond could move in and take control of it."
	overlay_color = COLOR_SLIME_LIGHT_PINK
	var/obj/effect/mob_spawn/ghost_role/transformed_slime/spawner
	/// Name of whoever used the extract, passed down to babies.
	var/master_name

/datum/slime_transformation/lightpink/on_apply(mob/living/user)
	spawner = new(our_slime)
	RegisterSignal(our_slime, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_attack_ghost))
	if(user)
		serve(user.real_name)

/datum/slime_transformation/lightpink/Destroy()
	QDEL_NULL(spawner)
	return ..()

/datum/slime_transformation/lightpink/proc/serve(new_master_name)
	master_name = new_master_name
	spawner.important_text = "Assist [master_name] at all costs."

/datum/slime_transformation/lightpink/on_split(mob/living/basic/slime/source, mob/living/basic/slime/baby)
	var/datum/slime_transformation/lightpink/inherited = baby.add_transformation(type)
	if(master_name)
		inherited.serve(master_name)

/datum/slime_transformation/lightpink/proc/on_attack_ghost(mob/living/basic/slime/source, mob/dead/observer/ghost)
	SIGNAL_HANDLER
	if(source.ckey)
		return
	INVOKE_ASYNC(spawner, TYPE_PROC_REF(/atom, attack_ghost), ghost)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/effect/mob_spawn/ghost_role/transformed_slime
	name = "transformed slime"
	desc = "It seems to pulse slightly with an inner life."
	density = FALSE
	prompt_name = "a transformed slime"
	you_are_text = "You are a slime."
	flavour_text = "You were suddenly awakened by the power of a strange, foreign core inside of you."
	role_ban = ROLE_GHOST_ROLE
	// the slime is still there for the next ghost if this one leaves
	infinite_use = TRUE
	deletes_on_zero_uses_left = FALSE

/obj/effect/mob_spawn/ghost_role/transformed_slime/allow_spawn(mob/user, silent = FALSE)
	var/mob/living/basic/slime/slime = loc
	if(slime.stat == DEAD || slime.ckey)
		if(!silent)
			to_chat(user, span_warning("This slime is [slime.ckey ? "already taken" : "dead"]!"))
		return FALSE
	return TRUE

// nothing to create, the slime we're sitting in is the mob
/obj/effect/mob_spawn/ghost_role/transformed_slime/create(mob/mob_possessor, newname, apply_prefs)
	special(loc, mob_possessor, apply_prefs)
	return loc

/obj/item/slimecross/transformative/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	transformation_type = /datum/slime_transformation/adamantine
	effect_desc = "Use on a slime to halve the brute damage it takes."

/datum/slime_transformation/adamantine
	desc = "It shrugs off half of any brute damage."
	overlay_color = COLOR_SLIME_ADAMANTINE
	var/brute_multiplier = 0.5

/datum/slime_transformation/adamantine/on_apply(mob/living/user)
	MODIFY_PHYSIOLOGY(our_slime, BRUTE, brute_multiplier)

/obj/item/slimecross/transformative/rainbow
	colour = SLIME_TYPE_RAINBOW
	transformation_type = /datum/slime_transformation/rainbow
	effect_desc = "Use on a slime to make it change color at random every now and then."

/datum/slime_transformation/rainbow
	desc = "It changes color at random every now and then."
	overlay_color = COLOR_SLIME_RAINBOW
	/// Percent chance per second to change color.
	var/change_chance = 2.5

/datum/slime_transformation/rainbow/on_apply(mob/living/user)
	RegisterSignal(our_slime, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/slime_transformation/rainbow/proc/on_life(mob/living/basic/slime/source, seconds_per_tick)
	SIGNAL_HANDLER
	// a wind-up already decided what color it ends on, don't pull the rug out from under it
	if(source.stat == DEAD || source.has_status_effect(/datum/status_effect/slime_reproducing))
		return
	if(SPT_PROB(change_chance, seconds_per_tick))
		source.set_slime_type()

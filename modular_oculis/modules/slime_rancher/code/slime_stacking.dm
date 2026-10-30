/// How many slimes tall a tower gets, counting the one on the floor.
#define SLIME_MAX_STACK_HEIGHT 4
/// Pixels a slime sits above the adult under it.
#define SLIME_STACK_PIXEL_Z_ADULT 9
/// Pixels a slime sits above the baby under it.
#define SLIME_STACK_PIXEL_Z_BABY 7
/// Chance per second that a riding slime gets bored and hops off.
#define SLIME_STACK_HOP_OFF_CHANCE 2
#define SLIME_STACK_OFFSET "slime_stack"

/mob/living/basic/slime
	COOLDOWN_DECLARE(stack_cooldown)

/// Whether we're bored enough to go sit on another slime right now
/mob/living/basic/slime/proc/wants_to_stack()
	if(buckled || has_buckled_mobs() || IS_UNCONSCIOUS_OR_CRIT(src))
		return FALSE
	if(!COOLDOWN_FINISHED(src, stack_cooldown))
		return FALSE
	if(ai_controller?.blackboard[BB_SLIME_RABID] || has_status_effect(/datum/status_effect/slime_reproducing))
		return FALSE
	return !was_recently_attacked()

/// Whether this slime makes a good seat. Also decides if we stay on the one we're already riding.
/mob/living/basic/slime/proc/can_stack_onto(mob/living/basic/slime/seat)
	if(!isslime(seat) || seat == src || IS_UNCONSCIOUS_OR_CRIT(seat) || seat.client || !isturf(seat.loc))
		return FALSE
	if(seat.is_latched() || seat.has_status_effect(/datum/status_effect/slime_reproducing))
		return FALSE
	// a big slime on a little one just looks like the little one got eaten
	if(life_stage == SLIME_LIFE_STAGE_ADULT && seat.life_stage != SLIME_LIFE_STAGE_ADULT)
		return FALSE
	if(buckled == seat)
		return TRUE
	if(seat.has_buckled_mobs())
		return FALSE
	var/tower_height = 1
	for(var/mob/living/basic/slime/below = seat.buckled; isslime(below); below = below.buckled)
		tower_height++
	return tower_height < SLIME_MAX_STACK_HEIGHT

/// Hops on top of another slime.
/mob/living/basic/slime/proc/stack_onto(mob/living/basic/slime/seat)
	forceMove(get_turf(seat))
	if(!seat.buckle_mob(src, force = TRUE))
		return FALSE
	set_temporary_mood(SLIME_MOOD_SMILE)
	manual_emote("hops on top of [seat].")
	return TRUE

/// Gets off the slime we're sitting on. Whoever's on top of us tumbles, see set_buckled()
/mob/living/basic/slime/proc/hop_off_stack()
	if(!isslime(buckled))
		return
	// has to be forced, we have can_buckle_to = FALSE and unbuckle_mob() quietly does nothing otherwise
	buckled.unbuckle_mob(src, force = TRUE)

/// Starts the wait before we'll climb onto another slime.
/mob/living/basic/slime/proc/start_stack_cooldown()
	COOLDOWN_START(src, stack_cooldown, rand(1 MINUTES, 2 MINUTES))

/// How high off the floor we sit, going by everyone under us.
/mob/living/basic/slime/proc/stack_pixel_z()
	. = 0
	for(var/mob/living/basic/slime/below = buckled; isslime(below); below = below.buckled)
		. += below.life_stage == SLIME_LIFE_STAGE_ADULT ? SLIME_STACK_PIXEL_Z_ADULT : SLIME_STACK_PIXEL_Z_BABY

/// Everyone riding us falls off, and everyone riding them, all the way up.
/mob/living/basic/slime/proc/dump_riders()
	for(var/mob/living/basic/slime/rider in buckled_mobs)
		var/fall_height = rider.pixel_z - rider.base_pixel_z
		// unbuckle first - a rider that moves while still buckled drags us along with it
		unbuckle_mob(rider, force = TRUE)
		rider.tumble_off_stack(fall_height)

/// The floor got pulled out from under us. Wheee- *splat*
/mob/living/basic/slime/proc/tumble_off_stack(fall_height)
	// the pen fence lets pulled things through on purpose, so a pulled slime just drops straight down
	if(isturf(loc) && !pulledby)
		var/tumble_dir = pick(GLOB.alldirs)
		var/turf/landing = get_step(src, tumble_dir)
		if(landing?.can_cross_safely(src))
			Move(landing, tumble_dir)

	// higher up = longer fall, so a tower lands one slime after another
	var/fall_time = 0.2 SECONDS + fall_height * 0.02 SECONDS
	var/floor_z = pixel_z
	var/matrix/base = matrix(transform)
	var/matrix/splatted = matrix(transform)
	splatted.Scale(1.3, 0.6)
	pixel_z = floor_z + fall_height
	SpinAnimation(speed = fall_time, loops = 1, clockwise = prob(50))
	animate(src, pixel_z = floor_z, time = fall_time, easing = EASE_IN, flags = ANIMATION_PARALLEL)
	animate(transform = splatted, time = 0.1 SECONDS, easing = EASE_OUT)
	animate(pixel_z = floor_z + 4, transform = base, time = 0.12 SECONDS, easing = EASE_OUT)
	animate(pixel_z = floor_z, time = 0.12 SECONDS, easing = EASE_IN)

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/misc/moist_impact.ogg', 30, TRUE), fall_time)
	Immobilize(fall_time + 1.5 SECONDS, ignore_canstun = TRUE) // sits there dazed for a bit
	set_temporary_mood(SLIME_MOOD_POUT)

/mob/living/basic/slime/set_buckled(new_buckled)
	var/atom/movable/old_seat = buckled
	. = ..()
	if(buckled == old_seat)
		return
	if(isslime(old_seat))
		start_stack_cooldown()
		// not animated, tumble_off_stack() does its own fall
		remove_offsets(SLIME_STACK_OFFSET, animate = FALSE)
		layer = initial(layer)
	if(isslime(buckled))
		add_offsets(SLIME_STACK_OFFSET, z_add = stack_pixel_z(), animate = FALSE)
		// same tile and same layer as our seat otherwise, and then who gets drawn on top is anyone's guess
		layer = buckled.layer + 0.01
	// whatever we just did, we moved out from under anyone sitting on us
	dump_riders()

/mob/living/basic/slime/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	// riders only follow a seat that walks. one that gets teleported, picked up or vacuumed leaves them behind, still buckled
	if(isslime(buckled) && buckled.loc != loc)
		hop_off_stack()
	if(forced || !isturf(loc))
		dump_riders()

/mob/living/basic/slime/set_life_stage(new_life_stage = SLIME_LIFE_STAGE_BABY, initial = FALSE)
	// how high they sit depends on our size, and so does who's allowed up there at all
	dump_riders()
	return ..()

/datum/targeting_strategy/slime_stack_seat

/datum/targeting_strategy/slime_stack_seat/is_valid_target(mob/living/basic/slime/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	return living_mob.can_stack_onto(target)

/datum/bt_node/decorator/slime_wants_to_stack

/datum/bt_node/decorator/slime_wants_to_stack/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn) || (slime_pawn.cleaner_slime && slime_pawn.sees_mess_to_clean()))
		return FALSE
	return isslime(slime_pawn.buckled) || slime_pawn.wants_to_stack()

/// Hops on, and then just sits there. This staying running is what keeps us on the tower,
/// so anything higher up the tree butting in drops it, and finish_action() gets us off.
/datum/bt_node/ai_behavior/sit_on_slime
	time_between_perform = 1 SECONDS

/datum/bt_node/ai_behavior/sit_on_slime/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/mob/living/basic/slime/seat = controller.blackboard[BB_SLIME_STACK_TARGET]
	if(!istype(slime_pawn) || QDELETED(seat) || !slime_pawn.can_stack_onto(seat))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(slime_pawn.buckled == seat)
		// one roll per perform, and we perform once a second
		if(prob(SLIME_STACK_HOP_OFF_CHANCE))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
		return AI_BEHAVIOR_DELAY
	if(!slime_pawn.Adjacent(seat) || !slime_pawn.stack_onto(seat))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/sit_on_slime/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	slime_pawn?.hop_off_stack()
	controller.clear_blackboard_key(BB_SLIME_STACK_TARGET)

#undef SLIME_STACK_OFFSET
#undef SLIME_STACK_HOP_OFF_CHANCE
#undef SLIME_STACK_PIXEL_Z_BABY
#undef SLIME_STACK_PIXEL_Z_ADULT
#undef SLIME_MAX_STACK_HEIGHT

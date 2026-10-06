// Slime rancher AI controller blackboard keys

///Item a slime is currently walking towards to eat
#define BB_SLIME_ITEM_TARGET "BB_slime_item_target"
///Typecache of item types the slime still wants to eat
#define BB_SLIME_WANTED_ITEMS "BB_slime_wanted_items"
///Typecache of mob types the slime can latch onto and drain for a mutation
#define BB_SLIME_WANTED_MOBS "BB_slime_wanted_mobs"
///Friend a slime is currently waddling over to go nuzzle
#define BB_SLIME_NUZZLE_TARGET "BB_slime_nuzzle_target"
///Emotes a monkey uses for its battle screech instead of the hardcoded roar/screech, if set
#define BB_MONKEY_BATTLE_SCREECHES "BB_monkey_battle_screeches"

/// The cat face. Core only defines the faces its own AI used, and this one's cuter.
#define SLIME_MOOD_CAT ":33"

/// From /mob/living/basic/slime/proc/eat_wanted_item(): (obj/item/meal)
/// Return COMPONENT_SLIME_WANTS_ITEM if this meal is worth something to you.
#define COMSIG_SLIME_CHECK_WANTED_ITEM "slime_check_wanted_item"
	#define COMPONENT_SLIME_WANTS_ITEM (1<<0)
/// From /mob/living/basic/slime/proc/eat_wanted_item(), after the item is gone: (meal_type)
#define COMSIG_SLIME_ATE_ITEM "slime_ate_item"
/// From /mob/living/basic/slime/proc/set_mood(): (old_mood, new_mood)
#define COMSIG_SLIME_UPDATE_MOOD "slime_update_mood"
/// From /datum/status_effect/slime_leech/tick(): (mob/living/meal, drained)
#define COMSIG_SLIME_LATCH_DRAINED "slime_latch_drained"

/// From /obj/item/vacuum_pack/proc/store(): (mob/living/stored_mob)
#define COMSIG_VACUUM_STORED "vacuum_stored"
/// From /obj/item/vacuum_pack/Exited(): (mob/living/released_mob)
#define COMSIG_VACUUM_RELEASED "vacuum_released"

#define VACUUM_CAN_PACIFY (1<<0)
#define VACUUM_CAN_PRINT (1<<1)

// these control how long slimes jiggle when splitting or mutating
#define SLIME_SPLIT_WINDUP (5 SECONDS)
#define SLIME_MUTATE_WINDUP (8 SECONDS)

/// Health an adult slime has to drain to secrete one extract (or roll a mutation)
#define SLIME_RANCH_EXTRACT_COST 50
/// Health a slime told to split by a friend has to drain first
#define SLIME_RANCH_COMMAND_SPLIT_COST 50
/// Health a slime that ate a breeding pellet has to drain first
#define SLIME_RANCH_PELLET_SPLIT_COST 100
/// How long a refused or interrupted split/mutation waits before trying again
#define SLIME_RANCH_RETRY_COOLDOWN (5 SECONDS)
/// How long a slime ignores a target it couldn't path to
#define SLIME_CHASE_GIVE_UP_TIME (5 SECONDS)

/// The fence sprite's own blue. A pen set to this color skips the recolor filter entirely, so the default look is the sprite as drawn.
#define SLIME_PEN_DEFAULT_COLOR "#4dc8e8"
/// Chance a monkey fights back when a ranched slime hits it. Base monkeys use MONKEY_RETALIATE_PROB (85).
#define PENNED_MONKEY_RETALIATE_PROB 40
/// How far away other slimes notice a monkey attacking a slime and join in.
#define SLIME_MONKEY_RALLY_RANGE 5

#define EVLOG_CATEGORY_SLIMES "Slimes"

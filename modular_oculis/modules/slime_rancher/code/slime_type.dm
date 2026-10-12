/// Lazylist of slime types that have been mutated so far
GLOBAL_LIST(obtained_slime_types)
/// Lazylist of xenofauna the ranch can print, filled in as slimes that want to eat them show up
GLOBAL_LIST(unlocked_xenofauna)

/datum/slime_type
	/// List of `/datum/slime_mutation`s this slime type is eligible for.
	/// Use this instead of the `mutations` list, because modularity or whatever.
	var/list/possible_mutations

/datum/slime_type/New()
	. = ..()
	// slimes with no further mutations can mutate into rainbow
	if(isnull(possible_mutations))
		possible_mutations = list(/datum/slime_mutation/rainbow)

/datum/slime_type/grey
	possible_mutations = list(
		/datum/slime_mutation/metal,
		/datum/slime_mutation/orange,
		/datum/slime_mutation/purple,
		/datum/slime_mutation/blue,
	)

/datum/slime_type/blue
	possible_mutations = list(
		/datum/slime_mutation/silver,
		/datum/slime_mutation/darkblue,
		/datum/slime_mutation/pink,
	)

/datum/slime_type/darkblue
	possible_mutations = list(
		/datum/slime_mutation/blue,
		/datum/slime_mutation/purple,
		/datum/slime_mutation/cerulean,
	)

/datum/slime_type/green
	possible_mutations = list(
		/datum/slime_mutation/black,
	)

/datum/slime_type/metal
	possible_mutations = list(
		/datum/slime_mutation/silver,
		/datum/slime_mutation/yellow,
		/datum/slime_mutation/gold,
	)

/datum/slime_type/purple
	possible_mutations = list(
		/datum/slime_mutation/green,
		/datum/slime_mutation/darkblue,
		/datum/slime_mutation/darkpurple,
	)

/datum/slime_type/orange
	possible_mutations = list(
		/datum/slime_mutation/darkpurple,
		/datum/slime_mutation/yellow,
		/datum/slime_mutation/red,
	)

/datum/slime_type/pink
	possible_mutations = list(
		/datum/slime_mutation/lightpink,
	)

/datum/slime_type/darkpurple
	possible_mutations = list(
		/datum/slime_mutation/sepia,
		/datum/slime_mutation/purple,
		/datum/slime_mutation/orange,
	)

/datum/slime_type/red
	possible_mutations = list(
		/datum/slime_mutation/oil,
	)

/datum/slime_type/yellow
	possible_mutations = list(
		/datum/slime_mutation/bluespace,
		/datum/slime_mutation/metal,
		/datum/slime_mutation/orange,
	)

/datum/slime_type/gold
	possible_mutations = list(
		/datum/slime_mutation/adamantine,
	)

/datum/slime_type/silver
	possible_mutations = list(
		/datum/slime_mutation/pyrite,
		/datum/slime_mutation/metal,
		/datum/slime_mutation/blue,
	)

/datum/slime_type/black
	possible_mutations = list(
		/datum/slime_mutation/darkgrey,
		/datum/slime_mutation/rainbow,
	)

/datum/slime_type/rainbow
	possible_mutations = list()

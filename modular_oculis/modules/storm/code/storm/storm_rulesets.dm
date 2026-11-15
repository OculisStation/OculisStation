#define STORM_INTENSITY_NONE 0
#define STORM_INTENSITY_CALM 1
#define STORM_INTENSITY_DRIZZLE 2
#define STORM_INTENSITY_HURRICANE 3
#define STORM_INTENSITY_MONSOON 4
#define STORM_INTENSITY_ADMIN 5

/datum/storm_ruleset
	/// Name of the storm ruleset. Mainly used for admin logs.
	var/name = "None"
	/// Which storm intensity this ruleset belongs to. See defines for values.
	var/intensity = STORM_INTENSITY_NONE
	/// Minimum population required for this ruleset to be selected at roundstart.
	var/min_pop = 0
	/// How much time it takes between each storm cooldown.
	var/storm_cooldown = 10 MINUTES

/datum/storm_ruleset/calm
	name = "Calm"
	intensity = STORM_INTENSITY_CALM
	min_pop = 0
	storm_cooldown = 15 MINUTES

/datum/storm_ruleset/drizzle
	name = "Drizzle"
	intensity = STORM_INTENSITY_DRIZZLE
	min_pop = 10
	storm_cooldown = 10 MINUTES

/datum/storm_ruleset/hurricane
	name = "Hurricane"
	intensity = STORM_INTENSITY_HURRICANE
	min_pop = 15
	storm_cooldown = 5 MINUTES

/datum/storm_ruleset/monsoon
	name = "Monsoon"
	intensity = STORM_INTENSITY_MONSOON
	min_pop = 25
	storm_cooldown = 2 MINUTES

#undef STORM_INTENSITY_NONE
#undef STORM_INTENSITY_CALM
#undef STORM_INTENSITY_DRIZZLE
#undef STORM_INTENSITY_HURRICANE
#undef STORM_INTENSITY_MONSOON
#undef STORM_INTENSITY_ADMIN

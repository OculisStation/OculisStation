#define STORM_INTENSITY_NONE 0
#define STORM_INTENSITY_CALM 1
#define STORM_INTENSITY_DRIZZLE 2
#define STORM_INTENSITY_STORM 3
#define STORM_INTENSITY_MONSOON 4
#define STORM_INTENSITY_ADMIN 5

/datum/storm_ruleset
	/// Which storm intensity this ruleset belongs to. See defines for values.
	var/intensity = STORM_INTENSITY_NONE
	/// Minimum population required for this ruleset to be selected at roundstart.
	var/min_pop = 0
	/// How much time it takes between each storm cooldown.
	var/storm_cooldown = 10 MINUTES

/datum/storm_ruleset/calm
	intensity = STORM_INTENSITY_CALM
	min_pop = 0
	storm_cooldown = 10 MINUTES

/datum/storm_ruleset/drizzle
	intensity = STORM_INTENSITY_DRIZZLE
	min_pop = 10
	storm_cooldown = 10 MINUTES

/datum/storm_ruleset/storm
	intensity = STORM_INTENSITY_STORM
	min_pop = 15
	storm_cooldown = 5 MINUTES

/datum/storm_ruleset/monsoon
	intensity = STORM_INTENSITY_MONSOON
	min_pop = 25
	storm_cooldown = 5 MINUTES

/datum/storm_ruleset/admin
	intensity = STORM_INTENSITY_ADMIN
	min_pop = 999
	storm_cooldown = 10 MINUTES

#undef STORM_INTENSITY_NONE
#undef STORM_INTENSITY_CALM
#undef STORM_INTENSITY_DRIZZLE
#undef STORM_INTENSITY_STORM
#undef STORM_INTENSITY_MONSOON
#undef STORM_INTENSITY_ADMIN

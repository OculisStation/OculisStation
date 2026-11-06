/mob/living/basic
	/// Biomass credited when this creature is recycled. Positive values also allow vacuum capture and printing.
	var/biomass_value = 0

	/// Scales how much a slime gets out of draining this creature. Over 1 is a fatter meal.
	var/slime_meal_multiplier = 1

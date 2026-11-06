/datum/techweb
	var/maxcap_reward_gained = FALSE

/obj/machinery/doppler_array
	/// Reference to the techweb.
	var/datum/techweb/stored_research

/obj/machinery/doppler_array/Destroy()
	. = ..()
	if(stored_research)
		stored_research = null

/obj/machinery/doppler_array/proc/bonus_explosion_points()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)
	if(stored_research && stored_research.maxcap_reward_gained == FALSE)
		stored_research.adjust_points(TECHWEB_POINT_TYPE_GENERIC, TECHWEB_POINTS_1_HOUR)
		stored_research.maxcap_reward_gained = TRUE
		return TRUE
	return FALSE

/datum/can_pass_info
	var/slime_pen_contained = FALSE

/datum/can_pass_info/New(atom/movable/construct_from, list/access, no_id = FALSE, call_depth = 0, multiz_checks = FALSE)
	. = ..()
	if(construct_from)
		slime_pen_contained = is_slime_pen_contained(construct_from)

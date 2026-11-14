#define MAX_NAVIGATE_RANGE 145

/mob/living/proc/create_astar_navigation()
	var/list/destination_list = list()
	for(var/atom/destination as anything in GLOB.navigate_destinations)
		if(get_dist(destination, src) > MAX_NAVIGATE_RANGE || !are_zs_connected(destination, src)) // monkestation edit: check to ensure that Z-levels are connected, so we don't get centcom destinations while on station and vice-versa
			continue
		var/destination_name = GLOB.navigate_destinations[destination]
		if(destination.z != z && is_multi_z_level(z)) // up or down is just a good indicator "we're on the station", we don't need to check specifics
			destination_name += ((get_dir_multiz(src, destination) & UP) ? " (Above)" : " (Below)")

		BINARY_INSERT_DEFINE(destination_name, destination_list, SORT_VAR_NO_TYPE, destination_name, SORT_COMPARE_DIRECTLY, COMPARE_KEY)
		destination_list[destination_name] = destination

	if(!length(destination_list))
		balloon_alert(src, "no navigation signals!")
		return

	var/platform_code = tgui_input_list(src, "Select a location", "Navigate", destination_list)
	var/atom/navigate_target = destination_list[platform_code]

	if(isnull(navigate_target) || incapacitated)
		return

	if(!isatom(navigate_target))
		CRASH("Navigate target ([navigate_target]) is not an atom, somehow.")

	navigating = TRUE
	var/datum/callback/await = list(CALLBACK(src, PROC_REF(finish_astar_navigation), navigate_target))
	if(!SSpathfinder.astar_pathfind(src, navigate_target, max_distance = MAX_NAVIGATE_RANGE, mintargetdist = 1, access = get_access(), smooth_diagonals = FALSE, on_finish = await)) // diagonals look kind of weird when visualized for now
		navigating = FALSE
		balloon_alert(src, "failed to begin navigation!")

/mob/living/proc/finish_astar_navigation(turf/navigate_target, list/path)
	navigating = FALSE
	if(!client)
		return
	if(!length(path))
		balloon_alert(src, "no valid path with current access!")
		return
	path |= get_turf(navigate_target)
	for(var/i in 1 to length(path))
		var/turf/current_turf = path[i]
		var/image/path_image = image(icon = 'icons/effects/navigation.dmi', layer = HIGH_PIPE_LAYER, loc = current_turf)
		SET_PLANE(path_image, GAME_PLANE, current_turf)
		path_image.color = COLOR_CYAN
		path_image.alpha = 0
		var/dir_1 = 0
		var/dir_2 = 0
		if(i == 1)
			dir_2 = angle2dir(get_angle(path[i+1], current_turf))
			dir_2 = REVERSE_DIR(dir_2) // if we combined this with the above, we'd do angle2dir/get_angle twice, which is not ideal
		else if(i == length(path))
			dir_2 = angle2dir(get_angle(path[i-1], current_turf))
			dir_2 = REVERSE_DIR(dir_2)
		else
			dir_1 = angle2dir(get_angle(path[i+1], current_turf))
			dir_2 = angle2dir(get_angle(path[i-1], current_turf))
			dir_1 = REVERSE_DIR(dir_1)
			dir_2 = REVERSE_DIR(dir_2)
			if(dir_1 > dir_2)
				dir_1 = dir_2
				dir_2 = angle2dir(get_angle(path[i+1], current_turf))
				dir_2 = REVERSE_DIR(dir_2)
		path_image.icon_state = "[dir_1]-[dir_2]"
		client.images += path_image
		client.navigation_images += path_image
		animate(path_image, 0.5 SECONDS, alpha = 150)

	addtimer(CALLBACK(src, PROC_REF(shine_navigation)), 0.5 SECONDS)
	RegisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(cut_navigation))
	balloon_alert(src, "navigation path created")

#undef MAX_NAVIGATE_RANGE

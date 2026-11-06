/atom/movable/screen/parallax_layer/random/space_gas/storm
	parallax_color = list(1,0,0,0, 0,0,0,0, 0,0,2,0, 0,0,0,1, 0,0,0,0) //very vibrant purple

/atom/movable/screen/parallax_layer/random/space_gas/storm/apply_global_effects()
	. = ..()
	set_base_starlight("#911855")

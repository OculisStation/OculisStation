/obj/item/slime_extract
	/// so slimes won't eat extracts that haven't been picked up first
	var/fresh_from_slime = FALSE

/obj/item/slime_extract/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(fresh_from_slime && !isturf(loc) && !ismonkey(loc))
		fresh_from_slime = FALSE

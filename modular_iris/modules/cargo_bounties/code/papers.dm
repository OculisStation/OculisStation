/obj/item/paper/bounty_printout
	name = "paper - Bounties"

/obj/item/paper/bounty_printout/Initialize(mapload, list/cargo_bounties)
	. = ..()
	add_raw_text("<h2>Nanotrasen Cargo Bounties</h2><br>")
	for(var/datum/bounty/B as anything in cargo_bounties)
		if(B.claimed)
			continue
		var/bounty_string = "<h3>[B.name]</h3><br>"
		bounty_string = "[bounty_string]<ul><li>Reward: [B.get_bounty_reward()] Credits</li><br>"
		bounty_string = "[bounty_string]<li>Completed: [B.get_completion_string()]</li></ul>"
		add_raw_text(bounty_string)

	update_icon_state()

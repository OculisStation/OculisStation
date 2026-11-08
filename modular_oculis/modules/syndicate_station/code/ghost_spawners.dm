/obj/effect/mob_spawn/ghost_role/human/octavia
	name = "Octavia personnel"
	use_outfit_name = TRUE
	prompt_name = "Octavia personnel"
	you_are_text = "You are a Syndicate operative, employed in a top secret syndicate space station."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has begun operations in this sector. Continue operating as best you can, and try to keep a low profile."
	quirks_enabled = TRUE
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE
	computer_area = /area/ruin/space/has_grav/nova/des_two/service/dorms
	spawner_job_path = /datum/job/octavia

/obj/effect/mob_spawn/ghost_role/human/octavia/prisoner
	name = "Syndicate Prisoner"
	prompt_name = "a Syndicate prisoner"
	you_are_text = "You are a Syndicate prisoner aboard an unknown ship."
	flavour_text = "Unaware of where you are, all you know is you are a prisoner. The plastitanium should clue you into who your captors are... as for why you're here? That's for you to know, and for us to find out."
	important_text = "You are still subject to standard prisoner policy and must Adminhelp before antagonizing Octavia."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	computer_area = /area/ruin/space/has_grav/nova/des_two/security/prison
	outfit = /datum/outfit/octavia/prisoner
	spawner_job_path = /datum/job/octavia/prisoner
	loadout_enabled = TRUE
	allow_mechanical_loadout_items = FALSE

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate
	name = "Syndicate Operative"
	prompt_name = "a Syndicate operative"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	you_are_text = "You are a Syndicate operative, employed onboard the Deep Space 2 FOB for reasons that are yours."
	flavour_text = "The Syndicate has found it fit to send a forward operating base to Sector 13 to monitor NT's operations. Your orders are maintaining the ship's integrity and keeping a low profile as well as possible."
	important_text = "You are not an antagonist. Adminhelp before antagonizing station crew."
	outfit = /datum/outfit/octavia/syndicate
	computer_area = /area/ruin/space/has_grav/nova/des_two/halls
	spawner_job_path = /datum/job/octavia
	loadout_enabled = TRUE
	allow_mechanical_loadout_items = TRUE

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate_command
	name = "Syndicate Command Operative"
	prompt_name = "a Syndicate leader"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	you_are_text = "You are a Syndicate command operative, employed onboard the Deep Space 2 FOB to guide it forward in its goals."
	flavour_text = "The Syndicate has found it fit to send you to help command the forward operating base in Sector 13. Your orders are commanding the crew of DS-2 while keeping a low profile as well as possible."
	important_text = "Keep yourself to the same standards as Command Policy. You are not an antagonist and must Adminhelp before antagonizing station crew."
	outfit = /datum/outfit/octavia/syndicate_command
	computer_area = /area/ruin/space/has_grav/nova/des_two/halls
	spawner_job_path = /datum/job/octavia/command
	loadout_enabled = TRUE
	allow_mechanical_loadout_items = TRUE

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.grant_language(/datum/language/codespeak, source = LANGUAGE_SPAWNER)

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate_command/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.grant_language(/datum/language/codespeak, source = LANGUAGE_SPAWNER)

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate/service
	outfit = /datum/outfit/octavia/syndicate/service

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate/miner
	outfit = /datum/outfit/octavia/syndicate/miner

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate/enginetech
	outfit = /datum/outfit/octavia/syndicate/enginetech
	spawner_job_path = /datum/job/octavia/engineer

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate/researcher
	outfit = /datum/outfit/octavia/syndicate/researcher
	spawner_job_path = /datum/job/octavia/science

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate/stationmed
	outfit = /datum/outfit/octavia/syndicate/stationmed

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate/brigoff
	outfit = /datum/outfit/octavia/syndicate/brigoff
	spawner_job_path = /datum/job/octavia/enforce

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate_command/masteratarms
	outfit = /datum/outfit/octavia/syndicate_command/masteratarms

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate_command/corporateliaison
	outfit = /datum/outfit/octavia/syndicate_command/corporateliaison

/obj/effect/mob_spawn/ghost_role/human/octavia/syndicate_command/admiral
	outfit = /datum/outfit/octavia/syndicate_command/admiral

/obj/effect/mob_spawn/ghost_role/robot/octavia
	name = "\improper Syndicate Robotic Storage"
	desc = "A suspicious specialized container marked 'cyborg storage'."
	prompt_name = "a syndicate deepspace robot"
	deletes_on_zero_uses_left = TRUE
	icon = 'modular_nova/modules/ghostcafe/icons/robot_storage.dmi'
	icon_state = "syndi_robostor"
	anchored = TRUE
	density = TRUE
	uses = 1
	you_are_text = "You are an Octavia Cyborg!"
	flavour_text = "You are a cyborg on a ship in deep space... what kind of hell is this?"
	important_text = "Keep yourself to the same standards as Silicon Policy. You are not an antagonist. Adminhelp before antagonizing station crew."
	loadout_enabled = TRUE
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE
	spawner_job_path = /datum/job/octavia
	mob_type = /mob/living/silicon/robot/model/octavia

/obj/effect/mob_spawn/ghost_role/robot/octavia/special(mob/living/silicon/robot/spawned_robot, mob/mob_possessor, apply_prefs)
	. = ..()
	if(spawned_robot.client)
		spawned_robot.custom_name = null
		spawned_robot.updatename(spawned_robot.client)
		spawned_robot.transfer_silicon_prefs(spawned_robot.client)
		spawned_robot.set_gender(spawned_robot.client)

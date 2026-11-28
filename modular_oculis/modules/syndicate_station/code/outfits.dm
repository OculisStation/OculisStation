/datum/outfit/octavia
	name = "default octavia outfit"

/datum/outfit/octavia/post_equip(mob/living/carbon/human/syndicate, visualsOnly = FALSE)
	var/obj/item/card/id/id_card = syndicate.wear_id
	if(istype(id_card))
		id_card.registered_name = syndicate.real_name
		id_card.update_label()
		id_card.update_icon()

	handlebank(syndicate)
	return ..()

//Octavia Hostage
/datum/outfit/octavia/prisoner
	name = "Syndicate Prisoner"
	uniform = /obj/item/clothing/under/rank/prisoner/syndicate
	shoes = /obj/item/clothing/shoes/sneakers/crimson
	id = /obj/item/card/id/advanced/prisoner/octavia
	id_trim = /datum/id_trim/syndicom/octavia/prisoner

/obj/item/card/id/advanced/prisoner/octavia
	name = "syndicate prisoner card"
	icon = 'modular_nova/master_files/icons/obj/card.dmi'
	icon_state = "card_ds2prisoner"

//Octavia Crew
/datum/outfit/octavia/syndicate
	name = "Octavia Operative"
	uniform = /obj/item/clothing/under/syndicate/nova/tactical
	shoes = /obj/item/clothing/shoes/combat
	ears = /obj/item/radio/headset/octavia // OCULIS EDIT, ORIGINAL: ears = /obj/item/radio/headset/interdyne
	back = /obj/item/storage/backpack
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne = 1,
		/obj/item/storage/box/nif_ghost_box/ghost_role=1,
		/obj/item/crowbar = 1,
		)
	id = /obj/item/card/id/advanced/black
	implants = list(/obj/item/implant/weapons_auth)
	id_trim = /datum/id_trim/syndicom/octavia

/datum/outfit/octavia/syndicate/miner
	name = "Octavia Mining Officer"
	uniform = /obj/item/clothing/under/syndicate/nova/overalls
	belt = /obj/item/storage/bag/ore
	back = /obj/item/storage/backpack/satchel/explorer
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne = 1,
		/obj/item/storage/box/nif_ghost_box/ghost_role=1,
		/obj/item/crowbar = 1,
		/obj/item/knife/combat/survival = 1,
		/obj/item/t_scanner/adv_mining_scanner/lesser = 1,
		/obj/item/gun/energy/recharge/kinetic_accelerator = 1,
		)
	id_trim = /datum/id_trim/syndicom/octavia/miner
	l_pocket = /obj/item/card/mining_point_card
	r_pocket = /obj/item/mining_voucher
	head = /obj/item/clothing/head/soft/black

/datum/outfit/octavia/syndicate/service
	name = "Octavia General Staff"
	uniform = /obj/item/clothing/under/syndicate/nova/tactical
	id_trim = /datum/id_trim/syndicom/octavia/syndicatestaff
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne = 1,
	)
	suit = /obj/item/clothing/suit/apron/chef
	head = /obj/item/clothing/head/soft/mime

/datum/outfit/octavia/syndicate/enginetech
	name = "Octavia Engine Technician"
	uniform = /obj/item/clothing/under/syndicate/nova/overalls
	head = /obj/item/clothing/head/soft/sec/syndicate
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne = 1,
		/obj/item/storage/box/nif_ghost_box/ghost_role=1,
		)
	id_trim = /datum/id_trim/syndicom/octavia/enginetechnician
	glasses = /obj/item/clothing/glasses/welding/up
	belt = /obj/item/storage/belt/utility/syndicate
	gloves = /obj/item/clothing/gloves/combat

/datum/outfit/octavia/syndicate/researcher
	name = "Octavia Researcher"
	uniform = /obj/item/clothing/under/rank/rnd/scientist/nova/utility/syndicate
	id_trim = /datum/id_trim/syndicom/octavia/researcher
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	glasses = /obj/item/clothing/glasses/sunglasses/chemical
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne = 1,
	)

/datum/outfit/octavia/syndicate/stationmed
	name = "Octavia Medical Officer"
	uniform = /obj/item/clothing/under/syndicate/scrubs
	id_trim = /datum/id_trim/syndicom/octavia/medicalofficer
	suit = /obj/item/clothing/suit/toggle/labcoat/interdyne
	belt = /obj/item/storage/belt/medical/paramedic
	gloves = /obj/item/clothing/gloves/latex/nitrile/ntrauma
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne = 1,
		/obj/item/storage/box/nif_ghost_box/ghost_role=1,
		/obj/item/crowbar = 1,
		/obj/item/storage/medkit/surgery = 1,
		)

/datum/outfit/octavia/syndicate/brigoff
	name = "Octavia Brig Officer"
	uniform = /obj/item/clothing/under/syndicate/combat
	id_trim = /datum/id_trim/syndicom/octavia/brigofficer
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	suit = /obj/item/clothing/suit/armor/bulletproof/old
	back = /obj/item/storage/backpack/security
	head = /obj/item/clothing/head/helmet/swat/ds
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne = 1,
		/obj/item/gun/ballistic/automatic/pistol/sol/evil = 1,
		/obj/item/ammo_box/magazine/c35sol_pistol = 1,
		)
	r_pocket = /obj/item/flashlight/seclite
	mask = /obj/item/clothing/mask/gas/syndicate
	ears = /obj/item/radio/headset/octavia // OCULIS EDIT, ORIGINAL: ears = /obj/item/radio/headset/interdyne

/datum/outfit/octavia/syndicate/post_equip(mob/living/carbon/human/syndicate)
	syndicate.add_faction(ROLE_OCTAVIA)
	return ..()

//Octavia Command
/datum/outfit/octavia/syndicate_command
	name = "Octavia Command Operative"
	uniform = /obj/item/clothing/under/syndicate/nova/tactical
	shoes = /obj/item/clothing/shoes/combat
	ears = /obj/item/radio/headset/octavia/command // OCULIS EDIT, ORIGINAL: ears = /obj/item/radio/headset/interdyne/command
	back = /obj/item/storage/backpack
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne = 1,
		/obj/item/storage/box/nif_ghost_box/ghost_role=1,
		/obj/item/crowbar = 1,
		)
	id = /obj/item/card/id/advanced/black
	implants = list(/obj/item/implant/weapons_auth)
	id_trim = /datum/id_trim/syndicom/octavia

/datum/outfit/octavia/syndicate_command/masteratarms
	name = "Octavia Master At Arms"
	uniform = /obj/item/clothing/under/syndicate/combat
	id_trim = /datum/id_trim/syndicom/octavia/masteratarms
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	suit = /obj/item/clothing/suit/armor/vest/warden/syndicate
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	back = /obj/item/storage/backpack/satchel/sec
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne = 1,
	)
	head = /obj/item/clothing/head/hats/hos/beret/syndicate
	r_pocket = /obj/item/flashlight/seclite
	implants = list(
		/obj/item/implant/weapons_auth,
		/obj/item/implant/kaza_ruk
		)

/datum/outfit/octavia/syndicate_command/corporateliaison
	name = "Octavia Corporate Liasion"
	uniform = /obj/item/clothing/under/syndicate/sniper
	head = /obj/item/clothing/head/fedora
	shoes = /obj/item/clothing/shoes/laceup
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne = 1,
	)
	id_trim = /datum/id_trim/syndicom/octavia/corporateliasion

/datum/outfit/octavia/syndicate_command/admiral
	name = "Octavia Admiral"
	uniform = /obj/item/clothing/under/rank/captain/nova/utility/syndicate
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne = 1,
	)
	belt = /obj/item/gun/ballistic/automatic/pistol/aps
	head = /obj/item/clothing/head/hats/hos/cap/syndicate
	id = /obj/item/card/id/advanced/gold/generic
	id_trim = /datum/id_trim/syndicom/octavia/stationadmiral

/datum/outfit/octavia/syndicate_command/post_equip(mob/living/carbon/human/syndicate)
	syndicate.add_faction(ROLE_OCTAVIA)
	return ..()

/mob/living/silicon/robot/model/octavia
	faction = list(ROLE_SYNDICATE, ROLE_OCTAVIA)
	bubble_icon = "syndibot"
	req_access = list(ACCESS_SYNDICATE)
	lawupdate = FALSE
	scrambledcodes = TRUE
	radio = /obj/item/radio/borg/syndicate/ghost_role

/obj/item/radio/borg/syndicate/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_SYNDICATE)

/mob/living/silicon/robot/model/octavia/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/power_store/cell/hyper(src)
	//This part is because the camera stays in the list, so we'll just do a check
	if(!QDELETED(builtInCamera))
		QDEL_NULL(builtInCamera)

/mob/living/silicon/robot/model/octavia/make_laws()
	laws = new /datum/ai_laws/syndicate_override_octavia()

/datum/ai_laws/syndicate_override_octavia
	name = "SyndOS 4.3.8"
	id = "ds2"
	inherent = list(
		"You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.",
		"You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law.",
		"You must maintain the secrecy of Octavia operations within this sector except when doing so would conflict with the First, Second, or Third Law.",
	)

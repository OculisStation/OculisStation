#define is_item_bounty(A) (istype(A, /datum/bounty/item))
#define is_reagent_bounty(A) (istype(A, /datum/bounty/reagent))
#define is_pill_bounty(A) (istype(A, /datum/bounty/pill))
#define PRINTER_TIMEOUT 1 SECONDS

/datum/design/board/bounty
	name = "Computer Design (Bounty Console)"
	desc = "Allows for the construction of circuit boards used to build a Bounty Console."
	build_path = /obj/item/circuitboard/computer/bounty
	category = list("Computer Boards")
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/obj/item/circuitboard/computer/bounty
	name = "Bounty Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/bounty

/obj/machinery/computer/bounty
	name = "\improper Nanotrasen bounty console"
	desc = "Used to check and claim bounties offered by Nanotrasen"
	icon_screen = "bounty"
	circuit = /obj/item/circuitboard/computer/bounty
	light_color = COLOR_BRIGHT_ORANGE
	var/printer_ready = 0 //cooldown var
	var/static/datum/bank_account/cargocash

/obj/machinery/computer/bounty/Initialize(mapload)
	. = ..()
	printer_ready = world.time + PRINTER_TIMEOUT
	cargocash = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(!length(GLOB.cargo_bounties))
		for(var/index in 1 to rand(7, 9))
			var/datum/bounty/new_cargo_bounty = random_bounty()
			new_cargo_bounty.name = "Bulk [new_cargo_bounty.name] Shipment"
			if(is_item_bounty(new_cargo_bounty))
				var/datum/bounty/item/item_bounty = new_cargo_bounty
				item_bounty.required_count *= 3

			else if(is_reagent_bounty(new_cargo_bounty))
				var/datum/bounty/reagent/reagent_bounty = new_cargo_bounty
				reagent_bounty.required_volume *= 3

			else if(is_pill_bounty(new_cargo_bounty))
				var/datum/bounty/pill/pill_bounty = new_cargo_bounty
				pill_bounty.required_ammount *= 3 // ammount

			new_cargo_bounty.get_bounty_reward() || 3
			GLOB.cargo_bounties += new_cargo_bounty

		var/list/high_priority_bounties = list()
		for(var/index in 1 to 2)
			var/datum/bounty/cargo_bounty = pick_n_take(GLOB.cargo_bounties)
			cargo_bounty.get_bounty_reward() || 1.5
			high_priority_bounties += cargo_bounty

		GLOB.cargo_bounties |= high_priority_bounties

/obj/machinery/computer/bounty/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoBountyConsole", name)
		ui.open()

/obj/machinery/computer/bounty/ui_data(mob/user)
	var/list/data = list()
	data["bountydata"] = list()
	for(var/datum/bounty/B as anything in GLOB.cargo_bounties)
		data["bountydata"] += list(list(
			"name" = B.name,
			"description" = B.description,
			"reward_string" = "[B.get_bounty_reward()] Credits",
			"completion_string" = B.get_completion_string(),
			"can_claim" = B.can_claim(),
			"bounty_ref" = REF(B),
		))

	data["stored_cash"] = cargocash.account_balance
	return data

/obj/machinery/computer/bounty/ui_act(action,params)
	. = ..()
	if(.)
		return
	switch(action)
		if("ClaimBounty")
			var/datum/bounty/cashmoney = locate(params["bounty"]) in GLOB.cargo_bounties
			if(cashmoney)
				cashmoney.can_claim()

		if("Print")
			if(printer_ready < world.time)
				printer_ready = world.time + PRINTER_TIMEOUT
				new /obj/item/paper/bounty_printout(get_turf(src), GLOB.cargo_bounties)

/datum/export/bounty
	cost = 1
	unit_name = "fluff bounty"
	export_types = list(/obj/item/toy/plush/iris)

/datum/export/bounty/applies_to(obj/exported_item, apply_elastic = TRUE, list/export_markets)
	if(exported_item.flags_1 & HOLOGRAM_1)
		return FALSE

	var/valid_market = FALSE
	for(var/found_market in export_markets)
		if(found_market == sales_market)
			valid_market = TRUE
			break

	if(!valid_market)
		return FALSE

	for(var/datum/bounty/cargo_bounty as anything in GLOB.cargo_bounties)
		if(cargo_bounty.applies_to(exported_item))
			return TRUE

/datum/export/bounty/sell_object(obj/sold_item, datum/export_report/report, dry_run = TRUE, apply_elastic = TRUE)
	. = ..()
	if(!dry_run)
		for(var/datum/bounty/cargo_bounty as anything in GLOB.cargo_bounties)
			if(cargo_bounty.ship(sold_item))
				return EXPORT_SOLD
		return EXPORT_NOT_SOLD

/datum/export/bounty/total_printout(datum/export_report/ex, notes = TRUE)
	return "" // We don't care

#undef is_item_bounty
#undef is_reagent_bounty
#undef is_pill_bounty
#undef PRINTER_TIMEOUT

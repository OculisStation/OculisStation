#define EXPRESS_EMAG_DISCOUNT 0.72
#define BEACON_PRINT_COOLDOWN 10 SECONDS

/obj/machinery/computer/cargo/deep_storage
	name = "deep storage supply console"
	desc = "This console allows the user to retrieve a package \
		with 1/80th of the delivery time: made possible by Sectorial's new \"Deep Storage Initiative\".\
		All retrievals are near instantaneous and limited in amount - please choose carefully"
	icon_state = MAP_SWITCH("computer", "/obj/machinery/computer/cargo")
	icon_screen = "supply_express"
	circuit = /obj/item/circuitboard/computer/cargo/express
	req_access = list(ACCESS_CARGO)
	is_express = TRUE
	interface_type = "CargoExpress"

	var/message
	/// The linked supplypod lift
	var/obj/item/supplypod_lift/lift
	/// Where we droppin boys
	var/area/landingzone = /area/station/cargo/storage
	var/pod_type = /obj/structure/closet/supplypod
	/// If this console is locked and needs to be unlocked with an ID
	var/locked = TRUE
	/// Is the console in lift mode? Exists to let lift know when a pod may come in
	var/using_lift = FALSE
	/// Number of lifts printed. Used to determine lift names.
	var/static/printed_lifts = 0
	/// Cooldown to prevent lift spam
	COOLDOWN_DECLARE(lift_print_cooldown)

/obj/machinery/computer/cargo/deep_storage/Initialize(mapload)
	. = ..()
	landingzone = GLOB.areas_by_type[landingzone]
	if (isnull(landingzone))
		WARNING("[src] couldnt find a Quartermaster/Storage (aka cargobay) area on the station, and as such it has set the supplypod landingzone to the area it resides in.")
		landingzone = get_area(src)

/obj/machinery/computer/cargo/deep_storage/Destroy()
	if(lift)
		lift.unlink_console()
	return ..()

/obj/machinery/computer/cargo/deep_storage/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if (tool.GetID() && allowed(user))
		locked = !locked
		to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the interface."))
		return ITEM_INTERACT_SUCCESS

	if (istype(tool, /obj/item/disk/cargo/bluespace_pod))
		if (pod_type == /obj/structure/closet/supplypod/bluespacepod)
			balloon_alert(user, "already upgraded!")
			return ITEM_INTERACT_FAILURE
		if(!user.temporarilyRemoveItemFromInventory(tool))
			return ITEM_INTERACT_FAILURE
		pod_type = /obj/structure/closet/supplypod/bluespacepod // doesnt affect our circuit board, making reversal possible
		to_chat(user, span_notice("You insert the disk into [src], allowing for advanced supply delivery vehicles."))
		tool.forceMove(src)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/supplypod_lift))
		var/obj/item/supplypod_lift/lift = tool
		if (lift.express_console != src)
			lift.link_console(src, user)
			return ITEM_INTERACT_SUCCESS

		to_chat(user, span_alert("[src] is already linked to [lift]."))
		return ITEM_INTERACT_FAILURE

	return NONE

/obj/machinery/computer/cargo/deep_storage/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	if(user)
		if (emag_card)
			user.visible_message(span_warning("[user] swipes [emag_card] through [src]!"))
		to_chat(user, span_notice("You change the routing protocols, allowing the Supply Pod to land anywhere on the station."))
	obj_flags |= EMAGGED
	contraband = TRUE
	// This also sets this on the circuit board
	var/obj/item/circuitboard/computer/cargo/board = circuit
	board.obj_flags |= EMAGGED
	board.contraband = TRUE
	update_static_data_for_all_viewers()
	return TRUE

/obj/machinery/computer/cargo/deep_storage/ui_data(mob/user)
	var/canLift = lift && (isturf(lift.loc) || ismob(lift.loc))//is the lift in a valid location?
	var/list/data = list()
	var/datum/bank_account/account = SSeconomy.get_dep_account(cargo_account)
	if(account)
		data["points"] = account.account_balance
	data["locked"] = locked //swipe an ID to unlock
	data["siliconUser"] = HAS_SILICON_ACCESS(user)
	data["liftzone"] = lift ? get_area(lift) : ""//where is the lift located? outputs in the tgui
	data["liftError"] = using_lift && !canLift ? "(LIFT ERROR)" : ""//changes button text to include an error alert if necessary
	data["hasLift"] = lift != null//is there a linked lift?
	data["liftName"] = lift ? lift.name : "No Lift Found"
	message = "Sales are near-instantaneous - please choose carefully."
	if(using_lift && !lift)
		message = "LIFT ERROR: LIFT MISSING"//lift was destroyed
	if(obj_flags & EMAGGED)
		message = "(&!#@ERROR: R0UTING_#PRO7O&OL MALF(*CT#ON. $UG%ESTE@ ACT#0N: !^/PULS3-%E)ET CIR*)ITB%ARD."
	data["message"] = message
	return data

/obj/machinery/computer/cargo/deep_storage/get_discount()
	return (obj_flags & EMAGGED) ? EXPRESS_EMAG_DISCOUNT : 1

/obj/machinery/computer/cargo/deep_storage/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("LZCargo")
			using_lift = FALSE
			if (lift)
				lift.update_status(SP_UNREADY) //ready light on lift will turn off
		if("LZLift")
			using_lift = TRUE
			if (lift)
				lift.update_status(SP_READY) //turns on the lift's ready light
		if("printLift")
			var/datum/bank_account/account = SSeconomy.get_dep_account(cargo_account)
			if(isnull(account) || !account.adjust_money(-BEACON_COST))
				return

			// a ~ten second cooldown for printing lifts to prevent spam
			COOLDOWN_START(src, lift_print_cooldown, BEACON_PRINT_COOLDOWN)
			var/obj/item/supplypod_lift/new_lift = new /obj/item/supplypod_lift(drop_location())
			new_lift.link_console(src, user) //rather than in lift's Initialize(), we can assign the computer to the lift by reusing this proc)
			printed_lifts++ //printed_lifts starts at 0, so the first one out will be called lift # 1
			lift.name = "Supply Pod Lift #[printed_lifts]"

		if("add")//Generate Supply Order first
			if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_EXPRESSPOD_CONSOLE))
				say("Railgun recalibrating. Stand by.")
				return
			var/id = params["id"]
			id = text2path(id) || id
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]

			if(!istype(pack))
				CRASH("Unknown supply pack id given by express order console ui. ID: [params["id"]]")

			/* NOVA EDIT REMOVAL BEGIN - We use the goody system for imports, so we remove this block in order to let cargo and ghost roles to get imports
			if((pack.order_flags & ORDER_GOODY) && !self_paid && !(obj_flags & EMAGGED))
				playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 50, FALSE)
				say("ERROR: Small crates may only be purchased by private accounts.")
				return
			*/ // NOVA EDIT REMOVAL END

			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = user.ckey
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				name = H.get_authentification_name()
				rank = H.get_assignment(hand_first = TRUE)
			else if(HAS_SILICON_ACCESS(user))
				name = user.real_name
				rank = "Silicon"
			var/reason = ""
			var/datum/supply_order/order = new(pack, name, rank, ckey, reason)
			var/datum/bank_account/account = SSeconomy.get_dep_account(cargo_account)
			if (isnull(account) && order.pack.get_cost() > 0)
				return

			if (obj_flags & EMAGGED)
				landingzone = GLOB.areas_by_type[pick(GLOB.the_station_areas)]


			var/list/empty_turfs
			if (!istype(lift) || !using_lift || (obj_flags & EMAGGED))
				empty_turfs = list()
				for(var/turf/open/floor/open_turf in landingzone.get_turfs_from_all_zlevels())
					if(!open_turf.is_blocked_turf())
						empty_turfs += open_turf

				if (!length(empty_turfs))
					return

			if (obj_flags & EMAGGED)
				if (account.account_balance < order.pack.get_cost() * -get_discount())
					return

				TIMER_COOLDOWN_START(src, COOLDOWN_EXPRESSPOD_CONSOLE, 10 SECONDS)
				order.generateRequisition(get_turf(src))
				for(var/i in 1 to MAX_EMAG_ROCKETS)
					if (!account.adjust_money(order.pack.get_cost() * -get_discount()))
						break

					var/turf/landing_turf = pick(empty_turfs)
					empty_turfs -= landing_turf
					if(pack.special_pod)
						new /obj/effect/pod_landingzone(landing_turf, pack.special_pod, order)
					else
						new /obj/effect/pod_landingzone(landing_turf, pod_type, order)

				update_appearance()
				return TRUE

			var/turf/landing_turf
			if (istype(lift) && using_lift)
				landing_turf = get_turf(lift)
				lift.update_status(SP_LAUNCH)
			else
				landing_turf = pick(empty_turfs)

			if (!account.adjust_money(-order.pack.get_cost() * get_discount()))
				return

			TIMER_COOLDOWN_START(src, COOLDOWN_EXPRESSPOD_CONSOLE, 5 SECONDS)
			if(pack.special_pod)
				new /obj/effect/pod_landingzone(landing_turf, pack.special_pod, order)
			else
				new /obj/effect/pod_landingzone(landing_turf, pod_type, order)

			update_appearance()
			return TRUE

#undef EXPRESS_EMAG_DISCOUNT
#undef BEACON_PRINT_COOLDOWN

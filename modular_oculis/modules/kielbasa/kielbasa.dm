/obj/item/weaponcrafting/kielbasa_kit
	name = "\"Kielbasa\" weapon conversion kit"
	desc = "Convert your Kibokos into much more practical Kielbasas. Also contains magazine conversion materials."
	icon = 'icons/obj/weapons/improvised.dmi'
	icon_state = "kitsuitcase"

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/kielbasa
	name = "\improper Kielbasa Grenade Launcher"
	desc = /obj/item/gun/ballistic/automatic/sol_grenade_launcher::desc + " This one seems to have been modified to accept magazines full of sausages instead of grenades."
	accepted_magazine_type = /obj/item/ammo_box/magazine/c980_sausage
	spawnwithmagazine = FALSE

/obj/item/ammo_box/magazine/c980_sausage
	name = "\improper Kielbasa grenade box"
	desc = "A standard size box for .980 sausages, holds four of them."

	icon = 'modular_nova/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "granata_standard"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_SMALL

	ammo_type = /obj/item/ammo_casing/c980sausage
	caliber = CALIBER_980TYDHOUER
	max_ammo = 4
	start_empty = TRUE


/obj/item/ammo_box/magazine/c980_sausage/drum
	name = "\improper Kielbasa grenade drum"
	desc = "A drum for .980 sausages, holds six of them."

	icon_state = "granata_drum"

	w_class = WEIGHT_CLASS_NORMAL

	max_ammo = 6


/obj/item/ammo_casing/c980sausage
	name = ".980 Sausage"
	desc = "A large sausage that deals stamina damage and is a sausage."

	icon = 'icons/obj/food/meat.dmi'
	icon_state = "sausage"

	caliber = CALIBER_980TYDHOUER
	projectile_type = /obj/projectile/bullet/sausage

	custom_materials = list(/datum/material/meat = SHEET_MATERIAL_AMOUNT)

	harmful = FALSE //Clearly.
	ammo_categories = AMMO_CLASS_NONE

/obj/item/ammo_casing/c980sausage/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless, FALSE)

/obj/projectile/bullet/sausage
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "sausage"
	name = ".980 Sausage"
	damage = 0
	stamina = 40
	range = 14
	speed = 1
	sharpness = NONE

/obj/projectile/bullet/sausage/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	new /obj/item/food/sausage(get_turf(target))

/datum/crafting_recipe/kielbasa_gun
	name = "Kielbasa Grenade Launcher"
	result = /obj/item/gun/ballistic/automatic/sol_grenade_launcher/kielbasa
	reqs = list(
		/obj/item/gun/ballistic/automatic/sol_grenade_launcher = 1,
	)
	tool_paths = list(/obj/item/weaponcrafting/kielbasa_kit)
	blacklist = list(/obj/item/gun/ballistic/automatic/sol_grenade_launcher/kielbasa)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/kielbasa_mag
	name = "Kielbasa grenade box"
	result = /obj/item/ammo_box/magazine/c980_sausage
	reqs = list(
		/obj/item/ammo_box/magazine/c980_grenade = 1,
	)
	tool_paths = list(/obj/item/weaponcrafting/kielbasa_kit)
	blacklist = list(/obj/item/ammo_box/magazine/c980_grenade/drum)
	time = 5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/kielbasa_drum_mag
	name = "Kielbasa grenade drum"
	result = /obj/item/ammo_box/magazine/c980_sausage/drum
	reqs = list(
		/obj/item/ammo_box/magazine/c980_grenade/drum = 1,
	)
	tool_paths = list(/obj/item/weaponcrafting/kielbasa_kit)
	time = 5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/kielbasa_ammo
	name = ".980 Sausage caliber conversion"
	result = /obj/item/ammo_casing/c980sausage
	reqs = list(
		/obj/item/food/sausage = 1,
	)
	tool_behaviors = TOOL_KNIFE
	time = 1 SECONDS
	category = CAT_WEAPON_AMMO

/datum/supply_pack/security/armory/kielbasa
	name = "Kielbasa conversion kit"
	desc = "Convert your Kiboko hardware into Kielbasa hardware."
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/weaponcrafting/kielbasa_kit)
	crate_name = "kielbasa conversion crate"
	order_flags = ORDER_CONTRABAND

/datum/market_item/weapon/kielbasa
	name = "Kiboko upgrade kit"
	desc = "Some sort of weird conversion kit for a standard Kiboko grenade launcher. Quality not guarenteed."
	item = /obj/item/weaponcrafting/kielbasa_kit

	price_min = CARGO_CRATE_VALUE * 10
	price_max = CARGO_CRATE_VALUE * 20
	stock_max = 2
	availability_prob = 60

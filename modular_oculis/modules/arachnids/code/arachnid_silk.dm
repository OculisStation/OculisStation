/obj/item/stack/sheet/silk
	name = "silk"
	singular_name = "silk"
	desc = "A webby material, best to keep a couple handy."
	inhand_icon_state = null
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	icon = 'modular_oculis/modules/arachnids/icons/stack/silk_stack.dmi'
	icon_state = "silk"
	drop_sound = /datum/sound_effect/cloth_drop
	pickup_sound = /datum/sound_effect/cloth_pickup
	mats_per_unit = list(/datum/material/silk = SHEET_MATERIAL_AMOUNT)
	table_type = /obj/structure/table/silk
	walltype = /turf/closed/wall/material/silk
	material_type = /datum/material/silk
	merge_type = /obj/item/stack/sheet/silk
	novariants = TRUE

/obj/item/stack/sheet/silk/grind_results()
	return list(/datum/reagent/cellulose = 20)


GLOBAL_LIST_INIT(silk_recipes, list ( \
	new /datum/stack_recipe_list("clothing", list( // loincloth doesn't exist on oculis!
		new /datum/stack_recipe("black kimono", /obj/item/clothing/under/costume/kimono, 3, crafting_flags = 0x0, category = CAT_CLOTHING), \
		new /datum/stack_recipe("red kimono", /obj/item/clothing/under/costume/kimono/red, 3, crafting_flags = 0x0, category = CAT_CLOTHING), \
		new /datum/stack_recipe("purple kimono", /obj/item/clothing/under/costume/kimono/purple, 3, crafting_flags = 0x0, category = CAT_CLOTHING), \
		new /datum/stack_recipe("mummy wrapping", /obj/item/clothing/under/costume/mummy, 3, crafting_flags = 0x0, category = CAT_CLOTHING), \
		new /datum/stack_recipe("beanie", /obj/item/clothing/head/beanie, 2, crafting_flags = 0x0, category = CAT_CLOTHING), \
		)),
	new /datum/stack_recipe_list("arachnid web structures", list(
		new /datum/stack_recipe("arachnid web", /obj/structure/spider/stickyweb/arachnid, 3, time = 6 SECONDS, crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE), \
		new /datum/stack_recipe("arachnid solid web", /obj/structure/spider/stickyweb/sealed/tough/arachnid, 4, time = 6 SECONDS, crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE), \
		new /datum/stack_recipe("arachnid web spikes", /obj/structure/spider/spikes/arachnid, 5, time = 6 SECONDS, crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE), \
		new /datum/stack_recipe("arachnid web passage", /obj/structure/spider/passage/arachnid, 3, time = 4 SECONDS, crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE), \
		)),
	new /datum/stack_recipe("refine silk into cloth", /obj/item/stack/sheet/cloth, 2, 1, 6, time = 2 SECONDS, crafting_flags = 0x0, category = CAT_TOOLS), \
	new /datum/stack_recipe("improvised gauze", /obj/item/stack/medical/wrap/gauze/improvised, 2, 2, 6, crafting_flags = 0x0, category = CAT_TOOLS), \
	new /datum/stack_recipe("rag", /obj/item/rag, 1, crafting_flags = 0x0, category = CAT_CHEMISTRY), \
	new /datum/stack_recipe("silk chair", /obj/structure/chair/silk, 3, time = 1 SECONDS, crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE), \
	new /datum/stack_recipe("silk bed", /obj/structure/bed/silk, 2, time = 1 SECONDS, crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE), \
	new /datum/stack_recipe("silk floor tile", /obj/item/stack/tile/silk, 1, 4, 20, crafting_flags = 0x0, category = CAT_TILES),
	))

/obj/item/stack/sheet/silk/get_main_recipes()
	. = ..()
	. += GLOB.silk_recipes

/obj/item/stack/sheet/silk/fifty
	amount = 50

/datum/material/silk
	name = "silk"
	desc = "Arachnid silk, for web development."
	color = "#ffffff"
	mat_flags = MATERIAL_CLASS_RIGID
	sheet_type = /obj/item/stack/sheet/silk
	value_per_unit = 45 / SHEET_MATERIAL_AMOUNT
	mat_properties = list(
		MATERIAL_DENSITY = 1, // silk is not dense at all
		MATERIAL_HARDNESS = 1, // silk is soft
		MATERIAL_FLEXIBILITY = 8, // silk is very flexible
		MATERIAL_REFLECTIVITY = 0, // silk can't reflect
		MATERIAL_ELECTRICAL = 0, // silk can't conduct
		MATERIAL_THERMAL = 1, // silk is insulative
		MATERIAL_CHEMICAL = 0, // silk is not chem proof
	)
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	minimum_value_override = 0
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_COMMON
	texture_layer_icon_state = "silk"

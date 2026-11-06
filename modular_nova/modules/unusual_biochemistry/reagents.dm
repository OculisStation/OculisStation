/datum/reagent/manganese
	name = "Manganese"
	description = "A silvery-gray metal that resembles iron. It is hard and very brittle, difficult to fuse, but easy to oxidize."
	color = "#3D3C47"
	taste_description = "metal"
	ph = 6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// New blood packs
/obj/item/reagent_containers/blood/haemocyanin
	blood_type = /datum/blood_type/haemocyanin

/obj/item/reagent_containers/blood/chlorocruorin
	blood_type = /datum/blood_type/chlorocruorin

/obj/item/reagent_containers/blood/hemerythrin
	blood_type = /datum/blood_type/hemerythrin

/obj/item/reagent_containers/blood/pinnaglobin
	blood_type = /datum/blood_type/pinnaglobin

/obj/item/reagent_containers/blood/exotic
	blood_type = /datum/blood_type/exotic

// OCULIS EDIT ADDITION START
/obj/item/reagent_containers/blood/haemoglobin
	blood_type = /datum/blood_type/haemoglobin

/obj/item/reagent_containers/blood/haemotoxin
	blood_type = /datum/blood_type/haemotoxin

/obj/item/reagent_containers/blood/nanoblood
	blood_type = /datum/blood_type/nanoblood
// OCULIS EDIT ADDITION END

/datum/supply_pack/medical/bloodpacks/uncommon
	name = "Uncommon Blood Pack Variety Crate"
	desc = "Contains sixteen different uncommmon blood packs for reintroducing blood to patients." // OCULIS EDIT, ORIGINAL: desc = "Contains ten different uncommmon blood packs for reintroducing blood to patients."
	cost = CARGO_CRATE_VALUE * 11 // OCULIS EDIT, proportional price increase for more items, ORIGINAL: cost = CARGO_CRATE_VALUE * 7
	contains = list(
		/obj/item/reagent_containers/blood/haemocyanin = 2,
		/obj/item/reagent_containers/blood/chlorocruorin = 2,
		/obj/item/reagent_containers/blood/hemerythrin = 2,
		/obj/item/reagent_containers/blood/pinnaglobin = 2,
		/obj/item/reagent_containers/blood/exotic = 2,
		// OCULIS EDIT ADDITION START
		/obj/item/reagent_containers/blood/haemoglobin = 2,
		/obj/item/reagent_containers/blood/haemotoxin = 2,
		/obj/item/reagent_containers/blood/nanoblood = 2,
		// OCULIS EDIT ADDITION END
	)
	crate_name = "blood freezer"
	crate_type = /obj/structure/closet/crate/freezer

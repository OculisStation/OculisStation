// I would like it to be known these were added out of spite

/datum/design/leftarm/New()
	category += list(SPECIES_ARACHNID)
	return ..()

/datum/design/rightarm/New()
	category += list(SPECIES_ARACHNID)
	return ..()

/datum/design/leftleg/New()
	category += list(SPECIES_ARACHNID)
	return ..()

/datum/design/rightleg/New()
	category += list(SPECIES_ARACHNID)
	return ..()

/datum/design/tongue/arachnid
	name = "Arachnid Tongue"
	build_path = /obj/item/organ/tongue/arachnid
	category = list(
		SPECIES_ARACHNID,
	)

/datum/design/liver/arachnid
	name = "Arachnid Liver"
	build_path = /obj/item/organ/liver/arachnid
	category = list(
		SPECIES_ARACHNID,
	)

/datum/design/heart/arachnid
	name = "Arachnid Heart"
	build_path = /obj/item/organ/heart/arachnid
	category = list(
		SPECIES_ARACHNID,
	)

/datum/design/eyes/arachnid
	name = "Arachnid Eyes"
	build_path = /obj/item/organ/eyes/night_vision/arachnid
	category = list(
		SPECIES_ARACHNID,
	)

/datum/design/arachnid_appendages
	name = "Arachnid Appendages"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/arachnid_appendages
	research_icon = 'modular_oculis/modules/arachnids/icons/research_icons.dmi'
	research_icon_state = "appendages"
	category = list(SPECIES_ARACHNID)

/datum/design/arachnid_chelicerae
	name = "Arachnid Chelicerae"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 15)
	build_path = /obj/item/organ/arachnid_chelicerae
	research_icon = 'modular_oculis/modules/arachnids/icons/research_icons.dmi'
	research_icon_state = "chelicerae"
	category = list(SPECIES_ARACHNID)

/datum/design/arachnid_silkgland
	name = "Arachnid Silk Gland"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 15)
	build_path = /obj/item/organ/silkgland
	research_icon = 'modular_oculis/modules/arachnids/icons/research_icons.dmi'
	research_icon_state = "silkgland"
	category = list(SPECIES_ARACHNID)

/obj/item/disk/design_disk/limbs/arachnid
	name = "Arachnid Organ Design Disk"
	blueprints = list(/datum/design/liver/arachnid, /datum/design/heart/arachnid, /datum/design/tongue/arachnid, /datum/design/eyes/arachnid, /datum/design/arachnid_silkgland, /datum/design/arachnid_appendages, /datum/design/arachnid_chelicerae)

/datum/design/limb_disk/arachnid
	name = "Arachnid Organ Design Disk"
	desc = "Contains designs for arachnid organs for the limbgrower - Arachnid heart, liver, tongue, silk gland, appendages, chelicerae and eyes."
	build_path = /obj/item/disk/design_disk/limbs/arachnid

/datum/design/liver/golem
	name = "Porous Rock"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/silicon = 20)
	build_path = /obj/item/organ/liver/golem
	category = list(SPECIES_GOLEM, RND_CATEGORY_INITIAL)

/datum/design/stomach/golem
	name = "Silicate Grinder"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/silicon = 15)
	build_path = /obj/item/organ/stomach/golem
	category = list(SPECIES_GOLEM, RND_CATEGORY_INITIAL)

/datum/design/appendix/golem
	name = "Internal Forge"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/silicon = 5)
	build_path = /obj/item/organ/appendix/golem
	category = list(SPECIES_GOLEM, RND_CATEGORY_INITIAL)

/datum/design/eyes/golem
	name = "Resonating Crystal"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/silicon = 10)
	build_path = /obj/item/organ/eyes/golem
	category = list(SPECIES_GOLEM, RND_CATEGORY_INITIAL)

/datum/design/tongue/golem
	name = "Golem Tongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/silicon = 10)
	build_path = /obj/item/organ/tongue/golem
	category = list(SPECIES_GOLEM, RND_CATEGORY_INITIAL)

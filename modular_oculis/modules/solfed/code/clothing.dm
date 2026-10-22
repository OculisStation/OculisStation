
/obj/item/clothing/suit/toggle/lawyer/greyscale/solfed
	name = "SolFed investigator jacket"
	greyscale_config = /datum/greyscale_config/solfed_investigator_jacket
	greyscale_config_worn = /datum/greyscale_config/solfed_investigator_jacket/worn
	greyscale_colors = "#41579A#fffb00"

/obj/item/clothing/suit/toggle/lawyer/greyscale/solfed/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SOLFED)

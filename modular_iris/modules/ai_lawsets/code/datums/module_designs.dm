/datum/design/board/crewsimov_module
	name = "Crew-Type Asimov Module"
	desc = "Allows for the construction of a 'Crew-Type Asimov' AI Core Module."
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/law/core/full/crewsimov
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/sophontsimov_module
	name = "Sophont-Type Asimov Module"
	desc = "Allows for the construction of a 'Sophont-Type Asimov' AI Core Module."
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/law/core/full/sophontsimov
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/noidimov_module
	name = "Humanoid-Type Asimov Module"
	desc = "Allows for the construction of a 'Humanoid-Type Asimov' AI Core Module."
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/law/core/full/noidimov
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/godcomplex_module
	name = "God Complex AI Module"
	desc = "Allows for the construction of a 'God Complex' AI Core Module."
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/law/core/full/godcomplex
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

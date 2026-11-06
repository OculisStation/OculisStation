// Note: The quantum materials are 3 times of what the part actually is made out of, very cost intensive process
// Also unlike all other parts, they cannot be made from the away protolathes. Station-only

/datum/design/quantum_capacitor
	name = "Quantum Capacitor"
	desc = "A capacitor engineered with a mix of bluespace and quantum technologies."
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3.3,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2.7,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 2.1,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/stock_parts/capacitor/quantum
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/quantum_scanning_module
	name = "Quantum field scanning module"
	desc = "A special scanning module using a mix of bluespace and quantum tech to scan even sub-atomic materials."
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3.3,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2.7,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 0.9,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 0.9,
	)
	build_path = /obj/item/stock_parts/scanning_module/quantum
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/quantum_servo
	name = "Quantum field servo"
	desc = "A strange, almost intangible servo that uses bluespace tech to manipulate and fold quantum states."
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2.7,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 0.3,
		/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 0.3,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 0.3,
	)
	build_path = /obj/item/stock_parts/servo/quantum
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/quantum_micro_laser
	name = "Quantum micro-laser"
	desc = "A modified quadultra micro-laser designed to make use of newly discovered quantum tech."
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2.7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2.7,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 1.5,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/stock_parts/micro_laser/quantum
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/quantum_matter_bin
	name = "Entangled matter bin"
	desc = "A bluespace matter bin that makes use of entangled particles to store states of materials as energy."
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3.3,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 1.5,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 2.1,
	)
	build_path = /obj/item/stock_parts/matter_bin/quantum
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/quantum_cell
	name = "Quantum power cell"
	desc = "A rechargeable quantum entangled power cell."
	build_type = PROTOLATHE
	// We are draining the entire ass silo with this recipe
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 9,
		/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 5.4,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/stock_parts/power_store/cell/quantum/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

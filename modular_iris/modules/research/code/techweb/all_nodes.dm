/datum/techweb_node/parts_quantum
	display_name = "Quantum Technology"
	description = "Quantum stock parts are to Bluespace Technology what a spear is to a rock, something that has been properly and efficiently utilized."
	prerequisite_nodes = list(/datum/techweb_node/parts_bluespace)
	unlocked_designs = list(
		/datum/design/quantum_scanning_module,
		/datum/design/quantum_servo,
		/datum/design/quantum_matter_bin,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_QUANTUM_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/parts_power_quantum
	display_name = "Quantum Power Technology"
	description = "Full utilization of power storage and dispersal using Bluespace Technology."
	prerequisite_nodes = list(/datum/techweb_node/parts_bluespace)
	unlocked_designs = list(
		/datum/design/quantum_capacitor,
		/datum/design/quantum_cell,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_QUANTUM_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/parts_laser_quantum
	display_name = "Integrated Quantum Laser Theory"
	description = "Theoretics made manifest in the venture of utilizing planck-length Quantum Scanner's in order to make incredibly precise and controlled precisions."
	prerequisite_nodes = list(/datum/techweb_node/parts_bluespace)
	unlocked_designs = list(
		/datum/design/quantum_micro_laser,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_QUANTUM_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/botanygene
	display_name = "Experimental Botanical Engineering"
	description = "Further advancement in plant cultivation techniques and machinery, enabling careful manipulation of plant DNA."
	prerequisite_nodes = list(/datum/techweb_node/parts_adv, /datum/techweb_node/selection)
	unlocked_designs = list(
		/datum/design/diskplantgene,
		/datum/design/board/plantgenes,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)

/datum/techweb_node/declassified_modules
	display_name = "Declassified Modular Suit"
	description = "Modular Technology that was either reversed engineered or previously restricted to Nanotrasen's Higher-ups but later approved for normal research."
	prerequisite_nodes = list(/datum/techweb_node/mod_anomaly)
	unlocked_designs = list(
		/datum/design/module/mod_storage_bluespace,
		/datum/design/module/energy_shield_nanotrasen,
		/datum/design/module/medbeam_nanotrasen,
		)
	required_items_to_unlock = list(/obj/item/mod/module/energy_shield/nanotrasen)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS * 2)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN

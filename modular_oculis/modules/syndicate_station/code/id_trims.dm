/datum/id_trim/syndicom/octavia
	assignment = "Octavia Operative"
	trim_state = "trim_unknown"
	department_color = COLOR_ASSEMBLY_BLACK
	subdepartment_color = COLOR_SYNDIE_RED
	threat_modifier = 5 // Matching the syndicate threat level since Octavia is a syndicate station.

/datum/id_trim/syndicom/octavia/prisoner
	trim_icon = 'modular_nova/master_files/icons/obj/card.dmi'
	assignment = "Octavia Hostage"
	trim_state = "trim_ds2prisoner"
	subdepartment_color = COLOR_MAROON
	sechud_icon_state = SECHUD_DS2_PRISONER

/datum/id_trim/syndicom/octavia/miner
	trim_icon = 'modular_nova/master_files/icons/obj/card.dmi'
	assignment = "Octavia Mining Officer"
	trim_state = "trim_ds2miningofficer"
	sechud_icon_state = SECHUD_DS2_MININGOFFICER
	honorifics = list("Lieutenant", "Mining Officer")
	honorific_positions = HONORIFIC_POSITION_FIRST | HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_FIRST_FULL | HONORIFIC_POSITION_NONE

/datum/id_trim/syndicom/octavia/syndicatestaff
	trim_icon = 'modular_nova/master_files/icons/obj/card.dmi'
	assignment = "Octavia General Staff"
	trim_state = "trim_ds2generalstaff"
	sechud_icon_state = SECHUD_DS2_GENSTAFF
	honorifics = list("Cook", "Janitor", "Private", "Assistant", "Chef")
	honorific_positions = HONORIFIC_POSITION_FIRST | HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_FIRST_FULL | HONORIFIC_POSITION_NONE

/datum/id_trim/syndicom/octavia/researcher
	trim_icon = 'modular_nova/master_files/icons/obj/card.dmi'
	assignment = "Octavia Researcher"
	trim_state = "trim_ds2researcher"
	sechud_icon_state = SECHUD_DS2_RESEARCHER
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS)
	honorifics = list("Researcher", "Doctor")
	honorific_positions = HONORIFIC_POSITION_FIRST | HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_FIRST_FULL | HONORIFIC_POSITION_NONE

/datum/id_trim/syndicom/octavia/enginetechnician
	trim_icon = 'modular_nova/master_files/icons/obj/card.dmi'
	assignment = "Octavia Engine Technician"
	trim_state = "trim_ds2enginetech"
	sechud_icon_state = SECHUD_DS2_ENGINETECH
	honorifics = list("Engineer", "Technician")
	honorific_positions = HONORIFIC_POSITION_FIRST | HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_FIRST_FULL | HONORIFIC_POSITION_NONE

/datum/id_trim/syndicom/octavia/medicalofficer
	trim_icon = 'modular_nova/master_files/icons/obj/card.dmi'
	assignment = "Octavia Medical Officer"
	trim_state = "trim_ds2medicalofficer"
	sechud_icon_state = SECHUD_DS2_DOCTOR
	honorifics = list("MD.","Dr.","Nurse","Doctor")
	honorific_positions = HONORIFIC_POSITION_FIRST | HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_FIRST_FULL | HONORIFIC_POSITION_NONE

/datum/id_trim/syndicom/octavia/masteratarms
	trim_icon = 'modular_nova/master_files/icons/obj/card.dmi'
	assignment = "Octavia Master At Arms"
	trim_state = "trim_ds2masteratarms"
	sechud_icon_state = SECHUD_DS2_MASTERATARMS
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS, ACCESS_SYNDICATE_LEADER)
	honorifics = list("M.A.A","Lieutenant","Senior Officer")
	honorific_positions = HONORIFIC_POSITION_FIRST | HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_FIRST_FULL | HONORIFIC_POSITION_NONE

/datum/id_trim/syndicom/octavia/brigofficer
	trim_icon = 'modular_nova/master_files/icons/obj/card.dmi'
	assignment = "Octavia Brig Officer"
	trim_state = "trim_ds2brigofficer"
	sechud_icon_state = SECHUD_DS2_BRIGOFFICER
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS, ACCESS_SYNDICATE_LEADER)
	honorifics = list("Officer","Corporal","Peacekeeper")
	honorific_positions = HONORIFIC_POSITION_FIRST | HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_FIRST_FULL | HONORIFIC_POSITION_NONE

/datum/id_trim/syndicom/octavia/corporateliasion
	trim_icon = 'modular_nova/master_files/icons/obj/card.dmi'
	assignment = "Octavia Corporate Liaison"
	trim_state = "trim_ds2corporateliaison"
	sechud_icon_state = SECHUD_DS2_CORPLIAISON
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS, ACCESS_SYNDICATE_LEADER)
	honorifics = list("Liason","Representative","Administrator")
	honorific_positions = HONORIFIC_POSITION_FIRST | HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_FIRST_FULL | HONORIFIC_POSITION_NONE

/datum/id_trim/syndicom/octavia/stationadmiral
	trim_icon = 'modular_nova/master_files/icons/obj/card.dmi'
	assignment = "Octavia Admiral"
	trim_state = "trim_ds2admiral"
	sechud_icon_state = SECHUD_DS2_ADMIRAL
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS, ACCESS_SYNDICATE_LEADER)
	honorifics = list("Admiral","Captain","Director", "Cpt.", "Adm.")
	honorific_positions = HONORIFIC_POSITION_FIRST | HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_FIRST_FULL | HONORIFIC_POSITION_NONE

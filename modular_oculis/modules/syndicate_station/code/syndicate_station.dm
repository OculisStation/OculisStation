/datum/lazy_template/syndicate_station
	key = LAZY_TEMPLATE_KEY_SYNDICATE_STATION
	map_dir = "_maps/oculis/lazy_templates"
	map_name = "syndicate_station"

/area/centcom/octavia
	name = "SSS Octavia"
	icon_state = "syndie-ship"
	ambience_index = AMBIENCE_DANGER
	static_lighting = TRUE
	requires_power = TRUE
	default_gravity = STANDARD_GRAVITY
	area_flags = HIDDEN_AREA | EVENT_PROTECTED | NOTELEPORT
	flags_1 = CAN_BE_DIRTY_1

/area/centcom/octavia/briefing_room
	name = "SSS Octavia - Briefing Room"
	icon_state = "syndie-control"

/area/centcom/octavia/research
	name = "SSS Octavia - Research Laboratory"
	icon_state = "syndie-elite"
	ambience_index = AMBIENCE_ENGI

/area/centcom/octavia/engineering
	name = "SSS Octavia - Engineering"
	icon_state = "syndie-elite"
	ambience_index = AMBIENCE_MEDICAL

/area/centcom/octavia/medical
	name = "SSS Octavia - Medical"
	icon_state = "syndie-elite"
	ambience_index = AMBIENCE_REEBE

/area/centcom/octavia/kitchen
	name = "SSS Octavia - Kitchen"
	icon_state = "syndie-elite"

/area/centcom/octavia/bar
	name = "SSS Octavia - Bar"
	icon_state = "syndie-elite"

/area/centcom/octavia/recreation_area
	name = "SSS Octavia - Recreation Area"
	icon_state = "syndie-elite"

/area/centcom/octavia/vault
	name = "SSS Octavia - Vault"
	icon_state = "syndie-elite"

/area/centcom/octavia/library
	name = "SSS Octavia - Library"
	icon_state = "syndie-elite"

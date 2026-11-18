/area/station/redspace_anchor
	name = "Redspace Anchor Control Room"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "engine_sm_room"

/area/station/redspace_anchor/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/block_area_power_fail)

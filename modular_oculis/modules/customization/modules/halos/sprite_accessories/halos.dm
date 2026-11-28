// halo sprites from Citadel RP by way of Monkestation. golden ring, neon ring and grease monkey halo by LettuceWarlock
/datum/sprite_accessory/halo
	key = "halo"
	icon = 'modular_oculis/master_files/icons/mob/sprite_accessory/halos/halos.dmi'
	organ_type = /obj/item/organ/halo
	color_src = USE_ONE_COLOR
	recommended_species = list(
		SPECIES_MAMMAL = 1,
		SPECIES_HUMAN = 1,
		SPECIES_SYNTH = 1,
		SPECIES_FELINE = 1,
		SPECIES_HUMANOID = 1,
	)
	center = TRUE
	dimension_x = 32
	dimension_y = 64

/datum/sprite_accessory/halo/none
	name = SPRITE_ACCESSORY_NONE
	factual = FALSE
	natural_spawn = FALSE

// sprite from Aurora Station
/datum/sprite_accessory/halo/classic
	name = "Classic Halo"
	icon_state = "classic"

/datum/sprite_accessory/halo/gabriel
	name = "Messenger Halo"
	icon_state = "gabriel"

/datum/sprite_accessory/halo/threespike
	name = "Triple-Star Halo"
	icon_state = "threespike"

/datum/sprite_accessory/halo/brokenspike
	name = "Prophet Halo"
	icon_state = "brokenspike"

/datum/sprite_accessory/halo/arrows
	name = "Wayfinder Halo"
	icon_state = "arrows"

/datum/sprite_accessory/halo/circles
	name = "Orbital Halo"
	icon_state = "circles"

/datum/sprite_accessory/halo/thorns
	name = "Judge Halo"
	icon_state = "thorns"

/datum/sprite_accessory/halo/cross
	name = "Winged Cross Halo"
	icon_state = "cross"

/datum/sprite_accessory/halo/moon
	name = "Lunar Halo"
	icon_state = "moon"

/datum/sprite_accessory/halo/crown
	name = "Lauded Halo"
	icon_state = "crown"

/datum/sprite_accessory/halo/shiroinv
	name = "Focused Halo"
	icon_state = "shiroinv"

/datum/sprite_accessory/halo/shiroko
	name = "Headstrong Halo"
	icon_state = "shiroko"

/datum/sprite_accessory/halo/wings
	name = "Ascendant Halo"
	icon_state = "wings"

/datum/sprite_accessory/halo/star
	name = "Radiant Star Halo"
	icon_state = "star"

/datum/sprite_accessory/halo/squares
	name = "Logistician Halo"
	icon_state = "squares"

/datum/sprite_accessory/halo/spikes
	name = "Intrepid Halo"
	icon_state = "spikes"

/datum/sprite_accessory/halo/reticle
	name = "Marksman Halo"
	icon_state = "reticle"

/datum/sprite_accessory/halo/polygon
	name = "Pragmatic Halo"
	icon_state = "polygon"

/datum/sprite_accessory/halo/offset
	name = "Mercurial Halo"
	icon_state = "offset"

/datum/sprite_accessory/halo/nanotrasen
	name = "Nanotrasen Halo"
	icon_state = "nanotrasen"

/datum/sprite_accessory/halo/corpomedic
	name = "Medical Halo"
	icon_state = "corpomedic"

/datum/sprite_accessory/halo/traumaresponse
	name = "Trauma Response Halo"
	icon_state = "traumaresponse"

/datum/sprite_accessory/halo/aesculapian
	name = "Aesculapian Halo"
	icon_state = "aesculapian"

/datum/sprite_accessory/halo/crowned
	name = "Little Crown Halo"
	icon_state = "crowned"

// already gold, so it skips recoloring
/datum/sprite_accessory/halo/goldenring
	name = "Golden Halo"
	icon_state = "goldenring"
	color_src = null

/datum/sprite_accessory/halo/neonring
	name = "Neon Halo"
	icon_state = "neonring"

/datum/sprite_accessory/halo/engineer
	name = "Mechanist Halo"
	icon_state = "engineer"

/datum/sprite_accessory/halo/seraph
	name = "Seraph Halo"
	icon_state = "aeri"

/datum/sprite_accessory/halo/crosshair
	name = "Crosshair Halo"
	icon_state = "crosshair"

// nova halos, formerly found in modular_nova/modules/customization/modules/mob/dead/new_player/sprite_accessories/head_accessory.dm

/datum/sprite_accessory/halo/simple
	name = "Simple Halo"
	icon_state = "simple"

/datum/sprite_accessory/halo/simple/no_animation
	name = "Simple Halo (Static)"
	icon_state = "simple_static"

/datum/sprite_accessory/halo/halo_double
	name = "Double Halo"
	icon_state = "double"

/datum/sprite_accessory/halo/halo_double/no_animation
	name = "Double Halo (Static)"
	icon_state = "double_static"

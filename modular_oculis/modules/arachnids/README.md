[https://github.com/OculisStation/OculisStation/pull/277](https://github.com/OculisStation/OculisStation/pull/277)

## Arachnids
Module ID: ARACHNIDS

### Description:
This module ports the arachnid species from [MonkeStation](https://github.com/Monkestation/Monkestation2.0).  
They were originally ported over *(and modified)* to MonkeStation from SS14 by [MilkForever](https://github.com/MilkForever).  
Arachnids are a humanoid spider-like species, their differences are:
- Innate nightvision, but can't wear eyewear.
- Slightly faster run speed.
- Part of the `SPIDER` faction, won't be attacked by AI spiders.
- Big cosmetic appendages that can't be concealed.
- Cosmetic chelicerae.
- Rare copper-based blood.
- Extremely vulnerable to flyswatters.
- Can't eat vegetables nor fruit.

### TG Proc/File Changes:
- `code/_globalvars/traits/_traits.dm` -> Added `TRAIT_ARACHNID_WEB_SURFER` to /mob
- `code/__DEFINES/DNA.dm` -> Added `ORGAN_SLOT_GLAND`, along with adding it to the organ process order
- `code/__DEFINES/icon_smoothing.dm` -> Added `SMOOTH_GROUP_SILK_WALLS`
- `code/__DEFINES/~~oculis_defines/DNA.dm` -> Added `SPECIES_ARACHNID`, `FEATURE_ARACHNID_APPENDAGES` and `FEATURE_ARACHNID_CHELICERAE`
- `code/__DEFINES/~~oculis_defines/colors.dm` -> Added `BLOOD_COLOR_ARACHNID`
- `code/__DEFINES/~~oculis_defines/is_helper.dm` -> Added `isarachnid()`
- `code/__DEFINES/~~oculis_defines/mobs.dm` -> Added `BLOOD_TYPE_ARACHNID`
- `code/controllers/subsystem/sprite_accessories.dm` -> Added `FEATURE_ARACHNID_APPENDAGES` and `FEATURE_ARACHNID_CHELICERAE` to the feature_list in `/datum/controller/subsystem/accessories/proc/setup_lists()`
- `config/game_options.txt` -> Added arachnid to the roundstart races
- `modular_oculis/modules/master_files/code/game/machinery/limbgrower.dm` -> Added `/obj/machinery/limbgrower/Initialize(mapload)` -> Adds `SPECIES_ARACHNID` to the list of categories
- `modular_oculis/modules/master_files/code/modules/research/techweb/all_nodes.dm` -> Added `/datum/techweb_node/xenobiology/New()` -> Adds `limbdesign_arachnid` to the xenobiology research
- `tgui/packages/tgui/interfaces/PreferencesMenu/preferences/features/character_preferences/oculis/arachnid_preferences.tsx` -> Created
- `modular_nova/modules/customization/modules/client/augment/organs.dm` -> Added `/datum/augment_item/organ/eyes/apply()` -> Makes it so actions are not copied over for eye organs (so the NVG toggle action isn't copied)
- `modular_nova/modules/unusual_biochemistry/reagents.dm` -> Added `/obj/item/reagent_containers/blood/arachnid = 2` -> Adds arachnid blood to the uncommon blood pack variety crate 

### Modular Overrides:
None, I think?

### Defines:
- `ORGAN_SLOT_GLAND`, in `code/__DEFINES/DNA.dm`
- `SMOOTH_GROUP_SILK_WALLS`, in `code/__DEFINES/icon_smoothing.dm`
- `SPECIES_ARACHNID`, `FEATURE_ARACHNID_APPENDAGES`, `FEATURE_ARACHNID_CHELICERAE`, in `code/__DEFINES/~~oculis_defines/DNA.dm`
- `BLOOD_COLOR_ARACHNID`, in `code/__DEFINES/~~oculis_defines/colors.dm`
- `BLOOD_TYPE_ARACHNID`, in `code/__DEFINES/~~oculis_defines/mobs.dm`
- `TRAIT_ARACHNID_WEB_SURFER` in `code/__DEFINES/~~oculis_defines/traits/declarations.dm`

### Included files that are not contained in this module:
- `sound/items/weapons/slash.ogg` -> For the bodypart arms, when attacking
- `sound/items/weapons/slashmiss.ogg` -> For the bodypart arms, when attacking
- `modular_oculis/modules/master_files/code/game/machinery/limbgrower.dm` -> Adds the `SPECIES_ARACHNID` to the categories
- `modular_oculis/modules/master_files/code/modules/research/designs/limbgrower_designs.dm` -> Arachnid recipes for the limb grower
- `modular_oculis/modules/master_files/code/modules/research/techweb/all_nodes.dm` -> Adds `limbdesign_arachnid` to the xenobiology research
- `tgui/packages/tgui/interfaces/PreferencesMenu/preferences/features/character_preferences/oculis/arachnid_preferences.tsx` -> Preferences for appendages / chelicerae
- `code/modules/unit_tests/screenshots/screenshot_humanoids__datum_species_arachnid.png` -> Necessary for the unit tests to pass

### Credits:
[PixelTK](https://github.com/PixelTheKermit): Originally making arachnids over in [SS14](https://github.com/space-wizards/space-station-14/pull/13945).  
[MilkForever](https://github.com/MilkForever): Porting arachnids to [SS13](https://github.com/Monkestation/Monkestation2.0/pull/240).  
[Lokachop](https://github.com/Lokachop): Porting arachnids to Oculis.

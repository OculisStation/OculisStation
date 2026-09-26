https://github.com/OculisStation/OculisStation/pull/45

## A* Pathfinding / Navigation

Module ID: ASTAR

### Description:

Implements A* pathfinding, and reworks the Navigate verb/button to use it.

A* works across Z-levels (it can go up/down stairs), and can also "prefer"
specific areas and tiles, i.e preferring to go through hallways rather than maints.

### TG Proc/File Changes:

- `code/__HELPERS/paths/path.dm`
  - new var: `/datum/can_pass_info/multiz_checks`
  - `/datum/can_pass_info/New`: added `multiz_checks` argument

### Modular Overrides:

- `modular_oculis/master_files/code/game/turfs/open/openspace.dm`
  - `/turf/open/openspace/can_cross_safely`
  - `/turf/open/openspace/CanAStarPass`
- `modular_oculis/master_files/code/game/turfs/turf.dm`
  - `/turf/ChangeTurf`
  - new var: `/turf/astar_weight`
- `modular_oculis/master_files/code/game/atoms_movable.dm`
  - `/atom/movable/Initialize`
  - `/atom/movable/Moved`
  - new var: `/atom/movable/astar_weight`
- `modular_oculis/master_files/code/modules/mob/living/navigation.dm`
  - `/mob/living/create_navigation`

### Defines:

- `code/__DEFINES/~~oculis_defines/astar.dm`: `ASTAR_*` defines
- `code/__HELPERS/~~oculis_helpers/_lists.dm`: `BINARY_INSERT_DEFINE_REVERSE`

### Included files that are not contained in this module:

- `code/__DEFINES/~~oculis_defines/astar.dm`
- `code/__HELPERS/~~oculis_helpers/_lists.dm`
- `code/__HELPERS/~~oculis_helpers/mapping.dm`

### Credits:

Absolucy, dwasint

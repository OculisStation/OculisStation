// Note: higher A* weight = less preferred, lower weight = more preferred.

/// Default A* weight given to areas.
#define ASTAR_WEIGHT_AREA_DEFAULT 0
/// A* weight given to hallway areas.
#define ASTAR_WEIGHT_AREA_HALLS -20
/// A* weight given to maintenance areas.
#define ASTAR_WEIGHT_AREA_MAINTS -(ASTAR_WEIGHT_AREA_HALLS / 2)
/// A* weight given to commons areas, i.e dorms, bar, cafeteria, etc.
#define ASTAR_WEIGHT_AREA_COMMONS (ASTAR_WEIGHT_AREA_HALLS / 4)


/// Default A* weight given to turfs.
#define ASTAR_WEIGHT_TURF_DEFAULT 50
/// A* weight for turfs we'd prefer to not go over if possible, but it's fine if needed.
#define ASTAR_WEIGHT_TURF_DISCOURAGED (ASTAR_WEIGHT_TURF_DEFAULT * 1.5)
/// A* weight for turfs we should prolly never path over but it might be in the realm of possibility anyways?
/// A* files nodes by total cost, so don't go much higher than this, or every search near one of these grows a huge open list.
#define ASTAR_WEIGHT_TURF_ALMOST_NEVER (ASTAR_WEIGHT_TURF_DEFAULT * 4)

/// A* weight for objects that are better to walk around, but it's not a big deal at all.
#define ASTAR_WEIGHT_OBJ_MEH 2
/// A* weight for objects to avoid going thru, but not too strongly.
#define ASTAR_WEIGHT_OBJ_DISCOURAGED 15

/// The lowest weight A* gives a turf: plain floor in a hallway.
/// A*'s distance guess assumes every step costs at least this on both ends, so anything lighter is raised to it.
#define ASTAR_MIN_TURF_WEIGHT (ASTAR_WEIGHT_TURF_DEFAULT + ASTAR_WEIGHT_AREA_HALLS)

///Path we should use next time we start A* movement, if it ends where we're going
#define BB_ASTAR_PATH_TO_USE "BB_astar_path_to_use"

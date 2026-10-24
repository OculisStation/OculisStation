/// File path used for the "enable tracy next round" functionality
#define TRACY_ENABLE_PATH	"data/enable_tracy"

/// The DLL that holds byond-tracy. It is built into dmeow.
#define TRACY_DLL_PATH		(world.system_type == MS_WINDOWS ? "dmeow.dll" : "./libdmeow.so")

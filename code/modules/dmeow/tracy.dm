// byond_tracy is linked into dmeow, so dmeow_init() already installed its hooks.
// Never load a standalone byond_tracy DLL beside this build - both install the
// same detours. Replay a .utracy with rtracy.

/// where byond_tracy_start() puts a capture when it's given no path. matches the
/// default in the DLL's own capture.rs - change one and change the other.
#define DMEOW_TRACY_DIR "data/profiler/"

/// Begin a capture. `path` defaults to data/profiler/<unix ms>.utracy and is
/// never overwritten. `ring_mib` is the buffer for events waiting to be written,
/// 64 by default; when it fills, events drop and the file records a gap.
/// Recording begins at the next tick with no proc running. Returns "" or why it
/// failed.
/proc/byond_tracy_start(path = "", ring_mib = "")
	return call_ext(DMEOW_DLL, "byond_tracy_start")("[path]", "[ring_mib]")

/// Blocks until everything recorded so far is written.
/proc/byond_tracy_flush()
	return call_ext(DMEOW_DLL, "byond_tracy_flush")()

/// Finishes the file and blocks until it is written. A later start works.
/proc/byond_tracy_stop()
	return call_ext(DMEOW_DLL, "byond_tracy_stop")()

/// Assoc list: "state" ("idle", "armed", "recording", "stopped"), "path",
/// "stop_reason", "dropped", "ring_capacity", "ring_high_water", "writer_error".
/proc/byond_tracy_status()
	return json_decode(call_ext(DMEOW_DLL, "byond_tracy_status")())

/// starts a capture only when nothing has been captured yet, so a server that
/// reboots all day records its first round and then leaves the disk alone. an
/// admin starting one by hand ignores this entirely.
///
/// flist() answers with an empty list for a directory that doesn't exist, so a
/// fresh install takes the same branch as an empty folder.
/proc/dmeow_tracy_autostart()
	var/list/existing = flist(DMEOW_TRACY_DIR)
	if(length(existing))
		return "skipped: [DMEOW_TRACY_DIR] already holds [length(existing)] capture(s)"
	var/failure = byond_tracy_start()
	if(failure)
		return "FAILED to start: [failure]"
	return "recording to [DMEOW_TRACY_DIR]"

ADMIN_VERB(dmeow_tracy_begin, R_DEBUG, "dmeow tracy: start capture", "Start a byond_tracy capture. Costs time on every proc call while it runs.", ADMIN_CATEGORY_DEBUG)
	var/failure = byond_tracy_start()
	var/result = failure || "recording to [DMEOW_TRACY_DIR]"
	message_admins("dmeow tracy: [key_name_admin(user)] started a capture - [result]")
	world.log << "dmeow tracy: [result]"

ADMIN_VERB(dmeow_tracy_end, R_DEBUG, "dmeow tracy: stop capture", "Finish the running byond_tracy capture and write the file.", ADMIN_CATEGORY_DEBUG)
	var/failure = byond_tracy_stop()
	var/result = failure || "capture written"
	message_admins("dmeow tracy: [key_name_admin(user)] stopped the capture - [result]")
	world.log << "dmeow tracy: [result]"

ADMIN_VERB(dmeow_tracy_state, R_DEBUG, "dmeow tracy: status", "Show whether byond_tracy is recording, and what it has dropped.", ADMIN_CATEGORY_DEBUG)
	var/status = json_encode(byond_tracy_status(), JSON_PRETTY_PRINT)
	to_chat(user, fieldset_block("byond_tracy status", "[status]", "boxed_message"))

#undef DMEOW_TRACY_DIR

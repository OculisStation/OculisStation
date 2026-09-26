// The corner bookkeeping is two lists that are supposed to mirror each other:
// a corner sits in `source.effect_str`, and that same source sits in
// `corner.affecting`. Every add and remove in `update_corners` touches both.
//
// Only `affecting` is walked when a corner dies. `/datum/lighting_corner/Destroy`
// unhooks itself from the sources it can see there, and nothing else ever will -
// so a corner sitting in an `effect_str` whose source is missing from its
// `affecting` can never be released. BYOND's hard delete cannot rescue it
// either: the erasure scan clears variable slots but skips list *elements*, so
// the entry survives `del()` and the round logs "was unable to be GC'd".
//
// This finds pairs that have already broken. It fixes nothing, and it is meant
// to be run after a round rather than left on - it walks every atom in the world.

/// A corner is in this source's effect_str, but the source is not in the
/// corner's affecting list. This is the one that leaks.
#define LIGHTING_PAIR_UNPAIRED "unpaired"
/// A corner that is already qdeleted is still sitting in an effect_str. Same
/// leak, one step later, and proof the corner cannot be collected.
#define LIGHTING_PAIR_DELETED "deleted"
/// A source is in this corner's affecting list, but the corner is not in that
/// source's effect_str. Does not leak the corner, but it keeps `affecting`
/// non-empty forever, so `self_destruct_if_idle` can never fire for it.
#define LIGHTING_PAIR_STALE "stale"

/**
 * Walks every light source and every lighting corner in the world and reports
 * where the two sides disagree.
 *
 * Returns an assoc list of category -> list of description strings, using the
 * LIGHTING_PAIR_* keys above. An empty list for a key means that side is clean.
 */
/proc/check_lighting_pairing()
	var/list/findings = list(
		LIGHTING_PAIR_UNPAIRED = list(),
		LIGHTING_PAIR_DELETED = list(),
		LIGHTING_PAIR_STALE = list(),
	)

	// A source registers itself on both source_atom and top_atom, and a corner
	// is shared by up to four turfs, so both sets are collected as assoc keys to
	// dedupe rather than checked several times over.
	var/list/datum/light_source/sources = list()
	var/list/datum/lighting_corner/corners = list()

	for(var/atom/thing in world)
		for(var/datum/light_source/source as anything in thing.light_sources)
			sources[source] = TRUE
		if(isturf(thing))
			var/turf/tile = thing
			for(var/datum/lighting_corner/corner in list(tile.lighting_corner_NE, tile.lighting_corner_SE, tile.lighting_corner_SW, tile.lighting_corner_NW))
				corners[corner] = TRUE
		CHECK_TICK

	for(var/datum/light_source/source as anything in sources)
		for(var/datum/lighting_corner/corner as anything in source.effect_str)
			if(QDELETED(corner))
				findings[LIGHTING_PAIR_DELETED] += "[REF(corner)] deleted corner still in effect_str of [describe_light_source(source)]"
				continue
			if(!(source in corner.affecting))
				findings[LIGHTING_PAIR_UNPAIRED] += "[REF(corner)] corner ([corner.x], [corner.y], [corner.z]) in effect_str of [describe_light_source(source)], but that source is not in its affecting list"
		CHECK_TICK

	for(var/datum/lighting_corner/corner as anything in corners)
		for(var/datum/light_source/source as anything in corner.affecting)
			if(QDELETED(source))
				findings[LIGHTING_PAIR_STALE] += "[REF(corner)] corner ([corner.x], [corner.y], [corner.z]) holds deleted source [REF(source)] in affecting"
				continue
			if(!(corner in source.effect_str))
				findings[LIGHTING_PAIR_STALE] += "[REF(corner)] corner ([corner.x], [corner.y], [corner.z]) holds [describe_light_source(source)] in affecting, but that source's effect_str does not hold the corner"
		CHECK_TICK

	return findings

/// Enough to find the light again in a log line: what emits it and where it is.
/proc/describe_light_source(datum/light_source/source)
	var/atom/owner = source.source_atom
	if(!owner)
		return "[REF(source)] (no source_atom)"
	return "[REF(source)] [owner.type] at ([owner.x], [owner.y], [owner.z])"

/// Runs the check and writes it to the world log as well as to chat, so a
/// headless burn round keeps the result after the client is gone.
/proc/report_lighting_pairing(client/user)
	var/list/findings = check_lighting_pairing()
	var/unpaired = length(findings[LIGHTING_PAIR_UNPAIRED])
	var/deleted = length(findings[LIGHTING_PAIR_DELETED])
	var/stale = length(findings[LIGHTING_PAIR_STALE])

	var/summary = "lighting pairing check: [unpaired] corner(s) held by a source that is missing from their affecting list (these leak), [deleted] already-deleted corner(s) still in an effect_str, [stale] stale affecting entr(ies)"
	log_world(summary)
	if(user)
		to_chat(user, summary)

	for(var/category in findings)
		for(var/line in findings[category])
			log_world("lighting pairing [category]: [line]")
			if(user)
				to_chat(user, "  [category]: [line]")

	return findings

#undef LIGHTING_PAIR_UNPAIRED
#undef LIGHTING_PAIR_DELETED
#undef LIGHTING_PAIR_STALE

ADMIN_VERB(check_lighting_pairing, R_DEBUG, "Check lighting corner pairing", "Find lighting corners and light sources that have stopped pointing at each other.", ADMIN_CATEGORY_DEBUG)
	report_lighting_pairing(user)

// The pairing check above comes back clean while corners still fail to collect
// with refcounts in the hundreds, so the extra references are not held by any
// DM structure this code can find. This counts the holders DM can account for
// and subtracts them from what BYOND reports.
//
// Read the result as a difference, never as an absolute. `refcount()` is an
// internal number with no documented contract: on top of DM variables it counts
// the hidden proc-local slot BYOND parks the last-used value in, the `view()`
// cache, and various verb and client bookkeeping. None of that is enumerable
// from DM, so a positive `unaccounted` means "references this code cannot see",
// which is not the same claim as "leaked".
//
// What makes it usable is that all of those engine-internal holders are the
// same whether the JIT is running or not. So take a reading, turn the JIT's
// hooks off, take another, and compare. The change between the two runs is the
// measurement; either number on its own is not.

/// The corners that already failed to collect, with the references DM can see.
///
/// Deliberately walks SSgarbage's queues rather than the world's turfs. A
/// corner that failed to collect has already run Destroy, which nulls all four
/// `master_*.lighting_corner_*` back-pointers - so the failures are exactly the
/// corners no turf can reach any more, and a turf walk would sample only the
/// healthy ones.
///
/// It also makes the arithmetic exact. A queued corner has two references by
/// construction, the same two `REFS_WE_EXPECT` accounts for in SSgarbage: the
/// local holding it and the entry in the queue list. Everything past that is
/// unexplained.
///
/// Returns a list of assoc lists sorted worst-first, each holding `corner`,
/// `refcount`, `holders` and `unaccounted`.
/// `queued_since` drops every corner that entered SSgarbage's queue before that
/// `world.time`. Pass the time you changed whatever you are testing and the
/// result contains only corners that lived their whole life under the new
/// setting - without it a reading taken minutes after the change is still full
/// of corners from before it, because SSgarbage holds items for several minutes
/// before it ever looks at them.
/proc/audit_corner_refcounts(queued_since = 0)
	// Measure this proc's own grip rather than argue about it. `refcount()`
	// counts more than DM variables - the hidden proc-local slot BYOND parks
	// the last-used value in shows up too, which is why `y += x` alone reads
	// as an extra reference on x. So hold a throwaway datum through the exact
	// same shape the loop below uses (a nested list, subscripted into a local)
	// and take whatever number comes back as zero.
	//
	// No named local for the datum itself: the loop has no equivalent, and one
	// extra local here would hide one real leaked reference per corner.
	var/list/sentinel_queue = list(list(world.time, new /datum, 0))
	var/baseline = 0
	for(var/list/entry as anything in sentinel_queue)
		var/datum/held = entry[GC_QUEUE_ITEM_REF]
		baseline = refcount(held)
	log_world("corner refcount audit: baseline for a queued datum is [baseline]; anything above that is unexplained")

	var/list/audited = list()
	for(var/list/queue as anything in SSgarbage.queues)
		for(var/list/entry as anything in queue)
			var/queued_at = entry[GC_QUEUE_ITEM_QUEUE_TIME]
			if(queued_at < queued_since)
				continue
			var/datum/lighting_corner/corner = entry[GC_QUEUE_ITEM_REF]
			if(!istype(corner))
				continue
			// Read the count before anything else touches the corner. Reading
			// any of its vars below parks that var in the hidden proc-local
			// slot instead, which drops the corner's count by one and would
			// make this read one lower than the baseline was measured at.
			var/count = refcount(corner)

			// Still counted even though Destroy should have cleared both: a
			// corner that kept one is a different bug from one carrying
			// references nothing owns, and the report should tell them apart.
			var/holders = length(corner.affecting)
			if(corner.master_NE?.lighting_corner_SW == corner)
				holders++
			if(corner.master_SE?.lighting_corner_NW == corner)
				holders++
			if(corner.master_SW?.lighting_corner_NE == corner)
				holders++
			if(corner.master_NW?.lighting_corner_SE == corner)
				holders++

			audited += list(list(
				"corner" = corner,
				"refcount" = count,
				"holders" = holders,
				"unaccounted" = count - holders - baseline,
				"age" = (world.time - queued_at) / 10,
			))
			CHECK_TICK

	sortTim(audited, GLOBAL_PROC_REF(cmp_corner_audit_desc))
	return audited

/// Worst offenders first, so a truncated report still shows the interesting end.
/proc/cmp_corner_audit_desc(list/a, list/b)
	return b["unaccounted"] - a["unaccounted"]

/// Runs the audit and prints the worst offenders plus the overall shape.
///
/// `unaccounted` is net of this proc's own grip on the corner, but not of
/// BYOND's own internal bookkeeping, which DM cannot enumerate. Compare two
/// runs with the JIT's hooks on and off rather than reading either number
/// alone - see the note above the audit.
///
/// Run it while corners are still queued. Once SSgarbage hard-deletes them
/// there is nothing left to measure and it will report an empty queue.
/proc/report_corner_refcounts(client/user, show = 20, within_seconds = 0)
	var/queued_since = within_seconds ? world.time - (within_seconds SECONDS) : 0
	var/list/audited = audit_corner_refcounts(queued_since)
	if(!length(audited))
		var/clean = "corner refcount audit: no lighting corners queued in that window - nothing to measure, not proof of health"
		log_world(clean)
		if(user)
			to_chat(user, clean)
		return audited

	var/worst = audited[1]["unaccounted"]
	var/median = audited[round(length(audited) / 2) + 1]["unaccounted"]
	// The oldest row is what says whether the window did its job: anything
	// older than the change under test drags the whole reading back toward the
	// setting you were trying to leave behind.
	var/oldest = 0
	for(var/list/row as anything in audited)
		oldest = max(oldest, row["age"])
	var/summary = "corner refcount audit: [length(audited)] corner(s) carry references DM cannot see - worst [worst], median [median], oldest queued [oldest]s ago. compare against a run with the JIT's hooks off; BYOND's own internal references are in these numbers too"
	log_world(summary)
	if(user)
		to_chat(user, summary)

	for(var/i in 1 to min(show, length(audited)))
		var/list/row = audited[i]
		var/datum/lighting_corner/corner = row["corner"]
		var/line = "  [REF(corner)] ([corner.x], [corner.y], [corner.z]) refcount [row["refcount"]], [row["holders"]] holder(s) in DM, [row["unaccounted"]] unaccounted, queued [row["age"]]s ago"
		log_world(line)
		if(user)
			to_chat(user, line)

	return audited

ADMIN_VERB(audit_corner_refcounts, R_DEBUG, "Audit lighting corner refcounts", "Compare each corner's refcount against the references DM can actually see.", ADMIN_CATEGORY_DEBUG)
	var/within = tgui_input_number(
		user,
		"Only look at corners queued within the last N seconds. After changing what you are testing, use the number of seconds since you changed it - otherwise the reading is still full of corners from before. 0 looks at everything.",
		"Corner refcount audit",
		default = 0,
		min_value = 0,
	)
	if(isnull(within))
		return
	report_corner_refcounts(user, within_seconds = within)

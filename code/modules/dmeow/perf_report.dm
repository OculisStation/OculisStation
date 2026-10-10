#ifdef DMEOW_BURN_BUILD

/// ratio ascending, so the procs the JIT made *slower* float to the top.
/proc/cmp_dmeow_ratio_asc(list/a, list/b)
	return a["ratio"] - b["ratio"]

/// self-time ratio ascending, for the rows the JIT made slower in its own body.
/proc/cmp_dmeow_self_ratio_asc(list/a, list/b)
	return a["self_ratio"] - b["self_ratio"]

/// which arm each A/B window belongs to, read back out of the report's own
/// marks. assoc list of "<window index>" -> "on" | "off".
///
/// mark_window() writes those labels; the "on"/"off" prefix is the whole
/// contract between the two.
/proc/dmeow_window_arms(list/report)
	var/list/arms = list()
	for(var/list/mark as anything in report["marks"])
		var/label = "[mark["label"]]"
		var/split = findtext(label, ":")
		arms["[mark["window"]]"] = split ? copytext(label, 1, split) : label
	return arms

/// paired sign test over the A/B windows.
///
/// drift fakes an aggregate ratio: if the server just got busier, whichever arm
/// ran later loses and one number can't tell you that happened. pairing each JIT
/// window against the interpreter window right after it can. "1.44x, and it won
/// 8 of 8 pairs" survives drift.
/proc/dmeow_window_pairs(list/entry, list/arms, use_self = FALSE)
	var/list/by_window = list()
	for(var/list/window as anything in entry["windows"])
		by_window["[window["window"]]"] = window
	var/native_time_key = use_self ? "native_self_total_ns" : "native_total_ns"
	var/interpreter_time_key = use_self ? "interpreter_self_total_ns" : "interpreter_total_ns"

	var/pairs_total = 0
	var/pairs_won = 0
	for(var/window_id in 0 to length(arms) - 1)
		if(arms["[window_id]"] != "on" || arms["[window_id + 1]"] != "off")
			continue
		var/list/on_window = by_window["[window_id]"]
		var/list/off_window = by_window["[window_id + 1]"]
		if(!on_window || !off_window)
			continue
		var/native_samples = on_window["native_sampled_calls"]
		var/interpreter_samples = off_window["interpreter_sampled_calls"]
		if(native_samples < 1 || interpreter_samples < 1)
			continue
		pairs_total++
		if((off_window[interpreter_time_key] / interpreter_samples) > (on_window[native_time_key] / native_samples))
			pairs_won++

	return list("won" = pairs_won, "total" = pairs_total)

/// per-fire SSair rows beside the perf report, same stem. `dmeow/turfs/` and not
/// `dmeow/perf/` because build.ts announces the newest perf file as "Report:", so
/// a second file landing there would get read with the wrong script.
/proc/dmeow_turf_rows_write(datum/dmeow_perf_session/session, perf_file, load_description)
	var/filename = replacetext(perf_file, "/dmeow/perf/", "/dmeow/turfs/")
	var/dump_file = file(filename)
	dump_file << json_encode(list(
		"perf_file" = perf_file,
		"tick_lag" = world.tick_lag,
		"cycles" = session.cycles,
		"window_seconds" = session.window_seconds,
		"load" = load_description,
		"rows_dropped" = session.turf_rows_dropped,
		"mobs_deleted" = session.mobs_deleted,
		"quiet_station" = session.quiet_station,
		"freeze_census" = session.freeze_census,
		"fire_runs_end" = SSair.fire_runs,
		"times_fired_end" = SSair.times_fired,
		"recovered" = SSair.recovered,
		"rows" = session.turf_rows,
	))
	return filename

/// yanks a report out of the DLL, dumps the raw JSON, and buckets every proc by
/// whether its numbers mean anything.
///
/// ranks on the *median*, never the average - an average here is one lock
/// contention away from a totally different number, and the 2026-08-09 run had
/// rows where the two were 139x apart. both come back; that gap is itself a tell.
/// self-time has to use averages, the profiler publishes no self-time median.
/proc/dmeow_perf_collect()
	var/json = dmeow_perf_report(DMEOW_PERF_REPORT_LIMIT)
	if(!json)
		return null

	var/filename = "[GLOB.log_directory]/dmeow/perf/[rustg_unix_timestamp()].json"
	var/report_file = file(filename)
	report_file << json

	var/list/report = json_decode(json)
	var/list/arms = dmeow_window_arms(report)

	var/list/comparable = list()
	var/list/self_comparable = list()
	var/list/below_floor = list()
	var/list/self_below_floor = list()
	var/list/insufficient = list()
	var/self_insufficient = 0
	for(var/list/entry as anything in report["entries"])
		var/list/native_arm = entry["native"]
		var/list/interpreter_arm = entry["interpreter"]
		var/native_samples = native_arm["sampled_calls"]
		var/interpreter_samples = interpreter_arm["sampled_calls"]
		var/overlap = entry["arm_overlap_pct"]
		var/native_median = native_arm["median_ns"]
		var/interpreter_median = interpreter_arm["median_ns"]
		var/native_self_avg = native_arm["self_avg_ns"] || 0
		var/interpreter_self_avg = interpreter_arm["self_avg_ns"] || 0

		var/list/row = list(
			"path" = entry["path"],
			"native_median_ns" = native_median,
			"interpreter_median_ns" = interpreter_median,
			"native_avg_ns" = native_arm["avg_ns"],
			"interpreter_avg_ns" = interpreter_arm["avg_ns"],
			"native_self_avg_ns" = native_self_avg,
			"interpreter_self_avg_ns" = interpreter_self_avg,
			"native_samples" = native_samples,
			"interpreter_samples" = interpreter_samples,
			"samples" = min(native_samples, interpreter_samples),
			"overlap" = overlap,
			"confidence" = "[native_arm["confidence"]]/[interpreter_arm["confidence"]]",
			"deopts" = entry["deopt_calls"],
			"demoted" = !!entry["demoted"],
			"eligibility" = entry["eligibility"],
			"ratio" = 0,
			"avg_ratio" = 0,
			"self_ratio" = 0,
			"pairs_won" = 0,
			"pairs_total" = 0,
			"self_pairs_won" = 0,
			"self_pairs_total" = 0,
			"verdict" = "insufficient",
		)

		// order matters: a row that never had two arms can't be judged on its
		// resolution, and a row under the clock's floor can't be judged at all.
		if(native_samples < DMEOW_PERF_MIN_SAMPLES || interpreter_samples < DMEOW_PERF_MIN_SAMPLES || overlap < DMEOW_PERF_MIN_OVERLAP_PCT)
			UNTYPED_LIST_ADD(insufficient, row)
			self_insufficient++
			continue

		var/list/inclusive_pairs = dmeow_window_pairs(entry, arms)
		row["pairs_won"] = inclusive_pairs["won"]
		row["pairs_total"] = inclusive_pairs["total"]
		if(native_median <= 0 || interpreter_median <= 0 || native_arm["confidence"] == "resolution_floor" || interpreter_arm["confidence"] == "resolution_floor")
			row["verdict"] = "below_floor"
			UNTYPED_LIST_ADD(below_floor, row)
		else
			row["ratio"] = interpreter_median / native_median
			row["avg_ratio"] = native_arm["avg_ns"] > 0 ? interpreter_arm["avg_ns"] / native_arm["avg_ns"] : 0
			row["verdict"] = row["ratio"] < 1 ? "loss" : "win"
			UNTYPED_LIST_ADD(comparable, row)

		var/list/self_pairs = dmeow_window_pairs(entry, arms, TRUE)
		row["self_pairs_won"] = self_pairs["won"]
		row["self_pairs_total"] = self_pairs["total"]
		if(native_self_avg <= 0 || interpreter_self_avg <= 0)
			UNTYPED_LIST_ADD(self_below_floor, row)
		else
			row["self_ratio"] = interpreter_self_avg / native_self_avg
			var/list/self_row = row.Copy()
			self_row["pairs_won"] = self_pairs["won"]
			self_row["pairs_total"] = self_pairs["total"]
			self_row["verdict"] = row["self_ratio"] < 1 ? "loss" : "win"
			UNTYPED_LIST_ADD(self_comparable, self_row)

	sortTim(comparable, GLOBAL_PROC_REF(cmp_dmeow_ratio_asc))
	sortTim(self_comparable, GLOBAL_PROC_REF(cmp_dmeow_self_ratio_asc))

	var/list/losses = list()
	var/list/wins = list()
	for(var/list/row as anything in comparable)
		if(length(losses) >= DMEOW_PERF_SUMMARY_ROWS)
			break
		if(row["verdict"] == "loss")
			UNTYPED_LIST_ADD(losses, row)
	for(var/index = length(comparable), index >= 1, index--)
		if(length(wins) >= DMEOW_PERF_SUMMARY_ROWS)
			break
		if(comparable[index]["verdict"] == "win")
			UNTYPED_LIST_ADD(wins, comparable[index])

	var/list/self_losses = list()
	var/list/self_wins = list()
	for(var/list/row as anything in self_comparable)
		if(length(self_losses) >= DMEOW_PERF_SUMMARY_ROWS)
			break
		if(row["verdict"] == "loss")
			UNTYPED_LIST_ADD(self_losses, row)
	for(var/index = length(self_comparable), index >= 1, index--)
		if(length(self_wins) >= DMEOW_PERF_SUMMARY_ROWS)
			break
		if(self_comparable[index]["verdict"] == "win")
			UNTYPED_LIST_ADD(self_wins, self_comparable[index])

	// below-floor rows come back ordered by how much work they do, so the ones
	// actually worth a finer clock end up on top.
	var/list/floor_rows = below_floor.Copy(1, min(length(below_floor), DMEOW_PERF_SUMMARY_ROWS) + 1)
	var/list/self_floor_rows = self_below_floor.Copy(1, min(length(self_below_floor), DMEOW_PERF_SUMMARY_ROWS) + 1)

	return list(
		"file" = filename,
		"losses" = losses,
		"wins" = wins,
		"self_losses" = self_losses,
		"self_wins" = self_wins,
		"below_floor" = floor_rows,
		"self_below_floor" = self_floor_rows,
		"compared" = length(comparable),
		"self_compared" = length(self_comparable),
		"below_floor_count" = length(below_floor),
		"self_below_floor_count" = length(self_below_floor),
		"insufficient" = length(insufficient),
		"self_insufficient" = self_insufficient,
		"total_calls" = report["total_calls"],
		"reported_calls" = report["reported_calls"],
		"timer_source" = report["timer_source"],
		"resolution_ns" = report["resolution_ns"],
		"timer_anomalies" = report["timer_anomalies"],
		"windows" = report["windows"],
		"census" = report["census"],
	)

#endif

#ifdef DMEOW_BURN_BUILD

/**
 * does the JIT get the same numbers as the interpreter for the air code?
 *
 * three live burn rounds all measured the burn room starting 1.87x as many fires
 * with the JIT armed. either dmeow frees up enough time for the fire to spread
 * further, or a compiled air proc returns a slightly different number and tiles
 * catch that shouldn't. this settles it.
 *
 * both arms come from the same process. the interpreter readings are taken
 * *before* anything is compiled, since an uncompiled proc runs interpreted
 * whatever the hook state is - beats toggling hooks, which would leave the result
 * depending on native dispatch being a complete bypass.
 *
 * comparison is exact. every tolerance in dmeow's own suite is wider than the
 * difference we're looking for, which is why its atmos test can't see this.
 */

/// several re-seed periods, so the captured mixtures carry real archive state
/// and real temperature_share history rather than the seeded values.
#define DMEOW_EQUIV_BURN_SECONDS 20
#define DMEOW_EQUIV_TICKS 500
/// the leaf compare runs over every captured mixture; trajectories are expensive
/// and don't need to.
#define DMEOW_EQUIV_TRAJECTORY_SAMPLES 3
/// an f32 round-trips in 9.
#define DMEOW_EQUIV_DIGITS 12
#define DMEOW_EQUIV_MAX_PRINTED 40

/// the rest of what a burning turf touches, on top of the five a burn round
/// force-compiles. several of these promoted on their own in the live rounds.
#define DMEOW_EQUIV_EXTRA_TARGETS list(\
	"/datum/gas_mixture/proc/garbage_collect",\
	"/datum/gas_mixture/proc/compare",\
	"/datum/gas_mixture/proc/heat_capacity_archive",\
	"/datum/gas_mixture/turf/heat_capacity_archive",\
	"/datum/gas_mixture/proc/temperature_share",\
	"/datum/gas_mixture/proc/equalize",\
)

/// copies a mixture by value, keeping everything the procs under test read.
///
/// copy() won't do: it zeroes moles_archive and carries over neither
/// temperature_archived nor volume, which is exactly what heat_capacity_archive()
/// and compare(cmp_archive = TRUE) look at. archive() won't either - it replaces
/// the moles_archive list rather than writing into it, so a held reference goes
/// stale instead of tracking.
/proc/dmeow_equiv_snapshot(datum/gas_mixture/source)
	var/mixture_type = source.type
	var/datum/gas_mixture/clone = new mixture_type(source.volume)
	clone.moles = source.moles.Copy()
	clone.moles_archive = source.moles_archive.Copy()
	clone.temperature = source.temperature
	clone.temperature_archived = source.temperature_archived
	return clone

/// a moles list as exact text, in natural order rather than sorted. a difference
/// in ordering is itself worth seeing: the reductions walk the assoc tree, so two
/// lists with the same numbers in a different shape can hand back different sums.
/proc/dmeow_equiv_moles_digest(list/moles)
	var/list/parts = list()
	for(var/gas_id in moles)
		parts += "[gas_id]=[num2text(moles[gas_id], DMEOW_EQUIV_DIGITS)]"
	return jointext(parts, ";")

/// every leaf reading for one mixture, filed into `into` under "<name>|<proc>".
/proc/dmeow_equiv_read_leaves(name, datum/gas_mixture/source, datum/gas_mixture/reference, list/into)
	var/datum/gas_mixture/mix = dmeow_equiv_snapshot(source)
	into["[name]|heat_capacity"] = mix.heat_capacity()
	into["[name]|heat_capacity_archive"] = mix.heat_capacity_archive()
	into["[name]|total_moles"] = mix.total_moles()
	into["[name]|return_pressure"] = mix.return_pressure()
	into["[name]|compare"] = mix.compare(reference)
	into["[name]|compare_archive"] = mix.compare(reference, cmp_archive = TRUE)
	// garbage_collect returns nothing worth reading, so the reading is the pair of
	// lists it leaves behind.
	mix.garbage_collect()
	into["[name]|gc_moles"] = dmeow_equiv_moles_digest(mix.moles)
	into["[name]|gc_moles_archive"] = dmeow_equiv_moles_digest(mix.moles_archive)

/// the two-mixture procs, which the single-mixture readings can't reach. these
/// are how heat and gas cross between turfs, so they'd explain a fire spreading
/// differently rather than one tile burning differently. both mutate both sides,
/// so the reading is the state left behind on each.
///
/// share() is deliberately absent. it hands back to the interpreter on every call
/// - 50 of 50 in the Linux round before being demoted - so a "compiled" reading
/// would be the interpreter compared against itself, and its hand-backs would
/// wreck the zero-deopt gate that makes every other reading here mean something.
/proc/dmeow_equiv_read_coupling(name, datum/gas_mixture/source, datum/gas_mixture/partner, list/into)
	var/datum/gas_mixture/hot = dmeow_equiv_snapshot(source)
	var/datum/gas_mixture/cold = dmeow_equiv_snapshot(partner)
	into["[name]|temperature_share"] = hot.temperature_share(cold, OPEN_HEAT_TRANSFER_COEFFICIENT)
	into["[name]|temperature_share/self"] = "[num2text(hot.temperature, DMEOW_EQUIV_DIGITS)] [dmeow_equiv_moles_digest(hot.moles)]"
	into["[name]|temperature_share/other"] = "[num2text(cold.temperature, DMEOW_EQUIV_DIGITS)] [dmeow_equiv_moles_digest(cold.moles)]"

	var/datum/gas_mixture/left = dmeow_equiv_snapshot(source)
	var/datum/gas_mixture/right = dmeow_equiv_snapshot(partner)
	left.equalize(right)
	into["[name]|equalize/self"] = "[num2text(left.temperature, DMEOW_EQUIV_DIGITS)] [dmeow_equiv_moles_digest(left.moles)]"
	into["[name]|equalize/other"] = "[num2text(right.temperature, DMEOW_EQUIV_DIGITS)] [dmeow_equiv_moles_digest(right.moles)]"

/// one react() chain, recorded per step.
///
/// the burning flag is the decision the live rounds actually counted, so
/// recording it turns a one-bit temperature difference into a flipped boolean
/// instead of two 12-digit numbers to eyeball.
///
/// holder stays null on purpose: plasmafire's istype(location) then fails, so
/// there's no hotspot_expose and no turf side effect, and the mixture is the only
/// thing moving.
///
/// returns how many steps reacted and how many were over the fire threshold. a
/// trajectory that never reacts matches the other arm for free, and that's
/// indistinguishable from a real pass without these.
/proc/dmeow_equiv_trajectory(name, datum/gas_mixture/seed_mix, list/into)
	var/datum/gas_mixture/mix = dmeow_equiv_snapshot(seed_mix)
	var/reacted = 0
	var/burning_steps = 0
	for(var/step in 1 to DMEOW_EQUIV_TICKS)
		var/flags = mix.react(null)
		var/burning = mix.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST
		if(flags != NO_REACTION)
			reacted++
		if(burning)
			burning_steps++
		into["[name]|t[step]"] = "flags=[flags] temp=[num2text(mix.temperature, DMEOW_EQUIV_DIGITS)] burning=[burning] [dmeow_equiv_moles_digest(mix.moles)]"
	return list("reacted" = reacted, "burning" = burning_steps)

/// mixtures aimed at where a last-bit difference stops being one.
///
/// the turf overrides end in `|| HEAT_CAPACITY_VACUUM`, so exactly zero jumps to
/// 7000 - that's what the empty mixes are for. the three around MOLAR_ACCURACY
/// are the cutoff garbage_collect trims on. the burn mix at 370 is what the room
/// seeds, 3.15K under what plasmafire needs, so the pair either side of that is
/// where a turf decides whether to catch.
/proc/dmeow_equiv_boundary_mixes()
	var/list/mixes = list()

	var/datum/gas_mixture/turf/empty_turf = new(CELL_VOLUME)
	empty_turf.archive()
	mixes["empty turf"] = empty_turf

	var/datum/gas_mixture/empty_base = new(CELL_VOLUME)
	empty_base.archive()
	mixes["empty base"] = empty_base

	var/datum/gas_mixture/turf/cutoff = new(CELL_VOLUME)
	cutoff.moles[/datum/gas/oxygen] = MOLAR_ACCURACY
	cutoff.moles[/datum/gas/plasma] = MOLAR_ACCURACY * 0.5
	cutoff.moles[/datum/gas/nitrogen] = MOLAR_ACCURACY * 2
	cutoff.temperature = T20C
	cutoff.archive()
	mixes["molar cutoff"] = cutoff

	for(var/temperature in list(370, FIRE_MINIMUM_TEMPERATURE_TO_EXIST, 400, 1000))
		mixes["burn mix at [temperature]K"] = dmeow_equiv_burn_mix(temperature)

	return mixes

/// the room's seed mixture at a chosen temperature. the archive() matters:
/// parse_gas_string hands back a copy(), which leaves moles_archive all zeros and
/// temperature_archived at TCMB, so without it the two archive procs would only
/// ever hit their vacuum branch.
/proc/dmeow_equiv_burn_mix(temperature)
	var/datum/gas_mixture/turf/mix = SSair.parse_gas_string(BURNMIX_ATMOS, /datum/gas_mixture/turf)
	mix.temperature = temperature
	mix.archive()
	return mix

/// keys whose values differ between the two arms, as printable lines.
/proc/dmeow_equiv_differences(list/interpreted, list/compiled)
	var/list/lines = list()
	for(var/key in interpreted)
		var/was = interpreted[key]
		var/now = compiled[key]
		if(was == now)
			continue
		if(isnum(was) && isnum(now))
			lines += "[key]: interp [num2text(was, DMEOW_EQUIV_DIGITS)] vs jit [num2text(now, DMEOW_EQUIV_DIGITS)]"
			continue
		lines += "[key]: interp [was] vs jit [now]"
	return lines

/// proves the comparison can fail, in the two ways it could silently not. a probe
/// that never ran any native code reports the same clean pass as one that did, so
/// this isn't optional.
///
/// resolution: two floats one ulp apart at magnitude 1 have to read as different,
/// or `==` isn't resolving what we're looking for. plumbing: nudging one real
/// reading has to make differences() report exactly it.
/proc/dmeow_equiv_red_phase(list/interpreted)
	var/list/lines = list()

	var/one_ulp_up = 1 + 2 ** (-23)
	lines += "resolution: 1 vs 1+2^-23 read as [one_ulp_up == 1 ? "EQUAL - the comparison is blind" : "different"]"

	var/list/nudged = interpreted.Copy()
	var/nudged_key
	for(var/key in nudged)
		if(!isnum(nudged[key]) || nudged[key] == 0)
			continue
		nudged_key = key
		nudged[key] = nudged[key] * (1 + 2 ** (-20))
		break

	if(!nudged_key)
		lines += "plumbing: NOT RUN - no non-zero numeric reading to perturb"
		return lines

	var/list/caught = dmeow_equiv_differences(interpreted, nudged)
	lines += "plumbing: perturbed [nudged_key], differences() reported [length(caught)] (want exactly 1)"
	return lines

/// burns a room to collect real mixtures, reads every air proc interpreted,
/// force-compiles them, reads again, diffs. split in two because the burn has to
/// run for real time and this half is reached from a timer callback.
/world/proc/run_dmeow_equiv()
	SSticker.delay_end = TRUE

	if(!dmeow_init())
		log_world("DMEOW_EQUIV: dmeow failed to load, nothing measured")
		finish_dmeow_equiv()
		return

	if(!dmeow_armed)
		log_world("DMEOW_EQUIV: dmeow loaded but the JIT is disabled - both arms would be the interpreter")
		dmeow_shutdown()
		finish_dmeow_equiv()
		return

	// otherwise the auto-tier promotes a proc partway through the interpreter
	// baseline. it's also what makes the deopt counter mean something later: with
	// it off, only the targets this probe compiles can deopt at all.
	dmeow_disable_counting()

	log_world("DMEOW_EQUIV: burning for [DMEOW_EQUIV_BURN_SECONDS]s to collect mixtures")
	log_world("DMEOW_EQUIV: [dmeow_toggle_standalone_burn()]")
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(dmeow_equiv_measure_kickoff)), DMEOW_EQUIV_BURN_SECONDS SECONDS)

/// world isn't a /datum, so a timer callback can't target a /world/proc directly.
/proc/dmeow_equiv_kickoff()
	world.run_dmeow_equiv()

/proc/dmeow_equiv_measure_kickoff()
	world.measure_dmeow_equiv()

/world/proc/measure_dmeow_equiv()
	var/list/captured = list()
	var/datum/dmeow_load/atmos_room/burn/burn = GLOB.dmeow_standalone_burn
	if(burn)
		for(var/turf/open/cell as anything in burn.interior)
			if(cell.air)
				captured += dmeow_equiv_snapshot(cell.air)
	// snapshots are by value, so tearing the room down now stops the burn mutating
	// anything underneath the two arms.
	dmeow_toggle_standalone_burn()
	log_world("DMEOW_EQUIV: captured [length(captured)] mixtures off the burn room")

	var/list/inputs = dmeow_equiv_boundary_mixes()
	for(var/index in 1 to length(captured))
		inputs["burn turf [index]"] = captured[index]

	var/datum/gas_mixture/reference = SSair.parse_gas_string(BURNMIX_ATMOS, /datum/gas_mixture/turf)
	reference.archive()

	// plasmafire needs the mix over PLASMA_MINIMUM_BURN_TEMPERATURE and the room
	// seeds 3.15K under it, so a trajectory off the plain seed mix would sit at
	// NO_REACTION for every step and measure nothing.
	var/list/trajectory_seeds = list()
	for(var/temperature in list(FIRE_MINIMUM_TEMPERATURE_TO_EXIST, 400, 1000))
		trajectory_seeds["synthetic [temperature]K"] = dmeow_equiv_burn_mix(temperature)

	var/burning_seeds = 0
	var/captured_burning = 0
	var/captured_hottest = 0
	var/captured_coldest = INFINITY
	for(var/datum/gas_mixture/candidate as anything in captured)
		captured_hottest = max(captured_hottest, candidate.temperature)
		captured_coldest = min(captured_coldest, candidate.temperature)
		if(candidate.temperature <= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			continue
		captured_burning++
		if(burning_seeds >= DMEOW_EQUIV_TRAJECTORY_SAMPLES)
			continue
		burning_seeds++
		trajectory_seeds["burning turf [burning_seeds]"] = candidate

	var/list/interpreted = list()
	var/list/liveness = list()
	for(var/name in inputs)
		dmeow_equiv_read_leaves(name, inputs[name], reference, interpreted)
		dmeow_equiv_read_coupling(name, inputs[name], reference, interpreted)
	for(var/name in trajectory_seeds)
		var/list/stats = dmeow_equiv_trajectory(name, trajectory_seeds[name], interpreted)
		liveness += "[name]: [stats["reacted"]]/[DMEOW_EQUIV_TICKS] steps reacted, [stats["burning"]] over the fire threshold"

	var/list/compile_lines = list()
	var/list/refused = list()
	for(var/proc_name in dmeow_atmos_target_procs() + DMEOW_EQUIV_EXTRA_TARGETS)
		var/ok = dmeow_compile(proc_name)
		if(!ok)
			refused += proc_name
		compile_lines += "[ok ? "compiled" : "REFUSED "] [proc_name]"

	var/deopts_before = dmeow_deopt_count()

	var/list/compiled = list()
	for(var/name in inputs)
		dmeow_equiv_read_leaves(name, inputs[name], reference, compiled)
		dmeow_equiv_read_coupling(name, inputs[name], reference, compiled)
	for(var/name in trajectory_seeds)
		dmeow_equiv_trajectory(name, trajectory_seeds[name], compiled)

	var/deopts_after = dmeow_deopt_count()

	var/list/differences = dmeow_equiv_differences(interpreted, compiled)
	var/list/report = list(
		"DMEOW EQUIVALENCE PROBE",
		"",
		"inputs: [length(inputs)] mixtures ([length(captured)] captured from the burn room)",
		"trajectories: [length(trajectory_seeds)] seeds x [DMEOW_EQUIV_TICKS] react() steps",
		"readings compared: [length(interpreted)]",
		"",
		"compile targets:",
	)
	report += compile_lines
	report += list(
		"",
		"captured mixture temperatures: [num2text(captured_coldest, DMEOW_EQUIV_DIGITS)]K to [num2text(captured_hottest, DMEOW_EQUIV_DIGITS)]K, [captured_burning] over the fire threshold",
		"",
		"trajectory liveness (a trajectory that never reacts agrees with the other arm for free):",
	)
	report += liveness
	report += list(
		"",
		"deopts during the JIT arm: [deopts_after - deopts_before] (want 0 - a deopt hands back to the interpreter, so a nonzero count means those readings prove nothing)",
		"",
		"red phase:",
	)
	report += dmeow_equiv_red_phase(interpreted)
	if(length(refused))
		report += list(
			"",
			"NOT COVERED - these refused to compile, so any reading of them below is the",
			"interpreter compared against itself and says nothing about the JIT:",
		)
		report += refused
	report += list(
		"",
		"VERDICT: [length(differences) ? "TRAJECTORIES AND/OR LEAVES DIFFER - [length(differences)] readings" : "IDENTICAL across all [length(interpreted)] readings"]",
	)
	if(length(differences))
		report += ""
		// every trajectory step after the first divergence differs too, so a real
		// bug prints thousands of lines that all say the same thing.
		report += differences.Copy(1, min(length(differences), DMEOW_EQUIV_MAX_PRINTED) + 1)
		if(length(differences) > DMEOW_EQUIV_MAX_PRINTED)
			report += "... and [length(differences) - DMEOW_EQUIV_MAX_PRINTED] more"

	var/text = jointext(report, "\n")
	var/filename = "[GLOB.log_directory]/dmeow/equiv/[rustg_unix_timestamp()].txt"
	var/probe_file = file(filename)
	probe_file << text
	log_world(text)
	log_world("DMEOW_EQUIV: wrote [filename]")

	dmeow_shutdown()
	finish_dmeow_equiv()

/world/proc/finish_dmeow_equiv()
	SSticker.delay_end = FALSE
	shutdown()

#undef DMEOW_EQUIV_BURN_SECONDS
#undef DMEOW_EQUIV_TICKS
#undef DMEOW_EQUIV_TRAJECTORY_SAMPLES
#undef DMEOW_EQUIV_DIGITS
#undef DMEOW_EQUIV_MAX_PRINTED
#undef DMEOW_EQUIV_EXTRA_TARGETS

#endif

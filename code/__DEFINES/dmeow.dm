// knobs for the dmeow JIT panel and its A/B runs.

/// interpreter calls before dmeow bothers compiling a proc. tuned so the hot set
/// is all compiled by the end of warmup, without cold procs sneaking in.
#define DMEOW_PERF_DEFAULT_THRESHOLD 200
/// times 1 in N calls, per proc. both hooks take their lock every call anyway, so
/// coarser only saves two clock reads. nothing past ~25.
#define DMEOW_PERF_DEFAULT_SAMPLE_RATE 3
/// compile-and-settle before the interleave. all binned, so it only has to
/// outlast the hot set promoting.
#define DMEOW_PERF_DEFAULT_WARMUP 180
/// seconds each arm gets per flip. short on purpose - at 15s a three-second
/// hiccup lands entirely inside one arm and skews it; at 5s it straddles windows
/// of both and the paired sign test absorbs it. keep it a whole number of
/// DMEOW_BURN_RESEED_PERIOD.
#define DMEOW_PERF_DEFAULT_WINDOW 5
/// on/off pairs the interleave runs.
#define DMEOW_PERF_DEFAULT_CYCLES 16

/// most A/B windows the DLL keeps per-proc arm totals for. mirrors MAX_WINDOWS in
/// dmeow's `runtime/profiling.rs`; past it the DLL merges everything further into
/// the last window and drops the per-proc totals, which reads as a normal report
/// rather than an error. one flip per arm per cycle, so the real ceiling is
/// `cycles * 2`.
#define DMEOW_PERF_MAX_WINDOWS 32

/// an arm with fewer samples than this is noise, not a measurement.
#define DMEOW_PERF_MIN_SAMPLES 100
/// arms overlapping less than this in time weren't watching the same workload,
/// however many samples they piled up.
#define DMEOW_PERF_MIN_OVERLAP_PCT 50
/// how many procs the panel ranks each way. the raw JSON keeps the lot.
#define DMEOW_PERF_SUMMARY_ROWS 8
/// 0 means unlimited. report_json always keeps every compiled row regardless, so
/// a cap here silently drops the interpreted rows the panel needs.
#define DMEOW_PERF_REPORT_LIMIT 0
/// per-fire SSair rows kept per round. rows past the cap are counted, not
/// silently dropped - the count is what says the row sum is short.
#define DMEOW_TURF_ROW_LIMIT 4000

/// burn room interior, in turfs. copied off
/// _maps/templates/holodeck_burntest.dmm.
#define DMEOW_BURN_ROOM_SIZE 10
/// seconds between burn room re-seeds. has to divide the A/B window exactly or
/// each arm gets a different amount of work.
#define DMEOW_BURN_RESEED_PERIOD 5
/// turfs between ignition points on each axis. one fire per ~25 interior turfs.
#define DMEOW_IGNITION_SPACING 5

/// turfs the world needs on top of the room's interior edge before a burn round
/// can reserve it: `size + 2` for walls, 2 more for `_reserve_area()`'s cordon,
/// and 32 because a reservation level only offers
/// `world.maxx - 2 * SHUTTLE_TRANSIT_BORDER`.
#define DMEOW_BURN_WORLD_MARGIN 40

/// hot dense half of the gradient room. nitrogen because no reaction in
/// reactions.dm can fire without a second gas, so the room moves gas and heat
/// hard and never catches - which is what makes both arms provably do the same
/// work per turf.
#define DMEOW_GRADIENT_HOT GAS_N2 + "=500;TEMP=1000"
/// cold thin half. ~1000x the pressure ratio against the hot half, so the front
/// keeps moving gas for the whole re-seed period rather than settling in a tick.
#define DMEOW_GRADIENT_COLD GAS_N2 + "=5;TEMP=100"

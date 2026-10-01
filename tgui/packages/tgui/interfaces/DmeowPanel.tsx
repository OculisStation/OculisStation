// THIS IS A OCULIS UI FILE
import hljs from 'highlight.js/lib/core';
import x86asm from 'highlight.js/lib/languages/x86asm';
import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

// hljs 11 throws on an unregistered language name.
hljs.registerLanguage('x86asm', x86asm);

enum Tab {
  Profiling = 1,
  Status,
  Tools,
  Assembly,
}

enum RankingMode {
  Inclusive = 'inclusive',
  Self = 'self',
}

type PerfRow = {
  path: string;
  /** interpreter median / JIT median. the headline number. */
  ratio: number;
  /** same thing on the averages. a big gap against ratio means outliers. */
  avg_ratio: number;
  native_median_ns: number;
  interpreter_median_ns: number;
  native_avg_ns: number;
  interpreter_avg_ns: number;
  native_self_avg_ns: number;
  interpreter_self_avg_ns: number;
  native_samples: number;
  interpreter_samples: number;
  samples: number;
  /**
   * how much the two arms' sample windows overlapped in time. under 50 and they
   * weren't watching the same workload. it can never hit 100 on an alternating
   * run - one arm starts first and the other finishes last, so a clean N-cycle
   * interleave tops out at 1 - 1/N.
   */
  overlap: number;
  confidence: string;
  pairs_won: number;
  pairs_total: number;
  self_ratio: number;
  self_pairs_won: number;
  self_pairs_total: number;
  deopts: number;
  demoted: BooleanLike;
  eligibility: string;
  verdict: string;
};

type Census = {
  compiled: number;
  compile_failed: number;
  rejected_partial_jit: number;
  ineligible: number;
  unclassified: number;
  classified: number;
  compile_attempts: number;
  compile_failures: number;
  compile_ns_total: number;
  wasted_compile_ns: number;
};

type Data = {
  loaded: BooleanLike;
  armed: BooleanLike;
  hooks_enabled: BooleanLike;
  counting_threshold: number;
  sample_rate: number;
  session_active: BooleanLike;
  /** mirrors the phase strings in /datum/dmeow_perf_session. */
  session_phase: 'idle' | 'warmup' | 'interleave' | 'done' | null;
  session_seconds: number;
  phase_seconds_left: number;
  window_index: number;
  window_total: number;
  window_seconds: number;
  load_status: string | null;
  status_text: string | null;
  losses: PerfRow[] | null;
  wins: PerfRow[] | null;
  self_losses: PerfRow[] | null;
  self_wins: PerfRow[] | null;
  below_floor: PerfRow[] | null;
  self_below_floor: PerfRow[] | null;
  compared: number;
  self_compared: number;
  below_floor_count: number;
  self_below_floor_count: number;
  insufficient: number;
  self_insufficient: number;
  total_calls: number;
  reported_calls: number;
  census: Census | null;
  timer_source: string | null;
  resolution_ns: number;
  timer_anomalies: number;
  last_report_file: string | null;
  last_result: string | null;
  asm_proc_path: string | null;
  asm_text: string | null;
  default_threshold: number;
  default_sample_rate: number;
  default_warmup: number;
  default_window: number;
  default_cycles: number;
  min_samples: number;
  min_overlap: number;
  reseed_period: number;
  /** only burn builds compile the profiling side of the panel. */
  profiling_available: BooleanLike;
};

export function DmeowPanel(props) {
  const { data } = useBackend<Data>();
  const { loaded, armed, last_result, profiling_available } = data;
  const [tab, setTab] = useState(
    profiling_available ? Tab.Profiling : Tab.Status,
  );

  return (
    <Window title="dmeow" width={720} height={620}>
      <Window.Content>
        <Stack fill vertical>
          {!loaded && (
            <Stack.Item>
              <LoadNotice />
            </Stack.Item>
          )}
          {!!loaded && !armed && (
            <Stack.Item>
              <NoticeBox danger>
                The JIT refused to arm. Every compile silently returns 0, so
                anything you measure here is the interpreter. Check Status.
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Tabs fluid>
              {!!profiling_available && (
                <Tabs.Tab
                  selected={tab === Tab.Profiling}
                  onClick={() => setTab(Tab.Profiling)}
                >
                  Profiling
                </Tabs.Tab>
              )}
              <Tabs.Tab
                selected={tab === Tab.Status}
                onClick={() => setTab(Tab.Status)}
              >
                Status
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Tools}
                onClick={() => setTab(Tab.Tools)}
              >
                Tools
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Assembly}
                onClick={() => setTab(Tab.Assembly)}
              >
                Assembly
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === Tab.Profiling && <ProfilingTab />}
            {tab === Tab.Status && <StatusTab />}
            {tab === Tab.Tools && <ToolsTab />}
            {tab === Tab.Assembly && <AssemblyTab />}
          </Stack.Item>
          {!!last_result && (
            <Stack.Item>
              <Box color="label" fontSize="0.9em">
                {last_result}
              </Box>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
}

function LoadNotice(props) {
  const { act } = useBackend<Data>();

  return (
    <NoticeBox info>
      <Stack align="center">
        <Stack.Item grow>dmeow is not loaded.</Stack.Item>
        <Stack.Item>
          <Button icon="plug" onClick={() => act('load')}>
            Load
          </Button>
        </Stack.Item>
      </Stack>
    </NoticeBox>
  );
}

function SessionProgress(props) {
  const { data } = useBackend<Data>();
  const {
    session_phase,
    session_seconds,
    phase_seconds_left,
    window_index,
    window_total,
    load_status,
  } = data;

  const inInterleave = session_phase === 'interleave';
  // even window = JIT arm, odd = interpreter. same rule the session datum
  // documents on window_index, so don't flip one without the other.
  const arm = window_index % 2 === 0 ? 'JIT' : 'interpreter';

  return (
    <Box mt={1} color="label">
      {inInterleave
        ? `Window ${window_index + 1} of ${window_total}: ${arm} arm, ${phase_seconds_left}s left. Running ${session_seconds}s.`
        : `Phase: ${session_phase}, ${phase_seconds_left}s left. Running ${session_seconds}s.`}
      {!!load_status && <Box>{load_status}</Box>}
    </Box>
  );
}

function ManualTracking(props) {
  const { act, data } = useBackend<Data>();
  const { loaded, session_active, sample_rate, default_sample_rate } = data;
  const [sampleRate, setSampleRate] = useState(default_sample_rate);
  const tracking = !session_active && sample_rate > 0;

  return (
    <Section title="Manual tracking">
      <Box mb={1} color="label">
        {session_active
          ? 'An A/B run owns the profiler. Stop that run to use manual tracking.'
          : tracking
            ? `Recording 1 in ${sample_rate} calls. Closing this panel keeps tracking.`
            : 'Tracking stopped. Dump report saves any samples already collected.'}
      </Box>
      <LabeledList>
        <LabeledList.Item label="Sample 1 in">
          <NumberInput
            value={tracking ? sample_rate : sampleRate}
            minValue={1}
            maxValue={1000}
            step={1}
            unit="calls"
            width="7rem"
            disabled={!loaded || !!session_active || tracking}
            onChange={setSampleRate}
          />
        </LabeledList.Item>
      </LabeledList>
      <Box mt={1}>
        <Button
          icon="play"
          color="good"
          disabled={!loaded || !!session_active || tracking}
          onClick={() => act('perf_manual_start', { sample_rate: sampleRate })}
        >
          Start tracking
        </Button>
        <Button
          icon="stop"
          disabled={!loaded || !!session_active || !tracking}
          onClick={() => act('perf_manual_stop')}
        >
          Stop tracking
        </Button>
        <Button
          icon="file-arrow-down"
          disabled={!loaded || !!session_active}
          onClick={() => act('perf_collect')}
        >
          Dump report
        </Button>
      </Box>
      <Box mt={1} color="label">
        Start clears previous samples. No warmup, timed JIT switching, or
        synthetic load. Dumping does not stop tracking.
      </Box>
    </Section>
  );
}

function ProfilingTab(props) {
  const { act, data } = useBackend<Data>();
  const {
    loaded,
    sample_rate,
    session_active,
    default_threshold,
    default_sample_rate,
    default_warmup,
    default_window,
    default_cycles,
    reseed_period,
  } = data;

  const [threshold, setThreshold] = useState(default_threshold);
  const [sampleRate, setSampleRate] = useState(default_sample_rate);
  const [warmup, setWarmup] = useState(default_warmup);
  const [windowSeconds, setWindowSeconds] = useState(default_window);
  const [cycles, setCycles] = useState(default_cycles);
  const [burnRoom, setBurnRoom] = useState(false);

  const windowMisaligned = burnRoom && windowSeconds % reseed_period !== 0;

  return (
    <Box height="100%" overflowY="auto">
      <Stack vertical>
        <Stack.Item>
          <ManualTracking />
        </Stack.Item>
        <Stack.Item>
          <Section title="A/B run">
            <LabeledList>
              <LabeledList.Item label="Promote after">
                <NumberInput
                  value={threshold}
                  minValue={5}
                  maxValue={100000}
                  step={25}
                  unit="calls"
                  width="7rem"
                  disabled={!!session_active}
                  onChange={setThreshold}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Sample 1 in">
                <NumberInput
                  value={sampleRate}
                  minValue={1}
                  maxValue={1000}
                  step={1}
                  unit="calls"
                  width="7rem"
                  disabled={!!session_active}
                  onChange={setSampleRate}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Warm up for">
                <NumberInput
                  value={warmup}
                  minValue={0}
                  maxValue={3600}
                  step={30}
                  unit="sec"
                  width="7rem"
                  disabled={!!session_active}
                  onChange={setWarmup}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Window">
                <NumberInput
                  value={windowSeconds}
                  minValue={1}
                  maxValue={300}
                  step={5}
                  unit="sec"
                  width="7rem"
                  disabled={!!session_active}
                  onChange={setWindowSeconds}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Cycles">
                <NumberInput
                  value={cycles}
                  minValue={1}
                  maxValue={16}
                  step={1}
                  unit="pairs"
                  width="7rem"
                  disabled={!!session_active}
                  onChange={setCycles}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Burn room">
                <Button.Checkbox
                  checked={burnRoom}
                  disabled={!!session_active}
                  tooltip="Seal a room full of plasma and oxygen and set it on fire, so both arms measure the same atmos load."
                  onClick={() => setBurnRoom(!burnRoom)}
                >
                  {burnRoom ? 'driving the load' : 'off'}
                </Button.Checkbox>
              </LabeledList.Item>
            </LabeledList>
            {windowMisaligned && (
              <NoticeBox danger mt={1}>
                The window has to be a multiple of {reseed_period}s while the
                burn room is driving, or each arm gets a different amount of
                work.
              </NoticeBox>
            )}
            <Box mt={1}>
              {!session_active ? (
                <Button
                  icon="play"
                  color="good"
                  disabled={!loaded || sample_rate > 0 || windowMisaligned}
                  onClick={() =>
                    act('perf_start', {
                      threshold,
                      sample_rate: sampleRate,
                      warmup,
                      window: windowSeconds,
                      cycles,
                      burn_room: burnRoom,
                    })
                  }
                >
                  Start run
                </Button>
              ) : (
                <>
                  <Button
                    icon="file-arrow-down"
                    onClick={() => act('perf_collect')}
                  >
                    Write report
                  </Button>
                  <Button.Confirm
                    icon="stop"
                    color="bad"
                    onClick={() => act('perf_stop')}
                  >
                    Stop run
                  </Button.Confirm>
                </>
              )}
            </Box>
            {!!session_active && <SessionProgress />}
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Results />
        </Stack.Item>
      </Stack>
    </Box>
  );
}

function Results(props) {
  const { data } = useBackend<Data>();
  const [rankingMode, setRankingMode] = useState(RankingMode.Inclusive);
  const {
    losses,
    wins,
    self_losses,
    self_wins,
    below_floor,
    self_below_floor,
    compared,
    self_compared,
    below_floor_count,
    self_below_floor_count,
    insufficient,
    self_insufficient,
    total_calls,
    reported_calls,
    census,
    timer_source,
    resolution_ns,
    timer_anomalies,
    last_report_file,
    min_samples,
    min_overlap,
  } = data;
  const showingSelf = rankingMode === RankingMode.Self;
  const displayedLosses = showingSelf ? self_losses : losses;
  const displayedWins = showingSelf ? self_wins : wins;
  const displayedBelowFloor = showingSelf ? self_below_floor : below_floor;
  const displayedCompared = showingSelf ? self_compared : compared;
  const displayedBelowFloorCount = showingSelf
    ? self_below_floor_count
    : below_floor_count;
  const displayedInsufficient = showingSelf ? self_insufficient : insufficient;

  if (!last_report_file) {
    return (
      <Section title="Results">
        <Box color="label">
          No report written yet. Dump a report during tracking or after
          stopping.
        </Box>
      </Section>
    );
  }

  return (
    <Section
      title="Results"
      buttons={
        <Stack align="center">
          <Stack.Item>
            <Box color="label" fontSize="0.9em">
              {displayedCompared} comparable, {displayedBelowFloorCount} under
              the clock, {displayedInsufficient} insufficient for comparison
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={showingSelf}
              onClick={() =>
                setRankingMode(
                  showingSelf ? RankingMode.Inclusive : RankingMode.Self,
                )
              }
            >
              {showingSelf ? 'Showing self time' : 'Show self time'}
            </Button>
          </Stack.Item>
        </Stack>
      }
    >
      <Box color="label" fontSize="0.9em" mb={1}>
        <Box>
          {reported_calls} of {total_calls} calls in this report. Clock:{' '}
          {timer_source} at {resolution_ns}ns
          {timer_anomalies > 0 && `, ${timer_anomalies} bad reads`}.
        </Box>
        <Box>
          A row needs {min_samples} samples per arm and {min_overlap}% time
          overlap to count. Overlap never reaches 100 - one arm always starts
          first.
        </Box>
        <Box>
          {showingSelf
            ? 'Rows are ranked by self-time average, with child procs removed.'
            : 'Rows are ranked by inclusive median time, including child procs.'}
        </Box>
        <Box>Raw JSON: {last_report_file}</Box>
        {!displayedCompared && (
          <Box>
            This report has no comparable JIT/interpreter timings. Manual
            tracking may only collect one side; the raw JSON still contains the
            recorded samples.
          </Box>
        )}
      </Box>
      {!!census && <CensusLine census={census} />}
      <RowTable
        title="JIT slower than the interpreter"
        rows={displayedLosses}
        showingSelf={showingSelf}
      />
      <Box mt={1}>
        <RowTable
          title="Biggest wins"
          rows={displayedWins}
          showingSelf={showingSelf}
        />
      </Box>
      {!!displayedBelowFloorCount && (
        <Box mt={1}>
          <Collapsible
            title={`Below the timer's resolution (${displayedBelowFloorCount})`}
          >
            <Box color="label" fontSize="0.9em" mb={0.5}>
              {showingSelf
                ? 'These procs have no measurable self time in one arm. Their ratios are not measurements.'
                : 'These procs run too fast for the current clock to separate the two arms. Their ratios are bucket indices, not measurements.'}
            </Box>
            <RowTable
              title=""
              rows={displayedBelowFloor}
              showingSelf={showingSelf}
            />
          </Collapsible>
        </Box>
      )}
    </Section>
  );
}

function CensusLine(props: { census: Census }) {
  const { census } = props;

  return (
    <Box color="label" fontSize="0.9em" mb={1}>
      {census.compiled} compiled, {census.compile_failed} failed to compile,{' '}
      {census.rejected_partial_jit} rejected as partial, {census.ineligible}{' '}
      ineligible, {census.unclassified} never classified.{' '}
      {Math.round(census.compile_ns_total / 1e6)}ms spent compiling
      {census.wasted_compile_ns > 0 &&
        ` (${Math.round(census.wasted_compile_ns / 1e6)}ms of it on retries)`}
      .
    </Box>
  );
}

function RowTable(props: {
  title: string;
  rows: PerfRow[] | null;
  showingSelf: boolean;
}) {
  const { title, rows, showingSelf } = props;

  if (!rows?.length) {
    return (
      <Box>
        {!!title && <Box bold>{title}</Box>}
        <Box color="label">None.</Box>
      </Box>
    );
  }

  return (
    <Box>
      {!!title && (
        <Box bold mb={0.5}>
          {title}
        </Box>
      )}
      <Table>
        <Table.Row header>
          <Table.Cell>Proc</Table.Cell>
          <Table.Cell collapsing textAlign="right">
            {showingSelf ? 'Interp self avg' : 'Interp med (incl.)'}
          </Table.Cell>
          <Table.Cell collapsing textAlign="right">
            {showingSelf ? 'JIT self avg' : 'JIT med (incl.)'}
          </Table.Cell>
          <Table.Cell collapsing textAlign="right">
            {showingSelf ? 'Self speedup' : 'Speedup'}
          </Table.Cell>
          <Table.Cell collapsing textAlign="right">
            {showingSelf ? 'Incl med ratio' : 'Avg (incl.)'}
          </Table.Cell>
          <Table.Cell collapsing textAlign="right">
            Pairs
          </Table.Cell>
          <Table.Cell collapsing textAlign="right">
            Overlap
          </Table.Cell>
          <Table.Cell collapsing textAlign="right">
            Deopts
          </Table.Cell>
        </Table.Row>
        {rows.map((row) => (
          <Table.Row key={row.path}>
            <Table.Cell>
              {row.path}
              {!!row.demoted && (
                <Box as="span" color="bad">
                  {' (demoted)'}
                </Box>
              )}
              <Box color="label" fontSize="0.85em">
                {row.eligibility}, {row.samples} samples, {row.confidence}
              </Box>
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              {formatNs(
                showingSelf
                  ? row.interpreter_self_avg_ns
                  : row.interpreter_median_ns,
              )}
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              {formatNs(
                showingSelf ? row.native_self_avg_ns : row.native_median_ns,
              )}
            </Table.Cell>
            <Table.Cell
              collapsing
              textAlign="right"
              color={
                (showingSelf ? row.self_ratio : row.ratio) < 1
                  ? 'bad'
                  : (showingSelf ? row.self_ratio : row.ratio) > 2
                    ? 'good'
                    : undefined
              }
            >
              {toFixed(showingSelf ? row.self_ratio : row.ratio, 2)}x
            </Table.Cell>
            <Table.Cell
              collapsing
              textAlign="right"
              // big gap between the median ratio and the average ratio means the
              // average is being carried by outliers, not by the proc.
              color={
                showingSelf
                  ? 'label'
                  : row.avg_ratio > row.ratio * 2 ||
                      row.avg_ratio * 2 < row.ratio
                    ? 'average'
                    : 'label'
              }
            >
              {showingSelf
                ? row.ratio > 0
                  ? `${toFixed(row.ratio, 2)}x`
                  : '-'
                : `${toFixed(row.avg_ratio, 2)}x`}
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              {showingSelf
                ? row.self_pairs_total
                  ? `${row.self_pairs_won}/${row.self_pairs_total}`
                  : '-'
                : row.pairs_total
                  ? `${row.pairs_won}/${row.pairs_total}`
                  : '-'}
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              {row.overlap}%
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              {row.deopts}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Box>
  );
}

function formatNs(ns: number) {
  if (ns >= 100000) {
    return `${Math.round(ns / 1000)}us`;
  }
  if (ns >= 1000) {
    return `${toFixed(ns / 1000, 1)}us`;
  }
  return `${ns}ns`;
}

function StatusTab(props) {
  const { act, data } = useBackend<Data>();
  const {
    armed,
    hooks_enabled,
    counting_threshold,
    sample_rate,
    session_active,
    timer_source,
    resolution_ns,
    status_text,
  } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="State">
          <LabeledList>
            <LabeledList.Item label="JIT" color={armed ? 'good' : 'bad'}>
              {armed ? 'armed' : 'disabled'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Native hooks"
              buttons={
                <Button
                  icon="power-off"
                  selected={hooks_enabled}
                  disabled={!!session_active}
                  tooltip={
                    session_active
                      ? 'A profiling run owns this switch. Flipping it by hand would mislabel every window after this one.'
                      : undefined
                  }
                  onClick={() => act('toggle_hooks')}
                >
                  {hooks_enabled ? 'On' : 'Off'}
                </Button>
              }
            >
              {hooks_enabled ? 'compiled procs are being used' : 'bypassed'}
            </LabeledList.Item>
            <LabeledList.Item label="Promotion">
              {counting_threshold ? `after ${counting_threshold} calls` : 'off'}
            </LabeledList.Item>
            <LabeledList.Item label="Profiler">
              {sample_rate ? `1 in ${sample_rate} calls` : 'off'}
            </LabeledList.Item>
            <LabeledList.Item label="Sample clock">
              {timer_source
                ? `${timer_source}, ${resolution_ns}ns floor`
                : 'unknown until the first report'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Deopt + debug status"
          buttons={
            <Button icon="rotate" onClick={() => act('refresh_status')}>
              Refresh
            </Button>
          }
        >
          {status_text ? (
            <Box preserveWhitespace fontFamily="monospace" fontSize="0.9em">
              {status_text}
            </Box>
          ) : (
            <Box color="label">
              Not read yet. Each read locks the DLL, so it is on demand.
            </Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function ToolsTab(props) {
  const { act, data } = useBackend<Data>();
  const { session_active, profiling_available } = data;
  const [procName, setProcName] = useState('');
  const [marker, setMarker] = useState('');

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="A single proc">
          <Stack align="center">
            <Stack.Item grow>
              <Input
                fluid
                placeholder="/datum/gas_mixture/proc/share"
                value={procName}
                onChange={setProcName}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="microchip"
                disabled={!procName}
                onClick={() => act('compile', { proc_name: procName })}
              >
                Compile
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="file-code"
                disabled={!procName}
                onClick={() => act('bytecode', { proc_name: procName })}
              >
                Bytecode
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Dumps">
          <Button icon="fire" onClick={() => act('compile_atmos')}>
            Compile atmos targets
          </Button>
          <Button icon="list" onClick={() => act('analysis')}>
            Proc analysis
          </Button>
          <Button icon="filter" onClick={() => act('eligible')}>
            Eligibility list
          </Button>
          <Button.Confirm icon="hammer" onClick={() => act('census')}>
            Compile census (stalls!)
          </Button.Confirm>
        </Section>
      </Stack.Item>
      {!!profiling_available && (
        <Stack.Item>
          <Section title="Synthetic load">
            <Button
              icon="fire-flame-curved"
              disabled={!!session_active}
              tooltip="A sealed room of plasma and oxygen, re-seeded on a fixed period. Standalone - a profiling run drives its own."
              onClick={() => act('burn_room')}
            >
              Toggle burn room
            </Button>
          </Section>
        </Stack.Item>
      )}
      <Stack.Item>
        <Section title="Debug log">
          <Stack align="center">
            <Stack.Item>
              <Button icon="hard-drive" onClick={() => act('debug_flush')}>
                Flush
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Input
                fluid
                placeholder="marker text..."
                value={marker}
                onChange={setMarker}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="bookmark"
                disabled={!marker}
                onClick={() => act('debug_marker', { text: marker })}
              >
                Mark
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function AssemblyTab(props) {
  const { act, data } = useBackend<Data>();
  const { asm_proc_path, asm_text } = data;
  const [procName, setProcName] = useState('');

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Optimized x86">
          <Stack align="center">
            <Stack.Item grow>
              <Input
                fluid
                placeholder="/datum/gas_mixture/proc/heat_capacity"
                value={procName}
                onChange={setProcName}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="file-code"
                disabled={!procName}
                onClick={() => act('dump_asm', { proc_name: procName })}
              >
                Dump
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable scrollableHorizontal title={asm_proc_path}>
          {asm_text ? (
            <Box
              as="pre"
              fontSize="0.9em"
              dangerouslySetInnerHTML={{
                __html: hljs.highlight(sanitizeText(asm_text), {
                  language: 'x86asm',
                }).value,
              }}
            />
          ) : (
            <Box color="label">
              Nothing dumped yet. This compiles the proc for real but throws the
              result away, so it stays interpreted either way.
            </Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}

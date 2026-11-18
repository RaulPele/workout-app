#!/bin/bash
# Runs the on-device UI tests against a real iPhone and Apple Watch.
#
#   DeviceTests/run-device-tests.sh <suite> [--app <worktree>] [--no-install]
#
# <suite>          One of the suites listed by --list (see the SUITES section below).
# --app <worktree> The checkout whose iPhone and watch apps get built and installed before the tests run.
#                  Defaults to the checkout this script lives in.
# --no-install     Skip building and installing the apps; test whatever is already on the devices.
# --list           Print the suites and exit.
#
# Device selection: IPHONE_ID and WATCH_ID (UDIDs) override the automatic choice of the first paired
# physical iPhone and Apple Watch.
#
# Output goes to DeviceTests/.results/<timestamp>-<suite>/: report.md, one .xcresult per step, exported
# screenshots, files copied off the devices, and the build logs.

set -uo pipefail

# MARK: - Paths and tools
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_PROJECT="$SCRIPT_DIR/DeviceTests.xcodeproj"
TEST_DERIVED_DATA="$SCRIPT_DIR/.build/tests"
PHONE_BUNDLE_ID="com.pele.raul.WorkoutApp"
WATCH_BUNDLE_ID="com.pele.raul.WorkoutApp.watchkitapp"
WATCH_APP_NAME="WatchWorkoutApp Watch App"

if [[ -z "${DEVELOPER_DIR:-}" ]]; then
    if [[ "$(xcode-select -p)" == *CommandLineTools* ]]; then
        # xcode-select points at the Command Line Tools, which have no xcodebuild or devicectl.
        # Use the newest full Xcode in /Applications for this run only.
        DEVELOPER_DIR="$(ls -d /Applications/Xcode*.app/Contents/Developer 2>/dev/null | sort -V | tail -1)"
        export DEVELOPER_DIR
    fi
fi

# MARK: - Arguments
SUITE=""
APP_DIR="$REPO_DIR"
INSTALL=1
LIST=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --app) APP_DIR="$(cd "$2" && pwd)"; shift 2 ;;
        --no-install) INSTALL=0; shift ;;
        --list) LIST=1; shift ;;
        -h|--help) sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) SUITE="$1"; shift ;;
    esac
done

# MARK: - Reporting
RUN_DIR=""
REPORT=""
FAILED_STEPS=0
STEP_INDEX=0

log() { printf '\033[1m==>\033[0m %s\n' "$*"; }
fail_early() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; [[ -n "$REPORT" ]] && printf '\n**Stopped:** %s\n' "$*" >> "$REPORT"; exit 1; }
report() { printf '%s\n' "$*" >> "$REPORT"; }

# MARK: - Devices
# Picks the first paired physical device of a platform from devicectl's JSON listing.
find_device() {
    local platform="$1" listing="$RUN_DIR/devices.json"
    xcrun devicectl list devices --json-output "$listing" >/dev/null 2>&1 || return 1
    python3 -I - "$listing" "$platform" <<'PY'
import json, sys
devices = json.load(open(sys.argv[1]))["result"]["devices"]
for d in devices:
    hw, cp = d.get("hardwareProperties", {}), d.get("connectionProperties", {})
    if hw.get("platform") == sys.argv[2] and hw.get("reality") == "physical" and cp.get("pairingState") == "paired":
        print(hw.get("udid") or d["identifier"])
        break
PY
}

# Fails unless devicectl can reach the device and it's unlocked; UI tests can't drive a locked screen.
require_reachable() {
    local id="$1" label="$2"
    local out="$RUN_DIR/lockstate-$label.json"
    if ! xcrun devicectl device info lockState --device "$id" --json-output "$out" >/dev/null 2>"$RUN_DIR/lockstate-$label.err"; then
        fail_early "Can't reach the $label ($id). $(tail -1 "$RUN_DIR/lockstate-$label.err") — check it's unlocked, awake, and on the same Wi-Fi as this Mac (or plugged in)."
    fi
    if is_locked "$out"; then
        fail_early "The $label is locked. Unlock it (for the watch: wear it, or turn off Wrist Detection while testing) and run again."
    fi
}

# is_locked <lockState JSON from devicectl> — whether the device needs its passcode.
is_locked() {
    [[ "$(python3 -I -c 'import json,sys; r=json.load(open(sys.argv[1]))["result"]; print(r.get("passcodeRequired", r.get("isLocked", False)))' "$1" 2>/dev/null)" == "True" ]]
}

# MARK: - App build and install
build_and_install_apps() {
    local project="$APP_DIR/WorkoutApp/WorkoutApp.xcodeproj"
    # One build folder per checkout, kept between runs so rebuilding a branch is incremental.
    local dd
    dd="$SCRIPT_DIR/.build/app-$(printf '%s' "$APP_DIR" | shasum | cut -c1-12)"
    [[ -d "$project" ]] || fail_early "No WorkoutApp.xcodeproj under $APP_DIR."
    local branch commit
    branch="$(git -C "$APP_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)"
    commit="$(git -C "$APP_DIR" rev-parse --short HEAD 2>/dev/null)"
    local dirty=""
    [[ -n "$(git -C "$APP_DIR" status --porcelain -- WorkoutApp 2>/dev/null)" ]] && dirty=" + uncommitted changes"
    report "- **App under test:** \`$branch\` at \`$commit\`$dirty ($APP_DIR)"

    log "Building the iPhone app (with the embedded watch app) from $branch"
    if ! xcodebuild build -project "$project" -scheme WorkoutApp -configuration Debug \
        -destination "id=$IPHONE_ID" -derivedDataPath "$dd" -allowProvisioningUpdates \
        > "$RUN_DIR/app-build.log" 2>&1; then
        grep -E 'error:' "$RUN_DIR/app-build.log" | head -10 >&2
        fail_early "The app build failed; see app-build.log."
    fi
    local phone_app="$dd/Build/Products/Debug-iphoneos/WorkoutApp.app"
    local watch_app="$phone_app/Watch/$WATCH_APP_NAME.app"
    [[ -d "$watch_app" ]] || watch_app="$dd/Build/Products/Debug-watchos/$WATCH_APP_NAME.app"

    log "Installing on the iPhone"
    xcrun devicectl device install app --device "$IPHONE_ID" "$phone_app" > "$RUN_DIR/install-phone.log" 2>&1 \
        || fail_early "Installing on the iPhone failed; see install-phone.log."
    # Installing the iPhone app makes iOS push the embedded watch app to the watch by itself. A direct
    # install while that push runs fails with "a coordinated install exists", so wait and retry; the
    # direct install is what guarantees this exact build ends up on the watch.
    log "Installing on the watch (this can take a few minutes over Wi-Fi)"
    local attempt
    for attempt in 1 2 3 4 5 6 7 8; do
        if xcrun devicectl --timeout 900 device install app --device "$WATCH_ID" "$watch_app" > "$RUN_DIR/install-watch.log" 2>&1; then
            return 0
        fi
        grep -q 'coordinated install exists\|IXErrorDomain error 48' "$RUN_DIR/install-watch.log" || break
        log "The iPhone is still pushing the watch app; retrying in 30 s (attempt $attempt)"
        sleep 30
    done
    fail_early "Installing on the watch failed; see install-watch.log."
}

build_tests() {
    log "Building the UI tests"
    xcodebuild build-for-testing -project "$TEST_PROJECT" -scheme PhoneUITests \
        -destination "id=$IPHONE_ID" -derivedDataPath "$TEST_DERIVED_DATA" -allowProvisioningUpdates \
        > "$RUN_DIR/tests-build-phone.log" 2>&1 || fail_early "Building the iPhone UI tests failed; see tests-build-phone.log."
    xcodebuild build-for-testing -project "$TEST_PROJECT" -scheme WatchUITests \
        -destination "id=$WATCH_ID" -derivedDataPath "$TEST_DERIVED_DATA" -allowProvisioningUpdates \
        > "$RUN_DIR/tests-build-watch.log" 2>&1 || fail_early "Building the watch UI tests failed; see tests-build-watch.log."
}

# MARK: - Steps
# Each step adds a numbered line to the report. A failed step is recorded and the suite carries on;
# steps that depend on an earlier one are guarded in the suite and reported as skipped.

# Sets STEP_NO to the next two-digit step number. It doesn't print it: $(next_step) would run in a
# subshell and the counter would never advance.
next_step() {
    STEP_INDEX=$((STEP_INDEX + 1))
    STEP_NO="$(printf '%02d' "$STEP_INDEX")"
}

# Waits up to 5 minutes for devicectl to reach the device. The watch turns its Wi-Fi off when its screen
# sleeps and nothing is driving it, e.g. right after the crash step; raising the wrist or tapping the
# screen brings it back.
wait_until_reachable() {
    local id="$1" label="$2" waited=0 state last=""
    local out="$RUN_DIR/lockstate-$label.json"
    while :; do
        state=unreachable
        if xcrun devicectl --timeout 30 device info lockState --device "$id" --json-output "$out" >/dev/null 2>&1; then
            state=unlocked
            is_locked "$out" && state=locked
        fi
        [[ "$state" == unlocked ]] && break
        if [[ $waited -ge 300 ]]; then
            log "The $label is still $state after ${waited}s; trying the test anyway"
            return 1
        fi
        if [[ "$state" != "$last" ]]; then
            # A locked device makes the UI test runner fail with "Authentication canceled by user".
            if [[ "$state" == locked ]]; then
                log "The $label is locked; unlock it to continue (for the watch: wear it, or turn off Wrist Detection while testing)"
            else
                log "Waiting for the $label to come back on the network (wake its screen if this takes long)"
            fi
            last="$state"
        fi
        sleep 15
        waited=$((waited + 45))
    done
    [[ $waited -gt 0 ]] && log "The $label is ready again"
    return 0
}

# The latest value any earlier step noted for a key, e.g. `note_value template`.
note_value() {
    cat "$RUN_DIR"/*.notes 2>/dev/null | grep "^$1=" | tail -1 | cut -d= -f2-
}

# Records a step that didn't run because one it depends on failed.
skip_step() {
    local device="$1" what="$2" why="$3" n
    next_step; n="$STEP_NO"
    report "| $n | $device | $what | ⏭️ skipped: $why | |"
}

# ui_test [--informational] <phone|watch> <TestClass/testMethod> [KEY=VALUE ...] — runs one UI test on
# one device. An informational step's failure is reported but doesn't fail the run.
ui_test() {
    local informational=0
    if [[ "$1" == "--informational" ]]; then informational=1; shift; fi
    local device="$1" test="$2"; shift 2
    local n scheme id
    next_step; n="$STEP_NO"
    if [[ "$device" == "phone" ]]; then scheme=PhoneUITests; id="$IPHONE_ID"; else scheme=WatchUITests; id="$WATCH_ID"; fi
    local name="$n-$device-${test//\//-}"
    local bundle="$RUN_DIR/$name.xcresult" logfile="$RUN_DIR/$name.log"
    log "Step $n: $device test $test"

    local env_args=()
    local pair
    for pair in "$@"; do env_args+=("TEST_RUNNER_$pair"); done

    local started=$SECONDS status attempt
    for attempt in 1 2; do
        wait_until_reachable "$id" "$device"
        rm -rf "$bundle"
        env ${env_args[@]+"${env_args[@]}"} xcodebuild test-without-building -project "$TEST_PROJECT" -scheme "$scheme" \
            -destination "id=$id" -derivedDataPath "$TEST_DERIVED_DATA" \
            -only-testing:"$scheme/$test" -resultBundlePath "$bundle" > "$logfile" 2>&1
        status=$?
        # A watch that dozed off between steps drops its Wi-Fi link, and one that locked makes the test
        # runner fail to start UI automation; neither is the test failing.
        [[ $status -ne 0 ]] && grep -qE 'Timed out waiting for all destinations|Failed to initialize for UI testing' "$logfile" || break
        log "The $device was asleep or locked when the test started; retrying"
    done
    local elapsed=$((SECONDS - started))

    # Notes the test printed for the report, e.g. the start time of a workout it saved.
    # Each note shows up twice (stdout and activity title), so drop repeats but keep the order.
    sed -n 's/.*DEVICETEST_NOTE //p' "$logfile" | tr -d '\r' | awk '!seen[$0]++' > "$RUN_DIR/$name.notes"
    if [[ -d "$bundle" ]]; then
        xcrun xcresulttool export attachments --path "$bundle" --output-path "$RUN_DIR/$name-attachments" >/dev/null 2>&1
    fi

    if [[ $status -eq 0 ]]; then
        report "| $n | $device | \`$test\` | ✅ passed | ${elapsed}s |"
    else
        local reason marker="❌ failed"
        reason="$(grep -E 'error: -\[|: error: |XCTAssert|Timed out|failed \(' "$logfile" | grep -v '^Testing failed' | head -2 | sed -E 's/.*error: //; s/\|/\\|/g' | tr '\n' ' ')"
        [[ -z "$reason" ]] && reason="$(grep -E 'xcodebuild: error|Unable to|isn.t|not connected|locked' "$logfile" | head -1 | sed 's/|/\\|/g')"
        if [[ $informational -eq 1 ]]; then
            marker="ℹ️ failed (informational)"
        else
            FAILED_STEPS=$((FAILED_STEPS + 1))
        fi
        report "| $n | $device | \`$test\` | $marker: ${reason:-see $name.log} | ${elapsed}s |"
    fi
    return $status
}

# app_action <phone|watch> <terminate|crash|launch> — changes the app's process state between tests.
app_action() {
    local device="$1" action="$2" n id bundle
    next_step; n="$STEP_NO"
    if [[ "$device" == "phone" ]]; then id="$IPHONE_ID"; bundle="$PHONE_BUNDLE_ID"; else id="$WATCH_ID"; bundle="$WATCH_BUNDLE_ID"; fi
    log "Step $n: $action the $device app"
    local result="✅ done"
    case "$action" in
        launch)
            xcrun devicectl device process launch --device "$id" --terminate-existing "$bundle" > "$RUN_DIR/$n-$device-launch.log" 2>&1 \
                || result="❌ failed: see $n-$device-launch.log"
            ;;
        terminate|crash)
            # SIGKILL looks like a crash to the system, which is what HealthKit's workout recovery reacts to.
            # "terminate" uses SIGTERM, the closest thing to the app being stopped normally.
            local signal=SIGTERM pid
            [[ "$action" == "crash" ]] && signal=SIGKILL
            pid="$(app_pid "$id" "$bundle")"
            if [[ -z "$pid" ]]; then
                result="⚠️ the app wasn't running"
            elif ! xcrun devicectl device process signal --device "$id" --pid "$pid" --signal "$signal" > "$RUN_DIR/$n-$device-$action.log" 2>&1; then
                result="❌ failed: see $n-$device-$action.log"
            else
                result="✅ sent $signal to pid $pid"
            fi
            ;;
    esac
    [[ "$result" == ❌* ]] && FAILED_STEPS=$((FAILED_STEPS + 1))
    report "| $n | $device | $action app | $result | |"
}

# The app's process id, found by its executable path (devicectl lists executables, not bundle ids).
app_pid() {
    local id="$1" bundle="$2" out="$RUN_DIR/processes.json" name=WorkoutApp
    [[ "$bundle" == "$WATCH_BUNDLE_ID" ]] && name="$WATCH_APP_NAME"
    xcrun devicectl device info processes --device "$id" --json-output "$out" >/dev/null 2>&1 || return 0
    python3 -I - "$out" "$name" <<'PY'
import json, sys
from urllib.parse import unquote
suffix = "/{0}.app/{0}".format(sys.argv[2])
for p in json.load(open(sys.argv[1]))["result"].get("runningProcesses", []):
    if unquote(p.get("executable", "")).endswith(suffix):
        print(p["processIdentifier"])
        break
PY
}

# pull_files <phone|watch> <folder inside the app's data container> [expect-empty] — lists and copies
# the folder's .json files off the device. With expect-empty, any file left there fails the step.
pull_files() {
    local device="$1" source="$2" expectation="${3:-}" n id bundle
    next_step; n="$STEP_NO"
    if [[ "$device" == "phone" ]]; then id="$IPHONE_ID"; bundle="$PHONE_BUNDLE_ID"; else id="$WATCH_ID"; bundle="$WATCH_BUNDLE_ID"; fi
    local dest="$RUN_DIR/$n-$device-files"
    mkdir -p "$dest"
    log "Step $n: list $source on the $device"
    local count=0 result
    if xcrun devicectl device info files --device "$id" --domain-type appDataContainer --domain-identifier "$bundle" \
        --subdirectory "$source" > "$dest/listing.txt" 2>&1; then
        count="$(grep -c '\.json' "$dest/listing.txt")"
        if [[ "$count" -gt 0 ]]; then
            xcrun devicectl device copy from --device "$id" --domain-type appDataContainer --domain-identifier "$bundle" \
                --source "$source" --destination "$dest" >/dev/null 2>&1
        fi
        result="📄 $count file(s), listing in $n-$device-files/"
    else
        result="📄 folder doesn't exist (nothing was ever left in it)"
    fi
    if [[ "$expectation" == "expect-empty" && "$count" -gt 0 ]]; then
        FAILED_STEPS=$((FAILED_STEPS + 1))
        result="❌ $count file(s) still waiting, expected none; see $n-$device-files/"
    elif [[ "$expectation" == "expect-empty" ]]; then
        result="✅ empty: ${result#📄 }"
    fi
    report "| $n | $device | \`$source\` | $result | |"
}

screenshot() {
    local device="$1" label="$2" n id
    next_step; n="$STEP_NO"
    if [[ "$device" == "phone" ]]; then id="$IPHONE_ID"; else id="$WATCH_ID"; fi
    local file="$RUN_DIR/$n-$device-$label.png"
    if xcrun devicectl device capture screenshot --device "$id" --destination "$file" >/dev/null 2>&1; then
        report "| $n | $device | screenshot: $label | 📷 $(basename "$file") | |"
    else
        report "| $n | $device | screenshot: $label | ⚠️ capture failed | |"
    fi
}

pause_for() {
    local seconds="$1" why="$2" n
    next_step; n="$STEP_NO"
    log "Step $n: wait ${seconds}s ($why)"
    sleep "$seconds"
    report "| $n | – | wait ${seconds}s: $why | | |"
}

# MARK: - Suites
# Each suite names the branch it was written for. The steps run in order; a failed step doesn't stop
# the ones after it, so one run reports every check.

# TEMPLATE=<name> in the environment picks the watch template; otherwise each test uses the first one.
TEMPLATE_ARG=()
[[ -n "${TEMPLATE:-}" ]] && TEMPLATE_ARG=("TEMPLATE=$TEMPLATE")

suite_smoke() {
    ui_test phone PhoneSmokeTests/testAppLaunches
    ui_test watch WatchSmokeTests/testAppLaunches
}

# Branch worktree-refactor+watch-app, session "Watch redesign: fix data loss & stuck end flow".
suite_watch_redesign() {
    # Fixes 1 and 2: ending from Controls keeps the logged sets; the summary opens on End.
    if ui_test watch RedesignedWatchWorkoutTests/testEndingFromControlsKeepsLoggedSets ${TEMPLATE_ARG[@]+"${TEMPLATE_ARG[@]}"}; then
        # This branch's iPhone app is main's, which only lists sessions that match a Health workout
        # from the iPhone app's own source, so a miss here isn't a failure of the watch fixes.
        ui_test --informational phone PhoneHistoryTests/testWatchSessionAppearsInHistory \
            "TEMPLATE=$(note_value template)" "WORKOUT_START=$(note_value workout_start)" "EXPECTED_SETS=2" "SYNC_TIMEOUT=240"
    else
        skip_step phone "History shows the 2 sets" "the watch step failed"
    fi

    # Fix 5: the rest countdown freezes while paused and ends by itself.
    ui_test watch RedesignedWatchWorkoutTests/testRestCountdownFreezesWhilePaused ${TEMPLATE_ARG[@]+"${TEMPLATE_ARG[@]}"}

    # Fix 4: a crash mid-workout keeps the logged sets.
    if ui_test watch RedesignedWatchWorkoutTests/testCrashRecoveryStep1LogSetsAndLeaveRunning ${TEMPLATE_ARG[@]+"${TEMPLATE_ARG[@]}"}; then
        app_action watch crash
        pause_for 3 "let watchOS handle the crash"
        ui_test watch RedesignedWatchWorkoutTests/testCrashRecoveryStep2RelaunchKeepsLoggedSets \
            "EXPECTED_SETS=$(note_value expected_sets)" "TEMPLATE=$(note_value template)" \
            "CRASH_WORKOUT_START=$(note_value crash_workout_start)"
    else
        skip_step watch "crash and relaunch" "setting up the workout failed"
    fi
}

# Branch fix/sessions-without-healthkit, session "Show watch sessions without a HealthKit match".
suite_sessions_without_healthkit() {
    if ui_test watch ClassicWatchWorkoutTests/testShortWorkoutEndedFromControls ${TEMPLATE_ARG[@]+"${TEMPLATE_ARG[@]}"}; then
        # The session must show up without waiting for Health to sync the workout to the iPhone, and
        # the detail always shows the heart-rate and calorie tiles ("–" until Health data matches).
        ui_test phone PhoneHistoryTests/testWatchSessionAppearsInHistory \
            "TEMPLATE=$(note_value template)" "WORKOUT_START=$(note_value workout_start)" \
            "EXPECTED_SETS=0" "HEALTH_TILES=always" "SYNC_TIMEOUT=120"
    else
        skip_step phone "History shows the session" "the watch workout failed"
    fi
}

# Branch fix/watch-sync-reliability, session "Watch/phone communication review".
suite_sync_reliability() {
    # Fix 1: the iPhone app starting must not blank the watch's template list. First the watch wakes
    # the stopped iPhone app in the background, then the iPhone app is opened normally.
    app_action phone terminate
    ui_test watch ClassicWatchWorkoutTests/testTemplateListStaysFilled "OBSERVE_SECONDS=30"
    app_action phone launch
    ui_test watch ClassicWatchWorkoutTests/testTemplateListStaysFilled "RELAUNCH=0" "OBSERVE_SECONDS=30"

    # Fixes 3 and 4: a workout sent while the iPhone app isn't running is written to the inbox, saved,
    # and listed in History without waiting for a Health match.
    app_action phone terminate
    if ui_test watch ClassicWatchWorkoutTests/testShortWorkoutEndedFromControls ${TEMPLATE_ARG[@]+"${TEMPLATE_ARG[@]}"}; then
        pause_for 30 "let the transfer reach the iPhone"
        pull_files phone "Library/Application Support/PendingWorkoutSessions"
        ui_test phone PhoneHistoryTests/testWatchSessionAppearsInHistory \
            "TEMPLATE=$(note_value template)" "WORKOUT_START=$(note_value workout_start)" \
            "EXPECTED_SETS=0" "SYNC_TIMEOUT=120"
        pull_files phone "Library/Application Support/PendingWorkoutSessions" expect-empty
    else
        skip_step phone "inbox and History checks" "the watch workout failed"
    fi
}

SUITES="smoke watch-redesign sessions-without-healthkit sync-reliability"
describe_suite() {
    case "$1" in
        smoke) echo "Launches both installed apps once. Checks the devices, signing and test runners work." ;;
        watch-redesign) echo "worktree-refactor+watch-app: end from Controls keeps sets, rest pauses with the workout, crash recovery." ;;
        sessions-without-healthkit) echo "fix/sessions-without-healthkit: a watch session shows in History before Health matches it." ;;
        sync-reliability) echo "fix/watch-sync-reliability: watch template list survives the iPhone app starting; inbox delivers workouts." ;;
    esac
}

# MARK: - Main
if [[ $LIST -eq 1 || -z "$SUITE" ]]; then
    echo "Suites:"
    for s in $SUITES; do printf '  %-28s %s\n' "$s" "$(describe_suite "$s")"; done
    [[ -z "$SUITE" && $LIST -eq 0 ]] && echo && echo "Usage: $0 <suite> [--app <worktree>] [--no-install]"
    exit 0
fi
case " $SUITES " in *" $SUITE "*) ;; *) echo "Unknown suite '$SUITE'. Run with --list." >&2; exit 2 ;; esac

RUN_DIR="$SCRIPT_DIR/.results/$(date +%Y%m%d-%H%M%S)-$SUITE"
mkdir -p "$RUN_DIR"
REPORT="$RUN_DIR/report.md"
report "# Device test run: $SUITE"
report ""
report "- **Started:** $(date '+%Y-%m-%d %H:%M:%S %Z')"
report "- **Suite:** $(describe_suite "$SUITE")"
report "- **Xcode:** $DEVELOPER_DIR"

IPHONE_ID="${IPHONE_ID:-$(find_device iOS)}"
WATCH_ID="${WATCH_ID:-$(find_device watchOS)}"
[[ -n "$IPHONE_ID" ]] || fail_early "No paired physical iPhone found (xcrun devicectl list devices)."
[[ -n "$WATCH_ID" ]] || fail_early "No paired physical Apple Watch found (xcrun devicectl list devices)."
report "- **iPhone:** $IPHONE_ID"
report "- **Watch:** $WATCH_ID"

log "Checking the devices are reachable and unlocked"
require_reachable "$IPHONE_ID" iPhone
require_reachable "$WATCH_ID" watch

[[ $INSTALL -eq 1 ]] && build_and_install_apps
build_tests

report ""
report "| # | Device | Step | Result | Time |"
report "|---|---|---|---|---|"
"suite_${SUITE//-/_}"

report ""
report "## Workouts this run started on the watch"
report ""
report "Each is in Apple Health if it got as far as being ended; the outcomes below say how each one ended."
report "Delete them in the Fitness or Health app if you don't want them. The tests never delete anything."
report ""
started="$(cat "$RUN_DIR"/*.notes 2>/dev/null | grep -E '^(health_workout|workout_outcome)=' | cut -d= -f2-)"
if [[ -n "$started" ]]; then
    while IFS= read -r line; do
        case "$line" in started*) report "- $line" ;; *) report "  - ended: $line" ;; esac
    done <<< "$started"
else
    report "None."
fi

report ""
report "## Notes from the tests"
report ""
notes="$(cat "$RUN_DIR"/*.notes 2>/dev/null | grep -vE '^(health_workout|workout_outcome)=')"
if [[ -n "$notes" ]]; then
    while IFS= read -r line; do report "- \`${line%%=*}\`: ${line#*=}"; done <<< "$notes"
else
    report "None."
fi
report ""
report "- **Finished:** $(date '+%Y-%m-%d %H:%M:%S %Z')"

log "Report: $REPORT"
if [[ $FAILED_STEPS -gt 0 ]]; then
    log "$FAILED_STEPS step(s) failed"
    exit 1
fi
log "All steps passed"

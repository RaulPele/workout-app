import XCTest

/// Checks the fixes on `worktree-refactor+watch-app` (session "Watch redesign: fix data loss & stuck end
/// flow") against a real watch and real HealthKit. Each test that ends a workout saves it to Apple Health
/// and notes its start time for the report.
///
/// Optional run parameters: `TEMPLATE` picks the template by name; otherwise the first one is used. The
/// rest test needs a first exercise with at least 2 sets, the others at least 2 sets in total.
final class RedesignedWatchWorkoutTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Fixes 1 and 2: ending from Controls mid-exercise keeps the logged sets, and the summary opens as
    /// soon as End is tapped, then ends as saved or "Not Saved" with a way out.
    @MainActor
    func testEndingFromControlsKeepsLoggedSets() throws {
        let watch = RedesignedWatchApp(test: self)
        try watch.launchToTemplateList()
        let workout = try watch.startWorkout()
        try watch.controls.waitUntilRunning()

        try watch.logSets(2)
        attachScreenshot("After logging 2 sets")
        // XCUITest's tap only returns once the app settles, which here is after saving, so this can't
        // time the summary's appearance; the test's screen recording shows it.
        let tapped = try watch.controls.endWorkout()
        let delay = try watch.waitForSummary(after: tapped)
        RunReport.note("summary_after_end_tap_returned", String(format: "%.1f s", delay))

        let result = try watch.finishSummary()
        RunReport.savedWorkout(template: workout.template, start: workout.start, outcome: result.saved ? "saved" : "Not Saved")
        XCTAssertTrue(result.saved, "The workout wasn't saved to Apple Health (the summary showed Not Saved)")
        XCTAssertEqual(result.setsLogged, 2, "The summary should count both logged sets")
        RunReport.note("expected_sets", "2")
    }

    /// Fix 5: the rest countdown is driven by WorkoutManager, freezes while the workout is paused,
    /// carries on after resuming, and ends by itself.
    @MainActor
    func testRestCountdownFreezesWhilePaused() throws {
        let watch = RedesignedWatchApp(test: self)
        try watch.launchToTemplateList()
        let workout = try watch.startWorkout()
        try watch.controls.waitUntilRunning()

        try watch.logSet()
        guard watch.isResting, let beforePause = watch.restRemaining() else {
            throw failure("No rest started after the first set. Use a template whose first exercise has 2+ sets (TEMPLATE=<name>).", app: watch.app)
        }
        try watch.controls.show()
        try watch.controls.pause()
        guard let pausedAt = watch.restRemaining() else {
            throw failure("The rest countdown wasn't showing after pausing", app: watch.app)
        }
        idle(10)
        let afterTenSeconds = watch.restRemaining()
        attachScreenshot("Rest 10 s into the pause")
        RunReport.note("rest_countdown", "\(beforePause) s before pause, \(pausedAt) s paused, \(afterTenSeconds.map(String.init) ?? "?") s after 10 s paused")
        XCTAssertNotNil(afterTenSeconds, "The countdown disappeared while paused")
        if let afterTenSeconds {
            XCTAssertLessThanOrEqual(abs(afterTenSeconds - pausedAt), 1, "The rest countdown kept running while the workout was paused")
        }

        try watch.controls.resume()
        idle(4)
        guard let afterResume = watch.restRemaining() else {
            throw failure("The rest ended or vanished right after resuming", app: watch.app)
        }
        XCTAssertLessThan(afterResume, afterTenSeconds ?? pausedAt, "The countdown didn't carry on after resuming")

        // Let the rest finish by itself if that's a reasonable wait; otherwise skip it.
        if afterResume <= 150 {
            let ended = waitUntil(timeout: TimeInterval(afterResume + 20), pollEvery: 3) { !watch.isResting }
            RunReport.note("rest_ended_by_itself", ended ? "yes, about \(afterResume) s after resuming" : "no")
            XCTAssertTrue(ended, "The rest didn't end by itself when the countdown ran out")
        } else {
            RunReport.note("rest_ended_by_itself", "not checked: \(afterResume) s left, skipped instead")
            try watch.skipRest()
        }

        let tapped = try watch.controls.endWorkout()
        _ = try watch.waitForSummary(after: tapped)
        let result = try watch.finishSummary()
        RunReport.savedWorkout(template: workout.template, start: workout.start, outcome: result.saved ? "saved" : "Not Saved")
        XCTAssertEqual(result.setsLogged, 1, "The summary should count the one logged set")
    }

    /// Fix 4, part 1: starts a workout, logs 2 sets and leaves it running. The run script then kills the
    /// app (SIGKILL, like a crash) before part 2.
    @MainActor
    func testCrashRecoveryStep1LogSetsAndLeaveRunning() throws {
        let watch = RedesignedWatchApp(test: self)
        try watch.launchToTemplateList()
        let workout = try watch.startWorkout()
        try watch.controls.waitUntilRunning()
        try watch.logSets(2)
        attachScreenshot("Running with 2 logged sets, before the crash")
        RunReport.note("expected_sets", "2")
        RunReport.note("crash_workout_start", RunReport.iso8601(workout.start))
    }

    /// Fix 4, part 2: after the crash, opening the app must bring the 2 logged sets back, either by
    /// reattaching to the HealthKit session or through the "Unfinished Workout" prompt. Ends and saves
    /// the workout and checks the summary still counts the sets.
    @MainActor
    func testCrashRecoveryStep2RelaunchKeepsLoggedSets() throws {
        let expectedSets = RunParameter.int("EXPECTED_SETS") ?? 2
        let template = RunParameter.value("TEMPLATE") ?? "unknown template"
        let crashedWorkoutStart = RunParameter.date("CRASH_WORKOUT_START") ?? Date()
        let watch = RedesignedWatchApp(test: self)

        // activate(), not launch(): launch() would kill an instance the system relaunched for recovery.
        watch.app.activate()
        var screen: [ScreenElement] = []
        let settled = waitUntil(timeout: Timeout.healthKit, pollEvery: 2) {
            screen = watch.app.screen()
            return screen.has("Unfinished Workout") || watch.isActiveWorkout(screen) || watch.isSummary(screen)
                || watch.isTemplateList(screen)
        }
        guard settled else { throw failure("The watch app showed nothing recognisable after the crash", app: watch.app) }
        attachScreenshot("First screen after the crash")

        var resumedStart: Date?
        if screen.has("Unfinished Workout") {
            RunReport.note("recovery_path", "Unfinished Workout prompt (HealthKit session didn't survive)")
            let message = screen.labels(containing: "logged sets").first ?? ""
            XCTAssertTrue(message.contains("\(expectedSets) logged sets"), "The prompt should mention \(expectedSets) logged sets, it said: \(message)")
            try require(watch.app.buttons["Resume"], "Resume in the Unfinished Workout prompt", in: watch.app).tap()
            resumedStart = Date()
            guard waitUntil(timeout: Timeout.healthKit, { watch.isActiveWorkout(watch.app.screen()) }) else {
                throw failure("Resume didn't reopen the workout", app: watch.app)
            }
            try watch.controls.waitUntilRunning()
        } else if watch.isActiveWorkout(screen) {
            RunReport.note("recovery_path", "reattached to the running HealthKit session")
        } else if watch.isSummary(screen) {
            RunReport.note("recovery_path", "the recovered session had stopped, so the app went straight to the summary")
        } else {
            throw failure("After the crash the app opened on the workout list with no prompt: the \(expectedSets) logged sets were lost", app: watch.app)
        }

        if !watch.isSummary(watch.app.screen()) {
            if watch.isResting { try watch.skipRest() }
            attachScreenshot("Workout after recovery")
            let tapped = try watch.controls.endWorkout()
            _ = try watch.waitForSummary(after: tapped)
        }
        let result = try watch.finishSummary()
        let outcome = result.saved ? "saved" : "Not Saved"
        RunReport.savedWorkout(template: template, start: crashedWorkoutStart, outcome: "\(outcome) after crash recovery")
        if let resumedStart {
            RunReport.note("resume_started_new_session", RunReport.iso8601(resumedStart))
        }
        XCTAssertEqual(result.setsLogged, expectedSets, "The summary after recovery should still count the \(expectedSets) sets logged before the crash")
    }
}

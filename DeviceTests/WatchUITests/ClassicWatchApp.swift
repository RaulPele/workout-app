import XCTest

// MARK: - Classic watch app
/// Drives the watch app as it is on `main` (also on `fix/watch-sync-reliability` and
/// `fix/sessions-without-healthkit`): an untitled list of template names, a paged workout screen with
/// Controls on the left, and a summary sheet with "Total Time" and "Done".
@MainActor
struct ClassicWatchApp {
    let app = XCUIApplication(bundleIdentifier: AppUnderTest.watchBundleID)
    let test: XCTestCase
    var controls: WatchControls { WatchControls(app: app, test: test) }

    // MARK: - Template list
    /// Starts the app fresh (or brings it forward with `relaunch: false`) and waits up to `timeout` for
    /// the template list to have rows. Returns the row count, 0 if the list stayed empty.
    func openTemplateList(relaunch: Bool = true, timeout: TimeInterval = 30) throws -> Int {
        if relaunch { app.launch() } else { app.activate() }
        var rows = 0
        _ = test.waitUntil(timeout: timeout, pollEvery: 2) {
            let screen = app.screen()
            rows = templateRowCount(screen)
            return rows > 0 || screen.hasLabel(containing: "not authorized to access HealthKit") || isInWorkout(screen)
        }
        let screen = app.screen()
        if screen.hasLabel(containing: "not authorized to access HealthKit") {
            throw test.failure("The watch app has no Health access. Allow it once on the watch, then rerun.", app: app)
        }
        if isInWorkout(screen) {
            throw test.failure("A workout from an earlier run is still open on the watch. Finish it on the watch, then rerun.", app: app)
        }
        return rows
    }

    /// Template rows are the only buttons on the list screen.
    func templateRowCount(_ screen: [ScreenElement]) -> Int {
        screen.filter { $0.type == .button }.count
    }

    // MARK: - Workout
    /// Taps a template (the requested one, or the first) and waits until the HealthKit session runs.
    func startWorkout(named requested: String? = RunParameter.value("TEMPLATE")) throws -> (template: String, start: Date) {
        let row: XCUIElement
        if let requested {
            row = app.buttons[requested]
            for _ in 0..<10 where !row.isHittable { app.swipeUp() }
            guard row.exists else { throw test.failure("No template named \(requested) on the watch", app: app) }
        } else {
            guard let first = app.firstOnScreen(app.buttons) else { throw test.failure("No template rows on the watch", app: app) }
            row = first
        }
        let name = row.label
        let start = Date()
        row.tap()
        guard test.waitUntil(timeout: Timeout.ui, { isInWorkout(app.screen()) || app.screen().hasLabel(containing: "bpm") }) else {
            throw test.failure("The workout screen for \(name) never appeared", app: app)
        }
        try controls.waitUntilRunning()
        RunReport.note("template", name)
        RunReport.note("workout_start", RunReport.iso8601(start))
        RunReport.startedWorkout(template: name, start: start)
        return (name, start)
    }

    /// Ends the workout from Controls, waits for the summary, taps Done, and returns whether the summary
    /// showed the saved workout's metrics.
    func endAndDismissSummary() throws -> Bool {
        try controls.endWorkout()
        var screen: [ScreenElement] = []
        let summary = test.waitUntil(timeout: Timeout.healthKit) {
            screen = app.screen(onScreenOnly: false)
            return screen.has("Total Time") || screen.has("Saving Workout")
        }
        guard summary else {
            throw test.failure("No summary after End. On this version that means saving to Health failed.", app: app)
        }
        let saved = test.waitUntil(timeout: Timeout.healthKit) { app.screen(onScreenOnly: false).has("Total Time") }
        test.attachScreenshot("Watch summary")
        guard saved else { throw test.failure("The summary stayed on Saving Workout", app: app) }

        let done = app.buttons["Done"]
        for _ in 0..<6 where !done.isHittable { app.swipeUp() }
        try test.require(done, "the summary's Done button", in: app).tap()
        guard test.waitUntil(timeout: Timeout.ui, { templateRowCount(app.screen()) > 0 }) else {
            throw test.failure("Done didn't return to the template list", app: app)
        }
        return saved
    }

    func isInWorkout(_ screen: [ScreenElement]) -> Bool {
        screen.has("Pause") || screen.has("Resume") || screen.has("End set") || screen.has("End rest")
            || screen.has("Saving Workout") || screen.has("Total Time")
    }
}

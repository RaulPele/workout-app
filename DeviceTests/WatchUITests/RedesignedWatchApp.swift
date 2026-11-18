import XCTest

// MARK: - Redesigned watch app
/// Drives the redesigned watch app (branch `worktree-refactor+watch-app`): "Workouts" list, exercise page
/// with "Set N of M", a log sheet with "Save Set", a rest countdown with "Skip", and a summary sheet.
@MainActor
struct RedesignedWatchApp {
    let app = XCUIApplication(bundleIdentifier: AppUnderTest.watchBundleID)
    let test: XCTestCase
    var controls: WatchControls { WatchControls(app: app, test: test) }

    static let setCaptionPattern = "Set [0-9]+ of [0-9]+"
    static let countdownPattern = "[0-9]+:[0-9]{2}"

    // MARK: - Launch
    /// Starts the app fresh and waits for the template list. Throws, without touching anything, if a
    /// workout from an earlier run is still active or waiting to be resumed.
    func launchToTemplateList() throws {
        app.launch()
        var screen: [ScreenElement] = []
        let settled = test.waitUntil(timeout: Timeout.ui) {
            screen = app.screen()
            return isTemplateList(screen) || isBlocking(screen) || screen.has("No Workouts") || screen.has("Unable to Load")
        }
        guard settled else { throw test.failure("The watch app didn't show its workout list", app: app) }
        if screen.hasLabel(containing: "not authorized to access HealthKit") {
            throw test.failure("The watch app has no Health access. Allow it once on the watch, then rerun.", app: app)
        }
        if screen.has("Unfinished Workout") || isActiveWorkout(screen) || isSummary(screen) {
            throw test.failure("A workout from an earlier run is still open on the watch. Finish it on the watch, then rerun.", app: app)
        }
        if screen.has("No Workouts") || screen.has("Unable to Load") {
            throw test.failure("The watch has no workout templates. Open the iPhone app once so it sends them.", app: app)
        }
    }

    // MARK: - Starting
    /// Taps a template (the requested one, or the first) and waits for its first set. Returns the
    /// template's name and when it was tapped.
    func startWorkout(named requested: String? = RunParameter.value("TEMPLATE")) throws -> (template: String, start: Date) {
        let row = try templateRow(named: requested)
        let name = row.label
        let start = Date()
        row.tap()
        var screen: [ScreenElement] = []
        let started = test.waitUntil(timeout: Timeout.healthKit) {
            screen = app.screen()
            return screen.firstLabel(matching: Self.setCaptionPattern) != nil
                || screen.has("Couldn't Start Workout") || screen.has("No Exercises")
        }
        if screen.has("Couldn't Start Workout") {
            throw test.failure("The watch showed Couldn't Start Workout for \(name)", app: app)
        }
        if screen.has("No Exercises") {
            throw test.failure("\(name) has no exercises. Pick another template with TEMPLATE=<name>.", app: app)
        }
        guard started else { throw test.failure("The workout screen for \(name) never appeared", app: app) }
        RunReport.note("template", name)
        RunReport.note("workout_start", RunReport.iso8601(start))
        RunReport.startedWorkout(template: name, start: start)
        return (name, start)
    }

    // MARK: - Sets and rest
    /// The current "Set N of M" caption as numbers, if the exercise page is showing.
    func currentSet() -> (number: Int, total: Int)? {
        guard let caption = app.screen().firstLabel(matching: Self.setCaptionPattern) else { return nil }
        let numbers = caption.split(separator: " ").compactMap { Int($0) }
        return numbers.count == 2 ? (numbers[0], numbers[1]) : nil
    }

    /// Logs the current set with the sheet's default reps and weight, then waits for the app to move on
    /// (rest, the next set or exercise, or the summary after the last set).
    func logSet() throws {
        guard let before = app.screen().firstLabel(matching: Self.setCaptionPattern) else {
            throw test.failure("No \"Set N of M\" caption to log", app: app)
        }
        // After the first set the log button is a text button "End"; before it, a checkmark icon
        // captioned "End" next to Swap. On the last exercise it's the text button from the start.
        guard let logButton = app.firstOnScreen(app.buttons.labeled("End")) ?? app.button(above: "End") else {
            throw test.failure("No button to log \(before)", app: app)
        }
        logButton.tap()
        try test.require(app.buttons["Save Set"], "the Save Set button in the log sheet", in: app).tap()

        // The set is logged once the sheet has finished closing.
        let moved = test.waitUntil(timeout: Timeout.ui) {
            let screen = app.screen()
            guard !screen.has("Save Set") else { return false }
            return screen.has("Rest") || isSummary(screen)
                || (screen.firstLabel(matching: Self.setCaptionPattern).map { $0 != before } ?? false)
        }
        guard moved else { throw test.failure("\(before) didn't log after tapping Save Set", app: app) }
    }

    var isResting: Bool { app.screen().has("Rest") }

    /// Seconds left on the rest countdown, if it's showing.
    func restRemaining() -> Int? {
        guard let text = app.screen().firstLabel(matching: Self.countdownPattern) else { return nil }
        let parts = text.split(separator: ":").compactMap { Int($0) }
        return parts.count == 2 ? parts[0] * 60 + parts[1] : nil
    }

    func skipRest() throws {
        try test.require(app.buttons["Skip"], "the Skip button on the rest screen", in: app).tap()
        guard test.waitUntil(timeout: Timeout.ui, { !isResting }) else {
            throw test.failure("Tapping Skip didn't end the rest", app: app)
        }
    }

    /// Logs sets until `count` have been logged, skipping the rest between them. Leaves any rest that
    /// follows the last one running.
    func logSets(_ count: Int) throws {
        for index in 1...count {
            if isResting { try skipRest() }
            try logSet()
            if isSummary(app.screen()), index < count {
                throw test.failure("The template ran out of sets after \(index); pick a longer one with TEMPLATE=<name>", app: app)
            }
        }
    }

    // MARK: - Summary
    /// Waits for the summary sheet's first state after End. Returns seconds from `tapped` until it showed.
    func waitForSummary(after tapped: Date) throws -> TimeInterval {
        guard test.waitUntil(timeout: Timeout.ui, pollEvery: 0.5, { isSummary(app.screen()) }) else {
            throw test.failure("The summary didn't open after End", app: app)
        }
        return Date().timeIntervalSince(tapped)
    }

    /// Waits for saving to finish, reads the outcome, taps Done and waits for the workout list.
    func finishSummary() throws -> (saved: Bool, setsLogged: Int?) {
        var screen: [ScreenElement] = []
        let done = test.waitUntil(timeout: Timeout.healthKit) {
            screen = app.screen(onScreenOnly: false)
            return screen.has("Sets Logged") || screen.has("Not Saved")
        }
        guard done else { throw test.failure("The summary stayed on Saving Workout", app: app) }
        test.attachScreenshot("Watch summary")
        let saved = screen.has("Sets Logged")
        let sets = screen.label(after: "Sets Logged").flatMap { Int($0.filter(\.isNumber)) }

        let doneButton = app.buttons["Done"]
        for _ in 0..<6 where !doneButton.isHittable { app.swipeUp() }
        try test.require(doneButton, "the summary's Done button", in: app).tap()
        guard test.waitUntil(timeout: Timeout.ui, { isTemplateList(app.screen()) }) else {
            throw test.failure("Done didn't return to the workout list", app: app)
        }
        return (saved, sets)
    }

    // MARK: - Screen checks
    func isTemplateList(_ screen: [ScreenElement]) -> Bool {
        screen.has("Workouts") && !isActiveWorkout(screen) && !isSummary(screen)
    }

    func isActiveWorkout(_ screen: [ScreenElement]) -> Bool {
        screen.firstLabel(matching: Self.setCaptionPattern) != nil || screen.has("Rest")
            || screen.has("Pause") || screen.has("Resume")
    }

    /// "Sets Logged" is the fourth metric and sits below the fold, so the saved state is recognised by
    /// "Total Time", the first one.
    func isSummary(_ screen: [ScreenElement]) -> Bool {
        screen.has("Saving Workout") || screen.has("Total Time") || screen.has("Sets Logged") || screen.has("Not Saved")
    }

    private func isBlocking(_ screen: [ScreenElement]) -> Bool {
        screen.has("Unfinished Workout") || isActiveWorkout(screen) || isSummary(screen)
            || screen.hasLabel(containing: "not authorized to access HealthKit")
    }

    private func templateRow(named requested: String?) throws -> XCUIElement {
        if let requested {
            let row = app.buttons[requested]
            for _ in 0..<10 where !row.isHittable { app.swipeUp() }
            guard row.exists else { throw test.failure("No template named \(requested) on the watch", app: app) }
            return row
        }
        guard let row = app.firstOnScreen(app.buttons.matching(NSPredicate(format: "label != '' AND label != 'Retry'"))) else {
            throw test.failure("No template rows on the watch", app: app)
        }
        return row
    }
}

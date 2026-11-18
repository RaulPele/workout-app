import XCTest

/// Watch-side steps for the branches that keep `main`'s watch UI: `fix/watch-sync-reliability` (session
/// "Watch/phone communication review") and `fix/sessions-without-healthkit`. The checks that matter for
/// those fixes happen on the iPhone or in what the watch receives from it.
final class ClassicWatchWorkoutTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Sync fix 1: the watch's template list must never go blank because the iPhone app started and
    /// pushed its empty, not-yet-loaded list. The run script starts or kills the iPhone app around this
    /// test; the test opens the list and watches it for `OBSERVE_SECONDS` (default 30).
    ///
    /// `RELAUNCH=0` keeps the watch app's current instance instead of starting it fresh.
    @MainActor
    func testTemplateListStaysFilled() throws {
        let watch = ClassicWatchApp(test: self)
        let relaunch = RunParameter.value("RELAUNCH") != "0"
        let observeFor = TimeInterval(RunParameter.int("OBSERVE_SECONDS") ?? 30)

        let initialRows = try watch.openTemplateList(relaunch: relaunch)
        guard initialRows > 0 else {
            throw failure("The watch's template list was empty after 30 s", app: watch.app)
        }
        attachScreenshot("Template list at the start")

        var fewest = initialRows
        var emptyAt: TimeInterval?
        var unreadable = 0
        let started = Date()
        while Date().timeIntervalSince(started) < observeFor {
            // A blank list has no labelled elements, the same as a snapshot taken while the screen is
            // asleep, so only count readings taken while the app is frontmost.
            guard watch.app.state == .runningForeground, let screen = watch.app.screenIfReadable() else {
                unreadable += 1
                idle(1)
                continue
            }
            let rows = watch.templateRowCount(screen)
            fewest = min(fewest, rows)
            if rows == 0, emptyAt == nil {
                emptyAt = Date().timeIntervalSince(started)
                attachScreenshot("Template list went empty")
            }
            idle(1)
        }
        RunReport.note("watch_template_rows", "\(initialRows) at start, fewest \(fewest) over \(Int(observeFor)) s (\(unreadable) unreadable readings)")
        if let emptyAt {
            XCTFail("The watch's template list went empty \(Int(emptyAt)) s into watching")
        }
    }

    /// Runs a short workout and ends it from Controls, so the watch sends the session to the iPhone.
    /// `DURATION` sets how long it runs in seconds (default 20).
    @MainActor
    func testShortWorkoutEndedFromControls() throws {
        let watch = ClassicWatchApp(test: self)
        guard try watch.openTemplateList() > 0 else {
            throw failure("The watch had no templates to start", app: watch.app)
        }
        let workout = try watch.startWorkout()
        idle(TimeInterval(RunParameter.int("DURATION") ?? 20))
        attachScreenshot("Workout before ending")
        let saved = try watch.endAndDismissSummary()
        RunReport.savedWorkout(template: workout.template, start: workout.start, outcome: saved ? "saved" : "not saved")
        RunReport.note("expected_sets", "0")
    }
}

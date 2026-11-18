import XCTest

// MARK: - Controls page
/// The Controls page is the same in both watch UIs: icon buttons captioned "End" and "Pause"/"Resume",
/// to the left of the main workout page. Pausing, resuming or the session starting to run sends the
/// pager back to the main page.
@MainActor
struct WatchControls {
    let app: XCUIApplication
    let test: XCTestCase

    /// Swipes to the Controls page if it isn't showing.
    func show() throws {
        if isShowing(app.screen()) { return }
        app.swipeRight()
        guard test.waitUntil(timeout: Timeout.short, { isShowing(app.screen()) }) else {
            throw test.failure("Swiping right didn't open the Controls page", app: app)
        }
    }

    /// Waits until HealthKit reports the session as running, shown by the Controls caption changing from
    /// "Resume" to "Pause". Leaves the pager on the main workout page.
    func waitUntilRunning() throws {
        let running = test.waitUntil(timeout: Timeout.healthKit, pollEvery: 2) {
            let screen = app.screen()
            if screen.has("Pause") { return true }
            if !screen.has("Resume") { app.swipeRight() }
            return false
        }
        guard running else {
            throw test.failure("The workout never started running: Controls kept showing Resume", app: app)
        }
        app.swipeLeft()
    }

    func pause() throws {
        try tap(caption: "Pause")
        guard test.waitUntil(timeout: Timeout.ui, { !app.screen().has("Pause") }) else {
            throw test.failure("Tapping Pause didn't pause the workout", app: app)
        }
    }

    func resume() throws {
        try show()
        try tap(caption: "Resume")
        guard test.waitUntil(timeout: Timeout.ui, { !app.screen().has("Resume") }) else {
            throw test.failure("Tapping Resume didn't resume the workout", app: app)
        }
    }

    /// Taps End on the Controls page. Returns when it was tapped.
    @discardableResult
    func endWorkout() throws -> Date {
        try show()
        try tap(caption: "End")
        return Date()
    }

    // MARK: - Private
    private func isShowing(_ screen: [ScreenElement]) -> Bool {
        screen.has("Pause") || screen.has("Resume")
    }

    private func tap(caption: String) throws {
        try show()
        guard let button = app.button(above: caption) else {
            throw test.failure("No button above the \"\(caption)\" caption on the Controls page", app: app)
        }
        button.tap()
    }
}

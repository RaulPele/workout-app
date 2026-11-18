import XCTest

final class WatchSmokeTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Confirms the runner can launch the installed watch app. Every other watch test relies on this.
    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication(bundleIdentifier: AppUnderTest.watchBundleID)
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: Timeout.ui), "The watch app didn't reach the foreground")
        attachScreenshot("Watch app after launch")
    }
}

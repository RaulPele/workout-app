import XCTest

final class PhoneSmokeTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Confirms the runner can launch the installed iPhone app. Every other phone test relies on this.
    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication(bundleIdentifier: AppUnderTest.phoneBundleID)
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: Timeout.ui), "The iPhone app didn't reach the foreground")
        attachScreenshot("iPhone app after launch")
    }
}

import XCTest

// MARK: - iPhone app
/// Drives the iPhone app's History tab. Assumes the iPhone is signed in and Health access was granted
/// once; it never taps Authorize or Sign in itself.
@MainActor
struct PhoneApp {
    let app = XCUIApplication(bundleIdentifier: AppUnderTest.phoneBundleID)
    let test: XCTestCase

    /// Brings the app forward without restarting it, so a save that a background launch started can
    /// finish, then opens History.
    func openHistory() throws {
        app.activate()
        let historyTab = app.tabBars.buttons["History"]
        var screen: [ScreenElement] = []
        let ready = test.waitUntil(timeout: Timeout.ui) {
            if historyTab.exists { return true }
            screen = app.screen()
            return screen.has("Authorize") || screen.has("Sign in to continue")
        }
        if screen.has("Authorize") {
            throw test.failure("The iPhone app is asking for Health access. Grant it once on the iPhone, then rerun.", app: app)
        }
        if screen.has("Sign in to continue") {
            throw test.failure("The iPhone app is signed out. Sign in once on the iPhone, then rerun.", app: app)
        }
        guard ready else { throw test.failure("The iPhone app's tab bar never appeared", app: app) }
        historyTab.tap()
        try test.require(app.navigationBars["History"], "the History screen", in: app)
    }

    /// The History card for a session: matches the template name, optionally the set count, and when
    /// start times are given, one of them. Cards are single buttons whose label joins all their text.
    func sessionCard(template: String, sets: Int?, startTimes: [String]) -> XCUIElement? {
        var predicate = NSPredicate(format: "label CONTAINS %@", template)
        if let sets {
            // "(?<![0-9])" keeps "2 sets" from matching "12 sets".
            let setsPredicate = NSPredicate(format: "label MATCHES %@", "(?s).*(?<![0-9])\(sets) sets.*")
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, setsPredicate])
        }
        let cards = app.buttons.matching(predicate).allElementsBoundByIndex
        if startTimes.isEmpty { return cards.first }
        return cards.first { card in startTimes.contains { card.label.contains($0) } }
    }

    func pullToRefresh() {
        let scrollView = app.scrollViews.firstMatch
        guard scrollView.exists else { return }
        let top = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let bottom = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
        top.press(forDuration: 0.05, thenDragTo: bottom)
    }

    /// Opens a session's detail screen and returns every stat tile's label, e.g. "2/9, sets".
    func openDetail(of card: XCUIElement, template: String) throws -> [String] {
        card.tap()
        try test.require(app.navigationBars[template], "the session detail screen", in: app)
        test.attachScreenshot("Session detail")
        let screen = app.screen(onScreenOnly: false)
        return ["duration", "sets", "volume", "avg bpm", "active kcal"].compactMap { tile in
            screen.labels(containing: tile).first
        }
    }

    func goBack() {
        let back = app.navigationBars.buttons.firstMatch
        if back.exists { back.tap() }
    }
}

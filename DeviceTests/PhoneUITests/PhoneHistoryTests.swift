import XCTest

/// iPhone-side checks that a session finished on the watch arrives and shows correctly in History.
///
/// Run parameters (set by the run script from the watch test's notes):
/// - `TEMPLATE` (required): the template the watch workout used.
/// - `WORKOUT_START`: when the watch test started it (ISO 8601). Narrows the match to that start time.
/// - `EXPECTED_SETS`: the set count the card and detail must show.
/// - `HEALTH_TILES=always`: the detail must show "avg bpm" and "active kcal" even without Health data
///   (the `fix/sessions-without-healthkit` behaviour, which shows "–" instead of hiding them).
/// - `SYNC_TIMEOUT`: seconds to wait for the session (default 180).
final class PhoneHistoryTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testWatchSessionAppearsInHistory() throws {
        guard let template = RunParameter.value("TEMPLATE") else {
            throw DeviceTestFailure(message: "TEMPLATE wasn't passed in; run this through run-device-tests.sh")
        }
        let expectedSets = RunParameter.int("EXPECTED_SETS")
        let startTimes = RunParameter.date("WORKOUT_START").map(Self.cardStartTimes) ?? []
        let timeout = TimeInterval(RunParameter.int("SYNC_TIMEOUT") ?? Int(Timeout.sync))
        let phone = PhoneApp(test: self)

        try phone.openHistory()
        let started = Date()
        var card: XCUIElement?
        let found = waitUntil(timeout: timeout, pollEvery: 5) {
            card = phone.sessionCard(template: template, sets: expectedSets, startTimes: startTimes)
            if card == nil { phone.pullToRefresh() }
            return card != nil
        }
        guard found, let card else {
            let anyMatch = phone.sessionCard(template: template, sets: nil, startTimes: startTimes)
            let hint = anyMatch.map { " A card for that workout exists but reads: \($0.label)" } ?? ""
            throw failure("No History card for \(template)\(expectedSets.map { " with \($0) sets" } ?? "") after \(Int(timeout)) s.\(hint)", app: phone.app)
        }
        let waited = Int(Date().timeIntervalSince(started))
        RunReport.note("history_card", "appeared \(waited) s after opening History: \(card.label)")
        attachScreenshot("History with the session")

        let tiles = try phone.openDetail(of: card, template: template)
        RunReport.note("detail_tiles", tiles.joined(separator: " | "))
        if let expectedSets {
            let setsTile = tiles.first { $0.contains("sets") } ?? ""
            XCTAssertTrue(setsTile.contains("\(expectedSets)/"), "The sets tile should start at \(expectedSets), it reads: \(setsTile)")
        }
        if RunParameter.value("HEALTH_TILES") == "always" {
            XCTAssertTrue(tiles.contains { $0.contains("avg bpm") }, "The avg bpm tile should always show")
            XCTAssertTrue(tiles.contains { $0.contains("active kcal") }, "The active kcal tile should always show")
            let healthTiles = tiles.filter { $0.contains("avg bpm") || $0.contains("active kcal") }
            RunReport.note("health_values", healthTiles.contains { $0.contains("–") } ? "shown as – (no Health data matched yet)" : "filled from Health")
        }
        phone.goBack()
    }

    /// The card shows the start time as `.dateTime.hour().minute()`. The watch test notes when it tapped
    /// Start, and HealthKit's start is a little later, so allow the next couple of minutes too.
    private static func cardStartTimes(around start: Date) -> [String] {
        (-1...2).map { start.addingTimeInterval(TimeInterval($0 * 60)).formatted(.dateTime.hour().minute()) }
    }
}

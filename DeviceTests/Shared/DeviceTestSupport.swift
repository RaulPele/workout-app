import XCTest

// MARK: - Apps under test
/// The tests drive the apps already installed on the devices, so they launch them by bundle identifier.
/// `run-device-tests.sh` builds and installs the apps from whichever branch is being tested first.
enum AppUnderTest {
    static let phoneBundleID = "com.pele.raul.WorkoutApp"
    static let watchBundleID = "com.pele.raul.WorkoutApp.watchkitapp"
}

// MARK: - Timeouts
enum Timeout {
    /// An element that should already be on screen.
    static let short: TimeInterval = 5
    /// A screen transition or a sheet appearing.
    static let ui: TimeInterval = 20
    /// HealthKit starting or saving a workout session on a real watch.
    static let healthKit: TimeInterval = 60
    /// A WatchConnectivity transfer between the real watch and iPhone, plus Health syncing the workout.
    static let sync: TimeInterval = 180
}

// MARK: - Run parameters
/// Values the run script passes in. `xcodebuild` forwards every `TEST_RUNNER_<NAME>` variable to the
/// test runner as `<NAME>`.
enum RunParameter {
    static func value(_ name: String) -> String? {
        let value = ProcessInfo.processInfo.environment[name]
        return value?.isEmpty == false ? value : nil
    }

    static func int(_ name: String) -> Int? {
        value(name).flatMap(Int.init)
    }

    static func date(_ name: String) -> Date? {
        value(name).flatMap { try? Date($0, strategy: .iso8601) }
    }
}

// MARK: - Reporting
/// Lines starting with this marker are picked out of the `xcodebuild` log by the run script. Later steps
/// receive them as run parameters, and the report lists them, e.g. every workout a test saved to Health.
@MainActor
enum RunReport {
    /// Prints the note and records it as an activity. On a physical device `xcodebuild` doesn't always
    /// echo the runner's stdout, but it always logs activity titles.
    static func note(_ key: String, _ value: String) {
        let line = "DEVICETEST_NOTE \(key)=\(value)"
        print(line)
        XCTContext.runActivity(named: line) { _ in }
    }

    /// Records a workout as soon as its HealthKit session starts, so the report lists it for deletion
    /// even if the test fails before ending it.
    static func startedWorkout(template: String, start: Date) {
        let time = start.formatted(date: .abbreviated, time: .standard)
        note("health_workout", "started \(time) · \(template)")
    }

    /// Records how a workout ended; the report pairs it with the start time.
    static func savedWorkout(template: String, start: Date, outcome: String) {
        let time = start.formatted(date: .abbreviated, time: .standard)
        note("workout_outcome", "\(time) · \(template) · \(outcome)")
    }

    static func iso8601(_ date: Date) -> String {
        date.formatted(.iso8601)
    }
}

// MARK: - Waiting
extension XCTestCase {
    /// Polls a condition until it's true or the timeout passes. Returns whether it became true.
    @MainActor
    func waitUntil(timeout: TimeInterval, pollEvery interval: TimeInterval = 1, _ condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(interval))
        }
        return condition()
    }

    /// Lets time pass without touching the device.
    @MainActor
    func idle(_ seconds: TimeInterval) {
        RunLoop.current.run(until: Date().addingTimeInterval(seconds))
    }
}

// MARK: - Failure evidence
extension XCTestCase {
    /// Attaches a screenshot of the device to the result bundle so a step can be inspected afterwards.
    @MainActor
    func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Attaches the element tree; this is what to read when a label in the tests doesn't match the app.
    @MainActor
    func attachElementTree(of app: XCUIApplication, _ name: String) {
        let tree = XCTAttachment(string: app.debugDescription)
        tree.name = name
        tree.lifetime = .keepAlways
        add(tree)
    }

    /// Attaches a screenshot and the element tree, and returns an error to throw. Tests throw it rather
    /// than calling `XCTFail`, so execution stops at the failing step and the message is the test's result.
    @MainActor
    func failure(_ message: String, app: XCUIApplication) -> DeviceTestFailure {
        attachScreenshot("Failure: \(message)")
        attachElementTree(of: app, "Element tree: \(message)")
        return DeviceTestFailure(message: message)
    }

    /// Waits for an element and throws with evidence attached if it never appears.
    @MainActor
    @discardableResult
    func require(
        _ element: XCUIElement,
        _ description: String,
        in app: XCUIApplication,
        timeout: TimeInterval = Timeout.ui
    ) throws -> XCUIElement {
        if element.waitForExistence(timeout: timeout) {
            return element
        }
        throw failure("Timed out after \(Int(timeout)) s waiting for \(description)", app: app)
    }
}

struct DeviceTestFailure: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

// MARK: - Element queries
extension XCUIElementQuery {
    /// Matches elements whose label is exactly the text.
    func labeled(_ text: String) -> XCUIElementQuery {
        matching(NSPredicate(format: "label == %@", text))
    }

    /// Matches elements whose label contains the text, ignoring case.
    func containing(_ text: String) -> XCUIElementQuery {
        matching(NSPredicate(format: "label CONTAINS[c] %@", text))
    }

    /// Matches elements whose whole label matches the regular expression.
    func matchingPattern(_ pattern: String) -> XCUIElementQuery {
        matching(NSPredicate(format: "label MATCHES %@", pattern))
    }
}

// MARK: - Screen snapshots
/// One element of a snapshot: enough to check what's on screen without a query per element.
/// On a watch every query is a round trip over Wi-Fi, so the tests read the whole tree once per check.
struct ScreenElement {
    let type: XCUIElement.ElementType
    let label: String
    let frame: CGRect
}

extension Array where Element == ScreenElement {
    func has(_ label: String) -> Bool {
        contains { $0.label == label }
    }

    func hasLabel(containing text: String) -> Bool {
        contains { $0.label.localizedCaseInsensitiveContains(text) }
    }

    /// The first label that matches the whole regular expression.
    func firstLabel(matching pattern: String) -> String? {
        first { $0.label.range(of: "^\(pattern)$", options: .regularExpression) != nil }?.label
    }

    func labels(containing text: String) -> [String] {
        filter { $0.label.localizedCaseInsensitiveContains(text) }.map(\.label)
    }

    /// The label that comes right after the given one in tree order, e.g. a summary metric's value.
    func label(after title: String) -> String? {
        guard let index = firstIndex(where: { $0.label == title }), index + 1 < count else { return nil }
        return self[index + 1].label
    }
}

extension XCUIApplication {
    /// Every labelled element, read in one snapshot. By default only elements whose centre is on screen.
    @MainActor
    func screen(onScreenOnly: Bool = true) -> [ScreenElement] {
        screenIfReadable(onScreenOnly: onScreenOnly) ?? []
    }

    /// Like `screen()`, but nil when the snapshot itself failed, as opposed to a screen with no labels.
    @MainActor
    func screenIfReadable(onScreenOnly: Bool = true) -> [ScreenElement]? {
        guard let root = try? snapshot() else { return nil }
        let bounds = Self.screenFrame(of: root)
        var elements: [ScreenElement] = []
        func walk(_ node: any XCUIElementSnapshot) {
            let nodeFrame = node.frame
            let visible = !nodeFrame.isEmpty && bounds.contains(CGPoint(x: nodeFrame.midX, y: nodeFrame.midY))
            if !node.label.isEmpty, visible || !onScreenOnly {
                elements.append(ScreenElement(type: node.elementType, label: node.label, frame: nodeFrame))
            }
            node.children.forEach(walk)
        }
        walk(root)
        return elements
    }
}

extension XCUIApplication {
    /// The screen's frame. Not the application's own `frame`: that is its main window's, and while a
    /// sheet is up on the watch the main window is a 6 × 48 pt strip at the edge (the scroll indicator),
    /// so every element would count as off screen. The largest window covers the whole screen.
    @MainActor
    static func screenFrame(of root: any XCUIElementSnapshot) -> CGRect {
        root.children
            .filter { $0.elementType == .window }
            .map { $0.frame }
            .max { $0.width * $0.height < $1.width * $1.height } ?? root.frame
    }

    /// The screen's frame, read in one snapshot.
    @MainActor
    var screenFrame: CGRect {
        guard let root = try? snapshot() else { return frame }
        return Self.screenFrame(of: root)
    }

    /// Whether the element's centre is inside the screen. Pages of a paged `TabView` that aren't showing
    /// stay in the element tree with frames off to the side, so `exists` alone isn't enough. Pass
    /// `screen` when checking several elements, to read the screen's frame once.
    @MainActor
    func isOnScreen(_ element: XCUIElement, screen: CGRect? = nil) -> Bool {
        guard element.exists else { return false }
        let elementFrame = element.frame
        guard !elementFrame.isEmpty else { return false }
        return (screen ?? screenFrame).contains(CGPoint(x: elementFrame.midX, y: elementFrame.midY))
    }

    /// The first element of the query that is on screen.
    @MainActor
    func firstOnScreen(_ query: XCUIElementQuery) -> XCUIElement? {
        let screen = screenFrame
        return query.allElementsBoundByIndex.first { isOnScreen($0, screen: screen) }
    }

    /// The icon-only button drawn directly above a caption. The watch app captions its icon buttons with
    /// a separate `Text` ("End", "Pause", "Swap"), so the caption isn't the button's accessibility label.
    @MainActor
    func button(above caption: String) -> XCUIElement? {
        guard let captionElement = firstOnScreen(staticTexts.labeled(caption)) else { return nil }
        let captionFrame = captionElement.frame
        let screen = screenFrame
        return buttons.allElementsBoundByIndex
            .filter { isOnScreen($0, screen: screen) && $0.frame.midY < captionFrame.midY }
            .min { distance($0.frame, captionFrame) < distance($1.frame, captionFrame) }
    }

    private func distance(_ button: CGRect, _ caption: CGRect) -> CGFloat {
        abs(button.midX - caption.midX) + abs(button.maxY - caption.minY)
    }
}

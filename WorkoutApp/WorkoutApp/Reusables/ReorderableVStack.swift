//
//  ReorderableVStack.swift
//  WorkoutApp
//
//  Created by Raul Pele on 08.04.2026.
//

import SwiftUI

// MARK: - Element Position
struct ElementPosition: Equatable, Sendable {
    let min: CGFloat
    let max: CGFloat

    var span: CGFloat { max - min }

    func contains(_ value: CGFloat) -> Bool {
        value >= min && value <= max
    }

    init(_ frame: CGRect) {
        self.min = frame.minY
        self.max = frame.maxY
    }
}

// MARK: - Position Preference Key
private struct PositionPreference: PreferenceKey {
    static let defaultValue: ElementPosition? = nil
    static func reduce(value: inout ElementPosition?, nextValue: () -> ElementPosition?) {
        value = nextValue() ?? value
    }
}

// MARK: - Drag Callbacks (Environment)
private struct ReorderDragCallbacks {
    let coordinateSpaceName: String
    let onDrag: (DragGesture.Value) -> Void
    let onDrop: () -> Void
}

private struct ReorderDragCallbacksKey: EnvironmentKey {
    static let defaultValue: ReorderDragCallbacks? = nil
}

extension EnvironmentValues {
    fileprivate var reorderDragCallbacks: ReorderDragCallbacks? {
        get { self[ReorderDragCallbacksKey.self] }
        set { self[ReorderDragCallbacksKey.self] = newValue }
    }
}

// MARK: - Drag Handle Modifier
private struct ReorderDragHandleModifier: ViewModifier {
    @Environment(\.reorderDragCallbacks) private var callbacks

    func body(content: Content) -> some View {
        if let callbacks {
            content
                .gesture(
                    LongPressGesture(minimumDuration: 0.15)
                        .sequenced(before: DragGesture(
                            minimumDistance: 0,
                            coordinateSpace: .named(callbacks.coordinateSpaceName)
                        ))
                        .onChanged { value in
                            switch value {
                            case .second(true, let drag):
                                if let drag {
                                    callbacks.onDrag(drag)
                                }
                            default:
                                break
                            }
                        }
                        .onEnded { _ in
                            callbacks.onDrop()
                        }
                )
        } else {
            content
        }
    }
}

extension View {
    func reorderDragHandle() -> some View {
        modifier(ReorderDragHandleModifier())
    }
}

// MARK: - ReorderableVStack
struct ReorderableVStack<Data: RandomAccessCollection, Content: View>: View
where Data.Element: Identifiable, Data.Index == Int {

    let data: Data
    let spacing: CGFloat
    let onMove: (Int, Int) -> Void
    let content: (Data.Element, Bool) -> Content

    @State private var positions: [Data.Element.ID: ElementPosition] = [:]
    @State private var dragging: Data.Element.ID?
    @State private var displayOffset: CGFloat = 0
    @State private var initialIndex: Int?
    @State private var currentIndex: Int?
    @State private var lastSwappedId: Data.Element.ID?
    @State private var pendingDrop: Data.Element.ID?
    @State private var coordinateSpaceName = UUID().uuidString

    // MARK: - Initializer
    init(
        _ data: Data,
        spacing: CGFloat = 0,
        onMove: @escaping (Int, Int) -> Void,
        @ViewBuilder content: @escaping (Data.Element, Bool) -> Content
    ) {
        self.data = data
        self.spacing = spacing
        self.onMove = onMove
        self.content = content
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(data) { element in
                content(element, element.id == dragging)
                    .overlay {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(
                                    key: PositionPreference.self,
                                    value: ElementPosition(proxy.frame(in: .named(coordinateSpaceName)))
                                )
                        }
                    }
                    .onPreferenceChange(PositionPreference.self) { position in
                        Task { @MainActor in
                            if let position {
                                positions[element.id] = position
                            }
                        }
                    }
                    .offset(y: offsetFor(id: element.id))
                    .zIndex(element.id == dragging || element.id == pendingDrop ? 10 : 0)
                    .environment(\.reorderDragCallbacks, ReorderDragCallbacks(
                        coordinateSpaceName: coordinateSpaceName,
                        onDrag: { handleDrag($0, for: element) },
                        onDrop: { handleDrop() }
                    ))
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
    }

    // MARK: - Offset Calculation
    private func offsetFor(id: Data.Element.ID) -> CGFloat {
        guard id == dragging else { return 0 }
        return displayOffset + positionOffset
    }

    private var positionOffset: CGFloat {
        guard let dragging,
              let currentIdx = data.firstIndex(where: { $0.id == dragging }),
              let initIdx = initialIndex else { return 0 }

        if currentIdx > initIdx {
            // Moved down: subtract spans of elements that shifted above
            return data[initIdx..<currentIdx].reduce(0.0) { sum, el in
                sum - (positions[el.id]?.span ?? 0)
            }
        } else if currentIdx < initIdx {
            // Moved up: add spans of elements that shifted below
            return data[(currentIdx + 1)...initIdx].reduce(0.0) { sum, el in
                sum + (positions[el.id]?.span ?? 0)
            }
        }
        return 0
    }

    // MARK: - Drag Handling
    private func handleDrag(_ drag: DragGesture.Value, for element: Data.Element) {
        if dragging == nil {
            dragging = element.id
            initialIndex = data.firstIndex(where: { $0.id == element.id })
            currentIndex = initialIndex
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        displayOffset = drag.translation.height
        checkIntersection(at: drag.location.y)
    }

    private func handleDrop() {
        withAnimation(.spring(duration: 0.3)) {
            pendingDrop = dragging
            dragging = nil
            displayOffset = 0
            initialIndex = nil
            currentIndex = nil
            lastSwappedId = nil
        } completion: {
            pendingDrop = nil
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // MARK: - Intersection Detection
    private func checkIntersection(at dragY: CGFloat) {
        guard let draggedId = dragging else { return }

        let validIds = Set(data.map(\.id))

        guard let (elementId, elementPos) = positions.first(where: { key, pos in
            key != draggedId && validIds.contains(key) && pos.contains(dragY)
        }),
        let targetIndex = data.firstIndex(where: { $0.id == elementId }),
        let fromIndex = currentIndex else {
            lastSwappedId = nil
            return
        }

        // Hysteresis: if we just swapped with this element, only allow
        // re-swap if the user moved to the opposite edge (prevents oscillation)
        if elementId == lastSwappedId {
            let bumperSize: CGFloat = 64
            let allowReswap: Bool

            if fromIndex > targetIndex {
                // Dragged is below target → allow re-swap only at top edge of target
                allowReswap = dragY > elementPos.min && dragY < elementPos.min + bumperSize
            } else {
                // Dragged is above target → allow re-swap only at bottom edge of target
                allowReswap = dragY < elementPos.max && dragY > elementPos.max - bumperSize
            }

            if !allowReswap { return }
        }

        lastSwappedId = elementId
        onMove(fromIndex, targetIndex)
        currentIndex = targetIndex
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

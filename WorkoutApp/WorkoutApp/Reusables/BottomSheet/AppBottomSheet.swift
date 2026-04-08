//
//  AppBottomSheet.swift
//  WorkoutApp
//
//  Created by Raul Pele on 04.04.2026.
//

import SwiftUI

// MARK: - View Extension
extension View {
    func appBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.medium, .large],
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        sheet(isPresented: isPresented) {
            content()
                .appBottomSheetStyle(detents: detents)
        }
    }

    func appBottomSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        detents: Set<PresentationDetent> = [.medium, .large],
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        sheet(item: item) { item in
            content(item)
                .appBottomSheetStyle(detents: detents)
        }
    }
}

// MARK: - Sheet Style
private extension View {
    func appBottomSheetStyle(detents: Set<PresentationDetent>) -> some View {
        self
            .presentationDetents(detents)
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.background)
            .presentationCornerRadius(20)
    }
}

// MARK: - Preview
#Preview {
    AppBottomSheetPreview()
}

private struct AppBottomSheetPreview: View {
    @State private var showSheet = true

    var body: some View {
        ZStack {
            Color(.appBackground).ignoresSafeArea()

            Button("Show Sheet") {
                showSheet = true
            }
        }
        .appBottomSheet(isPresented: $showSheet) {
            VStack(spacing: 16) {
                Text("Bottom Sheet Content")
                    .font(.headline)
                Text("A resizable bottom sheet.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

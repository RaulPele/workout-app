//
//  RestTimerView.swift
//  WatchWorkoutApp Watch App
//

import SwiftUI

struct RestTimerView: View {

    // MARK: - Properties
    let viewModel: ExerciseTrackingViewModel

    // MARK: - Body
    var body: some View {
        TimelineView(.periodic(from: viewModel.restStartDate ?? .now, by: 1.0)) { context in
            let remaining = viewModel.restRemaining(at: context.date)
            let progress = viewModel.restProgress(at: context.date)

            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Rest")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(formatTime(remaining))
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
                .frame(maxHeight: .infinity)

                skipButton(progress: progress)
            }
            .onChange(of: remaining) { _, newValue in
                if newValue <= 0 {
                    viewModel.completeRest()
                }
            }
        }
    }

    // MARK: - Private Views
    @ViewBuilder
    private func skipButton(progress: Double) -> some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)

        Button {
            viewModel.skipRest()
        } label: {
            Text("Skip")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background {
                    ZStack(alignment: .leading) {
                        Color.white.opacity(0.15)

                        GeometryReader { geo in
                            Color.primaryColor
                                .frame(width: geo.size.width * CGFloat(min(progress, 1.0)))
                                .animation(.linear(duration: 1), value: progress)
                        }
                    }
                }
                .clipShape(shape)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Private Methods
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

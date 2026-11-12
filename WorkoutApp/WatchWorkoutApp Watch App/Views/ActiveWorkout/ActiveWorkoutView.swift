//
//  ActiveWorkoutView.swift
//  WatchWorkoutApp Watch App
//

import SwiftUI
import WatchKit

struct ActiveWorkoutView: View {

    // MARK: - Properties
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @State private var viewModel: ActiveWorkoutViewModel
    @State private var horizontalSelection: HorizontalTab = .content

    private enum HorizontalTab {
        case controls
        case content
        case nowPlaying
    }

    // MARK: - Initializers
    init(template: Workout, workoutManager: WorkoutManager) {
        _viewModel = State(
            initialValue: ActiveWorkoutViewModel(template: template, workoutManager: workoutManager)
        )
    }

    // MARK: - Body
    var body: some View {
        // A ZStack, not a Group, so `.task` belongs to the container and doesn't
        // re-run (and retry) when the error view replaces the pages.
        ZStack {
            if let message = viewModel.startErrorMessage {
                WorkoutStartErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.start() } },
                    onCancel: viewModel.cancelStart
                )
            } else {
                TabView(selection: $horizontalSelection) {
                    Tab(value: HorizontalTab.controls) {
                        ControlsView()
                    }
                    Tab(value: HorizontalTab.content) {
                        SessionContentView(viewModel: viewModel.exerciseTracking)
                    }
                    Tab(value: HorizontalTab.nowPlaying) {
                        NowPlayingView()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
            }
        }
        .navigationBarBackButtonHidden(true)
        .layoutPriority(1)
        .task {
            await viewModel.start()
        }
        .onChange(of: viewModel.isRunning) { _, _ in
            withAnimation {
                horizontalSelection = .content
            }
        }
        .onChange(of: isLuminanceReduced) { _, reduced in
            if reduced {
                withAnimation {
                    horizontalSelection = .content
                }
            }
        }
    }
}

// MARK: - SessionContentView
private struct SessionContentView: View {

    // MARK: - Properties
    let viewModel: ExerciseTrackingViewModel
    @State private var verticalSelection: VerticalTab = .exercise

    private enum VerticalTab {
        case exercise
        case metrics
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $verticalSelection) {
                Tab(value: VerticalTab.exercise) {
                    ExerciseTrackingView(viewModel: viewModel)
                }
                Tab(value: VerticalTab.metrics) {
                    MetricsPageView()
                }
            }
            .tabViewStyle(.verticalPage)
//            .layoutPriority(1)
        }
    }
}

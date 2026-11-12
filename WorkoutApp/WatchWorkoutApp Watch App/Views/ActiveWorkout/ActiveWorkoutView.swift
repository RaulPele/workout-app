//
//  ActiveWorkoutView.swift
//  WatchWorkoutApp Watch App
//

import SwiftUI
import WatchKit

struct ActiveWorkoutView: View {

    // MARK: - Properties
    @Environment(WorkoutManager.self) private var workoutManager
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @State private var viewModel: ActiveWorkoutViewModel
    @State private var horizontalSelection: HorizontalTab = .content

    private enum HorizontalTab {
        case controls
        case content
        case nowPlaying
    }

    // MARK: - Initializers
    init(workout: Workout) {
        _viewModel = State(wrappedValue: ActiveWorkoutViewModel(workout: workout))
    }

    // MARK: - Body
    var body: some View {
        TabView(selection: $horizontalSelection) {
            Tab(value: HorizontalTab.controls) {
                ControlsView()
            }
            Tab(value: HorizontalTab.content) {
                SessionContentView(viewModel: viewModel, onFinishWorkout: handleFinishWorkout)
            }
            Tab(value: HorizontalTab.nowPlaying) {
                NowPlayingView()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
        .navigationBarBackButtonHidden(true)
        .layoutPriority(1)
        .task {
            WKInterfaceDevice.current().play(.start)
            await workoutManager.startWorkout(template: viewModel.workout)
        }
        .onChange(of: workoutManager.running) { _, _ in
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

    // MARK: - Private Methods
    private func handleFinishWorkout() {
        workoutManager.finishWorkout(
            performedExercises: viewModel.performedExercises
        )
    }
}

// MARK: - SessionContentView
private struct SessionContentView: View {

    // MARK: - Properties
    @Bindable var viewModel: ActiveWorkoutViewModel
    let onFinishWorkout: () -> Void
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
                    ExerciseTrackingView(viewModel: viewModel, onFinishWorkout: onFinishWorkout)
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

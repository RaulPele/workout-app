//
//  WorkoutTemplateBuilderView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.05.2023.
//

import SwiftUI

private struct ExerciseIndex: Identifiable {
    let id: Int
}

struct WorkoutTemplateBuilder {
        
    struct ContentView: View {
        
        @Bindable var viewModel: ViewModel
        @Environment(\.dismiss) private var dismiss
        @State private var isEditing = false
        @State private var deletingExerciseId: UUID?
        @State private var editingExerciseIndex: ExerciseIndex?
        
        var body: some View {
            ScrollView {
                mainContentView
            }
            .background(Color.background)
            .navigationTitle($viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !viewModel.exercises.isEmpty {
                    if isEditing {
                        ToolbarItem(placement: .primaryAction) {
                            Button(role: .confirm) {
                                viewModel.handleOnSaveTapped()
                                withAnimation {
                                    isEditing = false
                                }
                            }
                        }
                    } else {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                withAnimation {
                                    isEditing = true
                                }
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddExerciseView) {
                AddExerciseView(
                    exerciseService: viewModel.exerciseService,
                    into: $viewModel.exercises
                )
            }
            .sheet(item: $editingExerciseIndex) { indexWrapper in
                let index = indexWrapper.id
                if index < viewModel.exercises.count {
                    EditView(
                        exercise: Binding(
                            get: { viewModel.exercises[index] },
                            set: { viewModel.exercises[index] = $0 }
                        ),
                        onFinishedEditing: {
                            editingExerciseIndex = nil
                        }
                    )
                }
            }
        }
        
        private var mainContentView: some View {
            exercisesView
                .padding()
        }
        
        private var exercisesView: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Exercises list
                if viewModel.exercises.isEmpty {
                    EmptyExercisesView {
                        viewModel.handleAddExerciseButtonTapped()
                    }
                    .padding(.vertical)
                } else {
                    // Section header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Exercises")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Color.onBackground)
                            
                            if !viewModel.exercises.isEmpty {
                                Text("\(viewModel.exercises.count) exercise\(viewModel.exercises.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if isEditing {
                            Button {
                                viewModel.handleAddExerciseButtonTapped()
                            } label: {
                                Label("Add", systemImage: "plus")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(16)
                                    .background(Color.primaryColor)
                                    .clipShape(.capsule)
                                    .glassEffect(.clear)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                    }
                    .animation(.spring(duration: 0.3), value: isEditing)
                    .padding(.bottom)
                    
                    ForEach(viewModel.exercises.enumerated(), id: \.element.id) { offset, exercise in
                        ExerciseCardView(
                            exercise: exercise,
                            isEditMode: isEditing,
                            onDeleteAction: {
                                let exerciseId = exercise.id
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    deletingExerciseId = exerciseId
                                }
                                Task {
                                    try? await Task.sleep(for: .milliseconds(300))
                                    withAnimation {
                                        viewModel.exercises.removeAll(where: { $0.id == exerciseId })
                                        deletingExerciseId = nil
                                    }
                                }
                            },
                            onTapAction: {
                                if let currentIndex = viewModel.exercises.firstIndex(where: { $0.id == exercise.id }) {
                                    editingExerciseIndex = ExerciseIndex(id: currentIndex)
                                }
                            }
                        )
                        .offset(x: deletingExerciseId == exercise.id ? 2000 : 0)
                        .opacity(deletingExerciseId == exercise.id ? 0 : 1)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        
        private struct EmptyExercisesView: View {
            let onAddAction: () -> Void
            
            var body: some View {
                VStack(spacing: 16) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    
                    Text("No exercises yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Add your first exercise to get started")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        onAddAction()
                    } label: {
                        Label("Add Exercise", systemImage: "plus")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        
    }
}

#Preview("Empty state") {
    NavigationStack {
        WorkoutTemplateBuilder.ContentView(
            viewModel: .init(
                exerciseService: MockedExerciseService(),
                workoutTemplateService: MockedWorkoutTemplateService()
            )
        )
    }
}

#Preview("With two exercises") {
    WorkoutTemplateBuilderPreviewWithExercises()
}

private struct WorkoutTemplateBuilderPreviewWithExercises: View {
    private var viewModel: WorkoutTemplateBuilder.ViewModel
    
    init() {
        viewModel = WorkoutTemplateBuilder.ViewModel(
            exerciseService: MockedExerciseService(),
            workoutTemplateService: MockedWorkoutTemplateService()
        )
        viewModel.exercises = [.mockedBBSquats, .mockedBBBenchPress]
    }
    
    var body: some View {
        NavigationStack {
            WorkoutTemplateBuilder.ContentView(viewModel: viewModel)
        }
    }
}


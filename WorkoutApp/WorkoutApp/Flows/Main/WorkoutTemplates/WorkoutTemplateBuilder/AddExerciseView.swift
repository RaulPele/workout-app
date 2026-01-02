//
//  AddExerciseView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.06.2023.
//

import SwiftUI

extension AddExerciseView {
    
    class ViewModel: ObservableObject {
        
        @Published var existentExercises = [Exercise]()
        @Published var newExerciseName = ""
        @Published var isAddingExercise = false
        @Published var selectedExercise: Exercise?
        @Published var showEditView = false
        
        private var exercisesList: Binding<[Exercise]>
        
        private let exerciseService: any ExerciseServiceProtocol
        
        private var loadingTask: Task<Void, Never>?
        
        init(exerciseService: any ExerciseServiceProtocol, exercisesList: Binding<[Exercise]>) {
            self.exerciseService = exerciseService
            self.exercisesList = exercisesList
            loadExercises()
        }
        
        //MARK: - Private Methods
        private func loadExercises() {
            loadingTask?.cancel()
            loadingTask = Task(priority: .background) { @MainActor [weak self] in
                guard let self = self else { return }
                do {
                    self.existentExercises = try await exerciseService.getAll()
                } catch {
                    print("Error while loading exercises: \(error.localizedDescription)")
                }
            }
        }
        
        //MARK: - Handlers
        func handleAddExerciseTapped() {
            Task(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                do {
                    let exercise = Exercise(id: .init(), name: self.newExerciseName, numberOfSets: 0, setData: .init(id: .init(), reps: 0), restBetweenSets: 0)
                    try await self.exerciseService.save(exercise: exercise)
                    await MainActor.run(body: {
                        self.existentExercises.append(exercise)
                        self.exercisesList.wrappedValue.append(exercise)
                        self.newExerciseName = ""
                        self.isAddingExercise = false
                    })
                    print("Successfully added exercise: \(exercise.name)")
                } catch {
                    print("Error while saving exercise: \(error.localizedDescription)")
                }
            }
        }
        
        func handleOnAppear() {
            self.loadExercises()
        }
        
        func handleExerciseTapped(for exercise: Exercise) {
            // Create a new exercise instance with default values for editing
            let exerciseForWorkout = Exercise(
                id: .init(),
                name: exercise.name,
                numberOfSets: exercise.numberOfSets > 0 ? exercise.numberOfSets : 3,
                setData: ExerciseSet(
                    id: .init(),
                    reps: exercise.setData.reps > 0 ? exercise.setData.reps : 10
                ),
                restBetweenSets: exercise.restBetweenSets > 0 ? exercise.restBetweenSets : 60
            )
            selectedExercise = exerciseForWorkout
            showEditView = true
        }
        
        func handleExerciseEdited(_ exercise: Exercise) {
            exercisesList.wrappedValue.append(exercise)
        }
    }
}

struct AddExerciseView: View {
    
    @StateObject private var viewModel: ViewModel
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    init(exerciseService: any ExerciseServiceProtocol, into exercises: Binding<[Exercise]>) {
        let viewModel = ViewModel(exerciseService: exerciseService, exercisesList: exercises)
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return viewModel.existentExercises
        }
        return viewModel.existentExercises.filter { exercise in
            exercise.name.localizedStandardContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                TextField("Search exercises", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                // Exercises list
                if filteredExercises.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView(
                        "No exercises found",
                        systemImage: "magnifyingglass",
                        description: Text("Try a different search term")
                    )
                } else {
                    List {
                        ForEach(filteredExercises) { exercise in
                            Button {
                                viewModel.handleExerciseTapped(for: exercise)
                            } label: {
                                HStack {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .foregroundStyle(Color.primaryColor)
                                    
                                    Text(exercise.name)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(Color.primaryColor)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                // Add new exercise button
                Divider()
                
                Button {
                    viewModel.isAddingExercise = true
                } label: {
                    Label("Create New Exercise", systemImage: "plus.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.isAddingExercise) {
                AddNewExerciseSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showEditView) {
                if let exercise = viewModel.selectedExercise {
                    EditExerciseSheetWrapper(
                        exercise: exercise,
                        onFinishedEditing: { editedExercise in
                            viewModel.handleExerciseEdited(editedExercise)
                            viewModel.showEditView = false
                            dismiss()
                        }
                    )
                }
            }
            .onAppear {
                viewModel.handleOnAppear()
            }
        }
    }
}

private struct AddNewExerciseSheet: View {
    @ObservedObject var viewModel: AddExerciseView.ViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Exercise name", text: $viewModel.newExerciseName)
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.isAddingExercise = false
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.handleAddExerciseTapped()
                        dismiss()
                    }
                    .bold()
                    .disabled(viewModel.newExerciseName.isEmpty)
                }
            }
        }
    }
}

private struct EditExerciseSheetWrapper: View {
    let exercise: Exercise
    let onFinishedEditing: (Exercise) -> Void
    @State private var editedExercise: Exercise
    
    init(exercise: Exercise, onFinishedEditing: @escaping (Exercise) -> Void) {
        self.exercise = exercise
        self.onFinishedEditing = onFinishedEditing
        _editedExercise = State(initialValue: exercise)
    }
    
    var body: some View {
        EditView(
            exercise: $editedExercise,
            onFinishedEditing: {
                onFinishedEditing(editedExercise)
            }
        )
    }
}

struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView(exerciseService: MockedExerciseService(), into: .constant([]))
    }
}

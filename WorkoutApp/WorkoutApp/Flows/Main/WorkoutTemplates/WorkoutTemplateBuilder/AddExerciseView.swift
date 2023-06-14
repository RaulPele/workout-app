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
            self.exercisesList.wrappedValue.append(exercise)
        }
    }
}

struct AddExerciseView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(exerciseService: any ExerciseServiceProtocol, into exercises: Binding<[Exercise]>) {
        let viewModel = ViewModel(exerciseService: exerciseService, exercisesList: exercises)
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            ForEach(viewModel.existentExercises) { exercise  in
                Button {
                    viewModel.handleExerciseTapped(for: exercise)
                } label: {
                    Text(exercise.name)
                        .foregroundColor(.primaryColor)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                }
                
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
            }

            Button {
                viewModel.isAddingExercise = true
            } label: {
                Text("Add exercise...")
                    .foregroundColor(.primaryColor)
                    .padding(10)
                    .frame(maxWidth: .infinity)
            }
                
        }
        .padding()
        .frame(minHeight: 200)
        .background(Color.surface2)
        .overlay {
            if viewModel.isAddingExercise {
                ZStack {
                    Color.surface2
                    
                    VStack(spacing: 15) {
                        FloatingTextField(title: "Name", text: $viewModel.newExerciseName)
                            .padding(.horizontal, 20)
                        HStack(spacing: 40) {
                            Button(role: .cancel) {
                                viewModel.isAddingExercise = false
                            } label: {
                                Text("Cancel")
                                    .foregroundColor(.primaryColor)
                            }
                            .padding()
                            .frame(width: 120)

                            Buttons.Filled(title: "Add") {
                                viewModel.handleAddExerciseTapped()
                            }
                            .disabled(viewModel.newExerciseName.isEmpty)
                            .frame(width: 120)
                        }
                    }
                    .padding()
                }
                .transition(.opacity.animation(.easeInOut))
            }
        }
        .cornerRadius(15)
        .frame(maxHeight: .infinity)
        .onAppear {
            viewModel.handleOnAppear()
        }

    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView(exerciseService: MockedExerciseService(), into: .constant([]))
    }
}

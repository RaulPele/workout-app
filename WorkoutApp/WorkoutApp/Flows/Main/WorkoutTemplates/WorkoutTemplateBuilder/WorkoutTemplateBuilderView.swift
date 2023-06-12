//
//  WorkoutTemplateBuilderView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.05.2023.
//

import SwiftUI

struct WorkoutTemplateBuilder {
        
    struct ContentView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            ScrollView {
                NavigationBar(title: "Build your workout", backButtonAction:  {
                    viewModel.handleBackAction()
                }) {
                    Button {
                        viewModel.handleOnSaveTapped()
                    } label: {
                        Text("Save")
                            .foregroundColor(.primaryColor)
                    }
                    .buttonStyle(.plain)
                }
                
                mainContentView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(editView)
            .overlay(addExerciseView)
            .background(Color.background)

        }
        
        private var mainContentView: some View{
            VStack(alignment: .leading, spacing: 20) {
                FloatingTextField(title: "Workout title", text: $viewModel.title)
                
                exercisesView
                    .padding(.top, 10)
            }
            .padding()
//            .frame(maxHeight: 900)
        }
        
        private var exercisesView: some View {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Exercises")
                        .foregroundColor(.onBackground)
                        .font(.heading2)
                    
                    Spacer()
                    
                    Button {
                        //TODO: navigate to template builder screen
                        viewModel.handleAddExerciseButtonTapped()
                    } label: {
                        Image(systemName: "plus")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.primaryColor)
                    }
                    .buttonStyle(.plain)
                }
                
                ForEach(viewModel.exercises) { exercise in
                    ExerciseView(exercise: exercise) {
                        let index = viewModel.exercises.firstIndex(of: exercise)!
                        viewModel.selectedExercise = $viewModel.exercises[index]
                    }
                }
                
            }
        }
        
        @ViewBuilder
        private var editView: some View {
            if let selectedExercise = viewModel.selectedExercise, viewModel.showEditingView {
                EditView(exercise: selectedExercise) {
                    viewModel.showEditingView = false
                    print(viewModel.exercises[viewModel.exercises.firstIndex(of: viewModel.selectedExercise!.wrappedValue)!])
                }
            }

        }
        
        @ViewBuilder
        private var addExerciseView: some View {
            if viewModel.showAddExerciseView {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.showAddExerciseView = false
                        }
                    AddExerciseView()
                        .padding()
                }
                .transition(.opacity.animation(.easeInOut))

            }
        }
    }
}

#if DEBUG
struct WorkoutTemplateBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(previewDevices) { device in
            WorkoutTemplateBuilder.ContentView(viewModel: .init())
                .preview(device)
        }
    }
}
#endif

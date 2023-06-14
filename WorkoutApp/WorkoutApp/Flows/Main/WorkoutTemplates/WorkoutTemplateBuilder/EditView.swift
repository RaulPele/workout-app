//
//  EditView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.05.2023.
//

import SwiftUI

struct EditView: View {
    
    class ViewModel: ObservableObject {
        
        var exercise: Binding<Exercise>
        
        @Published var newReps: String
        @Published var newSets: String
        @Published var newMinutes: String
        @Published var newSeconds: String
        
        init(exercise: Binding<Exercise>) {
            self.exercise = exercise
            self.newReps = String(exercise.wrappedValue.setData.reps)
            self.newSets = String(exercise.wrappedValue.numberOfSets)
            self.newMinutes = String(Int(exercise.wrappedValue.restBetweenSets / 60))
            self.newSeconds = String(Int(exercise.wrappedValue.restBetweenSets.truncatingRemainder(dividingBy: 60)))
        }
        
        func handleFinishedEditing() {
            let newRestTime = Int(newMinutes)! * 60 + Int(newSeconds)!
            
            let exercise = Exercise(
                id: exercise.wrappedValue.id,
                name: exercise.wrappedValue.name,
                numberOfSets: Int(newSets) ?? 0,
                setData: .init(
                    id: exercise.wrappedValue.setData.id,
                    reps: Int(newReps)!
                ),
                restBetweenSets: TimeInterval(newRestTime)
            )
            
            self.exercise.wrappedValue = exercise
        }
    }
    
    @StateObject private var viewModel: ViewModel
    private let onFinishedEditing: () -> Void
    
    
    init(exercise: Binding<Exercise>, onFinishedEditing: @escaping () -> Void) {
        self.onFinishedEditing = onFinishedEditing
        _viewModel = .init(wrappedValue: ViewModel(exercise: exercise))
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            VStack(spacing: 40) {
                HStack(alignment: .center, spacing: 30) {
                    numbersInputField(title: "Sets", text: $viewModel.newSets)
                    numbersInputField(title: "Reps", text: $viewModel.newReps)
                    numbersInputField(title: "Mins", text: $viewModel.newMinutes)
                    numbersInputField(title: "Secs", text: $viewModel.newSeconds)
                }
                
                Buttons.Filled(title: "Done") {
                    viewModel.handleFinishedEditing()
                    onFinishedEditing()
                }
                .frame(maxWidth: 120)
                
            }
            .padding(30)
            .background(Color.surface2)
            .cornerRadius(15)
            .padding(.horizontal)
        }
        .transition(.opacity.animation(.easeInOut))
    }
    
    private func numbersInputField(title: String, text: Binding<String>) -> some View {
        FloatingTextField(
            title: title,
            text: text,
            keyboardType: .numberPad
        )
        .frame(width: 50)
        .onChange(of: text.wrappedValue) { newValue in
            let filtered = newValue.filter { "0123456789".contains($0) }
            if filtered != newValue {
                text.wrappedValue = filtered
            }
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(exercise: .constant(.mockedBBSquats), onFinishedEditing: { })
    }
}

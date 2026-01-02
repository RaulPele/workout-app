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
    @FocusState private var focusedField: Field?
    
    init(exercise: Binding<Exercise>, onFinishedEditing: @escaping () -> Void) {
        self.onFinishedEditing = onFinishedEditing
        _viewModel = .init(wrappedValue: ViewModel(exercise: exercise))
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Details") {
                    HStack {
                        Text("Sets")
                        Spacer()
                        TextField("Sets", text: $viewModel.newSets)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: viewModel.newSets) { _, newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    viewModel.newSets = filtered
                                }
                            }
                    }
                    .onTapGesture {
                        focusedField = .sets
                    }
                    
                    
                    HStack {
                        Text("Reps")
                        Spacer()
                        TextField("Reps", text: $viewModel.newReps)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: viewModel.newReps) { _, newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    viewModel.newReps = filtered
                                }
                            }
                    }
                    .onTapGesture {
                        focusedField = .reps
                    }
                }
                
                Section("Rest Time") {
                    HStack {
                        Text("Minutes")
                        Spacer()
                        TextField("Minutes", text: $viewModel.newMinutes)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: viewModel.newMinutes) { _, newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    viewModel.newMinutes = filtered
                                }
                            }
                    }
                    .onTapGesture {
                        focusedField = .minutes
                    }
                    
                    HStack {
                        Text("Seconds")
                        Spacer()
                        TextField("Seconds", text: $viewModel.newSeconds)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: viewModel.newSeconds) { _, newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    viewModel.newSeconds = filtered
                                }
                            }
                            
                    }
//                    .background(Color.red)
                    .contentShape(.rect)
                    .onTapGesture {
                        focusedField = .seconds
                    }
                }
            }
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        viewModel.handleFinishedEditing()
                        onFinishedEditing()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

enum Field {
    case sets
    case reps
    case minutes
    case seconds
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(exercise: .constant(.mockedBBSquats), onFinishedEditing: { })
    }
}

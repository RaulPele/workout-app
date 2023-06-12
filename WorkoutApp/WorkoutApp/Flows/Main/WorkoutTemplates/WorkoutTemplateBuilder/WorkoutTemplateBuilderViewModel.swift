//
//  WorkoutTemplateBuilderViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.05.2023.
//

import Foundation
import SwiftUI

extension WorkoutTemplateBuilder {
    
    class ViewModel: ObservableObject {
        
        @Published var title: String = ""
        @Published var reps: String = ""
        @Published var sets: String = ""
        @Published var restTime: String = ""
        @Published var seconds: String = ""
        @Published var minutes: String = ""
        
        @Published var showEditingView: Bool = false
        @Published var showAddExerciseView: Bool = false
        
        @Published var exercises = [Exercise]()
        
        var onBack: (() -> Void)? = nil
        
        var selectedExercise: Binding<Exercise>? {
            didSet {
                if selectedExercise != nil {
                    showEditingView = true
                }
            }
        }
        
        init() {
            exercises = [.mockedBBBenchPress, .mockedBBSquats]
        }
        
        //MARK: - public handlers
        func handleOnSaveTapped() {
            saveWorkoutTemplate()
        }
        
        func handleBackAction() {
            onBack?()
        }
        
        func handleAddExerciseButtonTapped() {
            showAddExerciseView = true
        }
        
        //MARK: - private methods
        private func saveWorkoutTemplate() {
            //TODO: field validations
            
            let newTemplate = WorkoutTemplate(id: .init(), name: title, exercises: exercises)
            
            do {
                try FileIOManager.write(entity: newTemplate, toDirectory: .workoutTemplates)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
    }
}

//
//  AppTester.swift
//  WorkoutApp
//
//  Created by Raul Pele on 26.05.2023.
//

import Foundation

struct AppTester {
    
    func createWorkoutTemplatesFiles() {
        let mockedTemplate = Workout.mockedWorkoutTemplate
        try? FileIOManager.write(entity: mockedTemplate, toDirectory: .workoutTemplates)
        print("Wrote mocked templates to app directory")
    }
}

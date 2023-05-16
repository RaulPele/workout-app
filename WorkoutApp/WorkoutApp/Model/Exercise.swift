//
//  Exercise.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.05.2023.
//

import Foundation

struct ExerciseSet: Identifiable {
    
    let id: UUID
    let reps: Int
//    let restTime: TimeInterval
}

struct Exercise: Identifiable {
    
    let id: UUID
    let name: String
    let numberOfSets: Int
    let setData: ExerciseSet
    let restBetweenSets: TimeInterval
}

extension Exercise {
    
    static let mockedBBBenchPress = Exercise(
        id: .init(),
        name: "BB Bench Press",
        numberOfSets: 3,
        setData: .mockedBBBenchPress,
        restBetweenSets: 150
    )
    
    static let mockedBBSquats = Exercise(
        id: .init(),
        name: "BB Squats",
        numberOfSets: 4,
        setData: .mockedBBSquats,
        restBetweenSets: 150

    )
}
                                           
extension ExerciseSet {
    static let mockedBBBenchPress = ExerciseSet(id: .init(), reps: 20)
    static let mockedBBSquats = ExerciseSet(id: .init(), reps: 5)
}

struct WorkoutTemplate: Identifiable {
    
    let id: UUID
    let name: String
    let exercises: [Exercise]
}

extension WorkoutTemplate {
    
    static let mockedWorkoutTemplate = WorkoutTemplate(
        id: .init(),
        name: "My strength workout",
        exercises: [.mockedBBSquats, .mockedBBBenchPress]
    )
}

struct PerformedExercise: Identifiable {
    
    let id: UUID
    let exercise: Exercise
    let numberOfSets: Int
    let setData: PerformedSet // TODO: change to an array of performed sets
    //TODO: add data health metrics
}

extension PerformedExercise {
    static let mockedBBBenchPress = PerformedExercise(
        id: .init(),
        exercise: .mockedBBBenchPress,
        numberOfSets: 3,
        setData: .mockedBBBenchPress
    )
    
    static let mockedBBSquats = PerformedExercise(
        id: .init(),
        exercise: .mockedBBSquats,
        numberOfSets: 3,
        setData: .mockedBBSquats
    )
    
}

struct PerformedSet: Identifiable {
    
    let id: UUID
    let set: ExerciseSet
    let reps: Int
    let weight: Double
    let restTime: TimeInterval
}

extension PerformedSet {
    
    static let mockedBBBenchPress = PerformedSet(
        id: .init(),
        set: .mockedBBBenchPress,
        reps: 20,
        weight: 50,
        restTime: 150
    )
    
    static let mockedBBSquats = PerformedSet(
        id: .init(),
        set: .mockedBBSquats,
        reps: 5,
        weight: 70,
        restTime: 200
    )
}


struct WorkoutSession: Identifiable {
    
    let id: UUID
    let startDate: Date
    let endDate: Date
    let workoutTemplate: WorkoutTemplate
    let performedExercises: [PerformedExercise]
}

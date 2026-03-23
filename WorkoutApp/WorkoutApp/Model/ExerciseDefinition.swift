//
//  ExerciseDefinition.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation

struct ExerciseDefinition: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let force: ExerciseForce?
    let level: ExerciseLevel
    let mechanic: ExerciseMechanic?
    let equipment: Equipment?
    let primaryMuscles: [MuscleGroup]
    let secondaryMuscles: [MuscleGroup]
    let instructions: [String]
    let category: ExerciseCategory
    let images: [String]
}

// MARK: - Legacy Support
extension ExerciseDefinition {
    static func legacy(name: String) -> ExerciseDefinition {
        ExerciseDefinition(
            id: UUID().uuidString,
            name: name,
            force: nil,
            level: .beginner,
            mechanic: nil,
            equipment: nil,
            primaryMuscles: [],
            secondaryMuscles: [],
            instructions: [],
            category: .strength,
            images: []
        )
    }
}

// MARK: - Mocked Data
extension ExerciseDefinition {
    static let mockedBBBenchPress = ExerciseDefinition(
        id: "barbell_bench_press",
        name: "Barbell Bench Press",
        force: .push,
        level: .intermediate,
        mechanic: .compound,
        equipment: .barbell,
        primaryMuscles: [.chest],
        secondaryMuscles: [.shoulders, .triceps],
        instructions: [
            "Lie back on a flat bench. Using a medium width grip, lift the bar from the rack and hold it straight over you with your arms locked.",
            "From the starting position, breathe in and begin coming down slowly until the bar touches your middle chest.",
            "After a brief pause, push the bar back to the starting position as you breathe out. Lock your arms and squeeze your chest in the contracted position, hold for a second and then start coming down slowly again.",
            "Repeat the movement for the prescribed amount of repetitions."
        ],
        category: .strength,
        images: ["barbell_bench_press_1", "barbell_bench_press_2"]
    )

    static let mockedBBSquats = ExerciseDefinition(
        id: "barbell_squat",
        name: "Barbell Squat",
        force: .push,
        level: .intermediate,
        mechanic: .compound,
        equipment: .barbell,
        primaryMuscles: [.quadriceps],
        secondaryMuscles: [.hamstrings, .glutes, .calves, .lowerBack],
        instructions: [
            "Set up a barbell on a squat rack at about shoulder height. Step under the bar and place it across your upper back.",
            "Lift the bar off the rack by pushing with your legs and straightening your torso. Step away from the rack with your feet shoulder-width apart.",
            "Begin to slowly lower the bar by bending the knees as you maintain a straight posture. Continue down until your thighs are parallel to the floor.",
            "Raise the bar back to the starting position by pushing through your heels as you straighten your legs."
        ],
        category: .strength,
        images: ["barbell_squat_1", "barbell_squat_2"]
    )

    static let mockedPullUp = ExerciseDefinition(
        id: "pullup",
        name: "Pull-Up",
        force: .pull,
        level: .intermediate,
        mechanic: .compound,
        equipment: .bodyOnly,
        primaryMuscles: [.lats],
        secondaryMuscles: [.biceps, .middleBack],
        instructions: [
            "Grab the pull-up bar with the palms facing forward using a wide grip.",
            "With both arms extended in front of you holding the bar, bring your torso back around 30 degrees while creating a curvature on your lower back.",
            "Pull your torso up until the bar touches your upper chest by drawing the shoulders and the upper arms down and back.",
            "After a second of squeezing at the top, slowly lower your torso back to the starting position."
        ],
        category: .strength,
        images: ["pullup_1", "pullup_2"]
    )
}

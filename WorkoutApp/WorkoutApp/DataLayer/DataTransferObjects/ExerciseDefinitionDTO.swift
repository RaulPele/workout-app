//
//  ExerciseDefinitionDTO.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation
import SwiftData

@Model
class ExerciseDefinitionDTO: DomainConvertible {

    // MARK: - Properties
    @Attribute(.unique) var id: String
    var name: String
    var force: ExerciseForce?
    var level: ExerciseLevel
    var mechanic: ExerciseMechanic?
    var equipment: Equipment?
    var primaryMuscles: [MuscleGroup]
    var secondaryMuscles: [MuscleGroup]
    var instructions: [String]
    var category: ExerciseCategory
    var images: [String]
    var lastSyncedAt: Date

    // MARK: - Initializers
    init(
        id: String,
        name: String,
        force: ExerciseForce?,
        level: ExerciseLevel,
        mechanic: ExerciseMechanic?,
        equipment: Equipment?,
        primaryMuscles: [MuscleGroup],
        secondaryMuscles: [MuscleGroup],
        instructions: [String],
        category: ExerciseCategory,
        images: [String],
        lastSyncedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.force = force
        self.level = level
        self.mechanic = mechanic
        self.equipment = equipment
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
        self.category = category
        self.images = images
        self.lastSyncedAt = lastSyncedAt
    }

    convenience init(from definition: ExerciseDefinition) {
        self.init(
            id: definition.id,
            name: definition.name,
            force: definition.force,
            level: definition.level,
            mechanic: definition.mechanic,
            equipment: definition.equipment,
            primaryMuscles: definition.primaryMuscles,
            secondaryMuscles: definition.secondaryMuscles,
            instructions: definition.instructions,
            category: definition.category,
            images: definition.images
        )
    }

    // MARK: - DomainConvertible
    func toDomain() -> ExerciseDefinition {
        ExerciseDefinition(
            id: id,
            name: name,
            force: force,
            level: level,
            mechanic: mechanic,
            equipment: equipment,
            primaryMuscles: primaryMuscles,
            secondaryMuscles: secondaryMuscles,
            instructions: instructions,
            category: category,
            images: images
        )
    }
}

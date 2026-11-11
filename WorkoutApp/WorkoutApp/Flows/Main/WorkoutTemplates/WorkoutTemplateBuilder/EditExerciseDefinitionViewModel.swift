//
//  EditExerciseDefinitionViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.05.2026.
//

import Foundation
import Observation

extension EditExerciseDefinitionView {

    @MainActor
    @Observable
    class ViewModel {

        // MARK: - Properties
        var name: String
        var primaryMuscles: Set<MuscleGroup>
        var equipment: Equipment?
        var category: ExerciseCategory
        var level: ExerciseLevel
        var isSaving = false

        let isEditing: Bool

        @ObservationIgnored private let existingId: String?
        @ObservationIgnored private let libraryRepository: any UserExerciseLibraryRepositoryProtocol

        var isValid: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        // MARK: - Initializers
        init(libraryRepository: any UserExerciseLibraryRepositoryProtocol) {
            self.libraryRepository = libraryRepository
            self.isEditing = false
            self.existingId = nil
            self.name = ""
            self.primaryMuscles = []
            self.equipment = nil
            self.category = .strength
            self.level = .beginner
        }

        init(
            libraryRepository: any UserExerciseLibraryRepositoryProtocol,
            editing definition: ExerciseDefinition
        ) {
            self.libraryRepository = libraryRepository
            self.isEditing = true
            self.existingId = definition.id
            self.name = definition.name
            self.primaryMuscles = Set(definition.primaryMuscles)
            self.equipment = definition.equipment
            self.category = definition.category
            self.level = definition.level
        }

        // MARK: - Save
        func save() async {
            guard isValid else { return }
            isSaving = true
            defer { isSaving = false }

            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            // Fields intentionally omitted from V1 essentials form: secondaryMuscles, force, mechanic, instructions, images.
            let definition = ExerciseDefinition(
                id: existingId ?? UUID().uuidString,
                name: trimmedName,
                force: nil,
                level: level,
                mechanic: nil,
                equipment: equipment,
                primaryMuscles: Array(primaryMuscles).sorted { $0.displayName < $1.displayName },
                secondaryMuscles: [],
                instructions: [],
                category: category,
                images: []
            )

            do {
                try await libraryRepository.save(entity: definition)
            } catch {
                // Surface via UI in a future pass; non-blocking here.
                print("Failed to save exercise definition: \(error.localizedDescription)")
            }
        }
    }
}

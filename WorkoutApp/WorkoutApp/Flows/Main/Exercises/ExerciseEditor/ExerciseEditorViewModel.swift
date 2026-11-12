//
//  ExerciseEditorViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Combine
import Foundation
import Observation

// MARK: - ExerciseEditorViewModel
@MainActor
@Observable
final class ExerciseEditorViewModel {

    // MARK: - Properties
    var name: String
    var muscles: Set<MuscleGroup>
    var equipment: Equipment?
    var errorMessage: String?
    private(set) var isSaving = false
    private(set) var otherExerciseNames: [String] = []

    let isEditing: Bool

    @ObservationIgnored private let original: ExerciseDefinition?
    @ObservationIgnored private let libraryRepository: any UserExerciseLibraryRepositoryProtocol
    @ObservationIgnored private let workoutRepository: any WorkoutRepository
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isDuplicateName: Bool {
        otherExerciseNames.contains {
            $0.compare(trimmedName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
    }

    var nameMessage: String? {
        isDuplicateName ? "You already have an exercise called \(trimmedName)." : nil
    }

    var canSave: Bool {
        !trimmedName.isEmpty && !isDuplicateName && !isSaving && (!isEditing || hasChanges)
    }

    var hasChanges: Bool {
        trimmedName != (original?.name ?? "")
            || muscles != Set(original?.primaryMuscles ?? [])
            || equipment != original?.equipment
    }

    var title: String {
        isEditing ? "Edit Exercise" : "New Exercise"
    }

    // MARK: - Initializers
    init(
        libraryRepository: any UserExerciseLibraryRepositoryProtocol,
        workoutRepository: any WorkoutRepository,
        definition: ExerciseDefinition? = nil
    ) {
        self.libraryRepository = libraryRepository
        self.workoutRepository = workoutRepository
        self.original = definition
        self.isEditing = definition != nil
        self.name = definition?.name ?? ""
        self.muscles = Set(definition?.primaryMuscles ?? [])
        self.equipment = definition?.equipment
        subscribeToLibrary()
    }

    // MARK: - Public Methods
    func load() async {
        try? await libraryRepository.loadData()
    }

    func toggleMuscle(_ muscle: MuscleGroup) {
        if muscles.contains(muscle) {
            muscles.remove(muscle)
        } else {
            muscles.insert(muscle)
        }
    }

    /// Saves the exercise and, when editing, refreshes the copies embedded in workouts.
    /// Returns the saved definition, or `nil` if saving failed.
    func save() async -> ExerciseDefinition? {
        guard canSave else { return nil }
        isSaving = true
        defer { isSaving = false }

        // Category and level aren't in the v1 form: keep existing values, default new ones.
        let definition = ExerciseDefinition(
            id: original?.id ?? UUID().uuidString,
            name: trimmedName,
            force: original?.force,
            level: original?.level ?? .beginner,
            mechanic: original?.mechanic,
            equipment: equipment,
            primaryMuscles: muscles.sorted { $0.displayName < $1.displayName },
            secondaryMuscles: original?.secondaryMuscles ?? [],
            instructions: original?.instructions ?? [],
            category: original?.category ?? .strength,
            images: original?.images ?? []
        )

        do {
            try await libraryRepository.save(entity: definition)
            if isEditing {
                try await workoutRepository.updateExerciseDefinition(definition)
            }
            return definition
        } catch {
            errorMessage = "Your exercise couldn't be saved. Try again."
            return nil
        }
    }

    // MARK: - Private Methods
    private func subscribeToLibrary() {
        let originalId = original?.id
        libraryRepository.entitiesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] definitions in
                self?.otherExerciseNames = definitions
                    .filter { $0.id != originalId }
                    .map(\.name)
            }
            .store(in: &cancellables)
    }
}

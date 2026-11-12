//
//  WorkoutTemplateEditorViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Combine
import Foundation
import Observation
import SwiftUI

// MARK: - WorkoutTemplateEditorViewModel
@MainActor
@Observable
final class WorkoutTemplateEditorViewModel {

    // MARK: - Properties
    var name: String
    var exercises: [ExerciseDraft]
    var expandedExerciseId: UUID?
    var isPickerPresented = false
    var errorMessage: String?
    private(set) var isSaving = false
    private(set) var otherWorkoutNames: [String] = []

    let isEditing: Bool

    @ObservationIgnored private let original: Workout?
    @ObservationIgnored private let initialExercises: [ExerciseDraft]
    @ObservationIgnored private let workoutRepository: any WorkoutRepository
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isDuplicateName: Bool {
        otherWorkoutNames.contains {
            $0.compare(trimmedName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
    }

    var nameMessage: String? {
        isDuplicateName ? "You already have a workout called \(trimmedName)." : nil
    }

    /// What's still missing before the workout can be saved.
    var requirementMessage: String? {
        if exercises.isEmpty {
            return "Add at least one exercise to save this workout."
        }
        if trimmedName.isEmpty {
            return "Name your workout to save it."
        }
        return nil
    }

    var hasChanges: Bool {
        trimmedName != (original?.name ?? "") || exercises != initialExercises
    }

    var canSave: Bool {
        !trimmedName.isEmpty && !exercises.isEmpty && !isDuplicateName && !isSaving && (!isEditing || hasChanges)
    }

    var title: String {
        isEditing ? "Edit Workout" : "New Workout"
    }

    var exercisesSubtitle: String? {
        guard !exercises.isEmpty else { return nil }
        let totalSets = exercises.reduce(0) { $0 + $1.sets }
        return "\(exercises.count) \(exercises.count == 1 ? "exercise" : "exercises") · \(totalSets) \(totalSets == 1 ? "set" : "sets")"
    }

    var definitionIdsInWorkout: Set<String> {
        Set(exercises.map(\.definition.id))
    }

    // MARK: - Initializers
    init(workoutRepository: any WorkoutRepository, workout: Workout? = nil) {
        self.workoutRepository = workoutRepository
        self.original = workout
        self.isEditing = workout != nil
        self.name = workout?.name ?? ""
        let drafts = workout?.exercises.map(ExerciseDraft.init(exercise:)) ?? []
        self.exercises = drafts
        self.initialExercises = drafts
        subscribeToWorkouts()
    }

    // MARK: - Exercises
    func toggleExpanded(_ id: UUID) {
        withAnimation(.snappy) {
            expandedExerciseId = expandedExerciseId == id ? nil : id
        }
    }

    func remove(_ id: UUID) {
        withAnimation(.snappy) {
            exercises.removeAll { $0.id == id }
            if expandedExerciseId == id {
                expandedExerciseId = nil
            }
        }
    }

    func move(from sourceIndex: Int, to destinationIndex: Int) {
        withAnimation(.spring(duration: 0.3)) {
            exercises.move(
                fromOffsets: IndexSet(integer: sourceIndex),
                toOffset: destinationIndex > sourceIndex ? destinationIndex + 1 : destinationIndex
            )
        }
    }

    func add(_ definitions: [ExerciseDefinition]) {
        withAnimation(.snappy) {
            exercises.append(contentsOf: definitions.map(ExerciseDraft.init(definition:)))
        }
    }

    /// Used by the remote catalog picker (behind `FeatureFlags.useRemoteExerciseCatalog`).
    func add(_ exercise: Exercise) {
        withAnimation(.snappy) {
            exercises.append(ExerciseDraft(exercise: exercise))
        }
    }

    // MARK: - Saving
    /// Saves the workout. Returns `true` on success.
    func save() async -> Bool {
        guard canSave else { return false }
        isSaving = true
        defer { isSaving = false }

        let workout = Workout(
            id: original?.id ?? UUID(),
            name: trimmedName,
            exercises: exercises.map(\.exercise)
        )

        do {
            try await workoutRepository.save(entity: workout)
            return true
        } catch {
            errorMessage = "Your workout couldn't be saved. Try again."
            return false
        }
    }

    // MARK: - Private Methods
    private func subscribeToWorkouts() {
        let originalId = original?.id
        workoutRepository.entitiesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] workouts in
                self?.otherWorkoutNames = workouts
                    .filter { $0.id != originalId }
                    .map(\.name)
            }
            .store(in: &cancellables)
    }
}

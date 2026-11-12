//
//  ExercisePickerViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Combine
import Foundation
import Observation

// MARK: - ExercisePickerViewModel
@MainActor
@Observable
final class ExercisePickerViewModel {

    // MARK: - Properties
    var searchText = ""
    var selectedMuscle: MuscleGroup?
    var isCreatingExercise = false
    private(set) var definitions: [ExerciseDefinition] = []
    private(set) var selectedIds: [String] = []
    private(set) var hasLoaded = false

    let definitionIdsInWorkout: Set<String>

    @ObservationIgnored private let libraryRepository: any UserExerciseLibraryRepositoryProtocol
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var availableMuscles: [MuscleGroup] {
        let used = Set(definitions.flatMap(\.primaryMuscles))
        return MuscleGroup.allCases.filter { used.contains($0) }
    }

    var filteredDefinitions: [ExerciseDefinition] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return definitions.filter { definition in
            let matchesQuery = query.isEmpty || definition.name.localizedStandardContains(query)
            let matchesMuscle = selectedMuscle.map { definition.primaryMuscles.contains($0) } ?? true
            return matchesQuery && matchesMuscle
        }
    }

    var isLibraryEmpty: Bool {
        hasLoaded && definitions.isEmpty
    }

    /// Selected definitions, in the order they were picked.
    var selectedDefinitions: [ExerciseDefinition] {
        selectedIds.compactMap { id in definitions.first { $0.id == id } }
    }

    var addButtonTitle: String {
        let count = selectedIds.count
        return "Add \(count) \(count == 1 ? "Exercise" : "Exercises")"
    }

    // MARK: - Initializers
    init(libraryRepository: any UserExerciseLibraryRepositoryProtocol, definitionIdsInWorkout: Set<String>) {
        self.libraryRepository = libraryRepository
        self.definitionIdsInWorkout = definitionIdsInWorkout
        subscribeToLibrary()
    }

    // MARK: - Public Methods
    func load() async {
        try? await libraryRepository.loadData()
        hasLoaded = true
    }

    func isSelected(_ definition: ExerciseDefinition) -> Bool {
        selectedIds.contains(definition.id)
    }

    func accessory(for definition: ExerciseDefinition) -> ExerciseLibraryCardView.Accessory {
        if !isSelected(definition), definitionIdsInWorkout.contains(definition.id) {
            return .tag("In workout")
        }
        return .selection(isSelected: isSelected(definition))
    }

    func toggle(_ definition: ExerciseDefinition) {
        if let index = selectedIds.firstIndex(of: definition.id) {
            selectedIds.remove(at: index)
        } else {
            selectedIds.append(definition.id)
        }
    }

    /// A newly created exercise comes back already selected.
    func handleCreated(_ definition: ExerciseDefinition) {
        if !selectedIds.contains(definition.id) {
            selectedIds.append(definition.id)
        }
    }

    // MARK: - Private Methods
    private func subscribeToLibrary() {
        libraryRepository.entitiesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] definitions in
                self?.definitions = definitions
            }
            .store(in: &cancellables)
    }
}

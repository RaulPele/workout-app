//
//  AddExerciseView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.06.2023.
//

import Combine
import Observation
import SwiftUI

extension AddExerciseView {

    @MainActor
    @Observable class ViewModel {

        // MARK: - Properties
        var definitions = [ExerciseDefinition]()
        var searchResults = [ExerciseDefinition]()
        var searchText = ""
        var isSearching = false
        var isAddingExercise = false
        var newExerciseName = ""
        var selectedExercise: Exercise?
        var showEditView = false
        var selectedDetailDefinition: ExerciseDefinition?

        var selectedMuscle: MuscleGroup?
        var selectedEquipment: Equipment?
        var selectedCategory: ExerciseCategory?
        var isLastPage = false
        var currentPage = 0
        var isLoadingMore = false

        var displayedDefinitions: [ExerciseDefinition] {
            if !searchText.isEmpty {
                return searchResults
            }
            return definitions
        }

        private let exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol
        private let exerciseRepository: any ExerciseRepositoryProtocol
        private let onExerciseSelected: (Exercise) -> Void
        @ObservationIgnored private var cancellables = Set<AnyCancellable>()
        @ObservationIgnored private var loadTask: Task<Void, Never>?
        @ObservationIgnored private var searchTask: Task<Void, Never>?

        // MARK: - Initializers
        init(
            exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol,
            exerciseRepository: any ExerciseRepositoryProtocol,
            onExerciseSelected: @escaping (Exercise) -> Void
        ) {
            self.exerciseDefinitionRepository = exerciseDefinitionRepository
            self.exerciseRepository = exerciseRepository
            self.onExerciseSelected = onExerciseSelected
            subscribeToDefinitions()
            loadDefinitions()
        }

        // MARK: - Private Methods
        private func subscribeToDefinitions() {
            exerciseDefinitionRepository
                .definitionsPublisher
                .sink { [weak self] definitions in
                    self?.definitions = definitions
                }
                .store(in: &cancellables)
        }

        private func loadDefinitions() {
            loadTask?.cancel()
            loadTask = Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    try await exerciseDefinitionRepository.loadDefinitions(
                        muscle: selectedMuscle,
                        equipment: selectedEquipment,
                        category: selectedCategory,
                        page: currentPage
                    )
                } catch {
                    print("Error loading definitions: \(error.localizedDescription)")
                }
            }
        }

        // MARK: - Handlers
        func handleSearchChanged(_ query: String) {
            searchTask?.cancel()
            guard !query.isEmpty else {
                searchResults = []
                isSearching = false
                return
            }

            isSearching = true
            searchTask = Task { @MainActor [weak self] in
                guard let self else { return }
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }

                do {
                    searchResults = try await exerciseDefinitionRepository.search(query: query)
                } catch {
                    print("Search error: \(error.localizedDescription)")
                }
                isSearching = false
            }
        }

        func handleFilterChanged() {
            currentPage = 0
            isLastPage = false
            definitions = []
            loadDefinitions()
        }

        func handleLoadMore() {
            guard !isLastPage, !isLoadingMore else { return }
            isLoadingMore = true
            currentPage += 1
            loadTask?.cancel()
            loadTask = Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    try await exerciseDefinitionRepository.loadDefinitions(
                        muscle: selectedMuscle,
                        equipment: selectedEquipment,
                        category: selectedCategory,
                        page: currentPage
                    )
                } catch {
                    print("Error loading more: \(error.localizedDescription)")
                }
                isLoadingMore = false
            }
        }

        func handleDefinitionTapped(_ definition: ExerciseDefinition) {
            let exercise = Exercise(
                id: .init(),
                definition: definition,
                numberOfSets: 3,
                setData: ExerciseSet(id: .init(), reps: 10),
                restBetweenSets: 60
            )
            selectedExercise = exercise
            showEditView = true
        }

        func handleExerciseEdited(_ exercise: Exercise) {
            onExerciseSelected(exercise)
        }

        func handleAddExerciseTapped() {
            Task(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                do {
                    let definition = ExerciseDefinition.legacy(name: self.newExerciseName)
                    let exercise = Exercise(id: .init(), definition: definition, numberOfSets: 0, setData: .init(id: .init(), reps: 0), restBetweenSets: 0)
                    try await self.exerciseRepository.save(entity: exercise)
                    await MainActor.run {
                        self.newExerciseName = ""
                        self.isAddingExercise = false
                    }
                } catch {
                    print("Error while saving exercise: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct AddExerciseView: View {

    @State private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol,
        exerciseRepository: any ExerciseRepositoryProtocol,
        onExerciseSelected: @escaping (Exercise) -> Void
    ) {
        self._viewModel = .init(wrappedValue: ViewModel(
            exerciseDefinitionRepository: exerciseDefinitionRepository,
            exerciseRepository: exerciseRepository,
            onExerciseSelected: onExerciseSelected
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                filterChips
                definitionsList
                createExerciseButton
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.isAddingExercise) {
                AddNewExerciseSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showEditView) {
                if let exercise = viewModel.selectedExercise {
                    EditExerciseSheetWrapper(
                        exercise: exercise,
                        onFinishedEditing: { editedExercise in
                            viewModel.handleExerciseEdited(editedExercise)
                            viewModel.showEditView = false
                            dismiss()
                        }
                    )
                }
            }
            .sheet(item: $viewModel.selectedDetailDefinition) { definition in
                ExerciseDefinitionDetailView(definition: definition)
            }
        }
    }
}

// MARK: - Search Bar
private extension AddExerciseView {
    var searchBar: some View {
        TextField("Search exercises", text: $viewModel.searchText)
            .textFieldStyle(.roundedBorder)
            .padding()
            .onChange(of: viewModel.searchText) { _, newValue in
                viewModel.handleSearchChanged(newValue)
            }
    }
}

// MARK: - Filter Chips
private extension AddExerciseView {
    var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterMenu(
                    title: "Muscle",
                    selection: $viewModel.selectedMuscle,
                    options: MuscleGroup.allCases
                )

                FilterMenu(
                    title: "Equipment",
                    selection: $viewModel.selectedEquipment,
                    options: Equipment.allCases
                )

                FilterMenu(
                    title: "Category",
                    selection: $viewModel.selectedCategory,
                    options: ExerciseCategory.allCases
                )

                if viewModel.selectedMuscle != nil || viewModel.selectedEquipment != nil || viewModel.selectedCategory != nil {
                    Button("Clear", role: .destructive) {
                        viewModel.selectedMuscle = nil
                        viewModel.selectedEquipment = nil
                        viewModel.selectedCategory = nil
                        viewModel.handleFilterChanged()
                    }
                    .font(.caption)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Definitions List
private extension AddExerciseView {
    var definitionsList: some View {
        Group {
            if viewModel.displayedDefinitions.isEmpty && !viewModel.searchText.isEmpty {
                ContentUnavailableView(
                    "No exercises found",
                    systemImage: "magnifyingglass",
                    description: Text("Try a different search term or filter")
                )
            } else {
                List {
                    ForEach(viewModel.displayedDefinitions) { definition in
                        Button {
                            viewModel.handleDefinitionTapped(definition)
                        } label: {
                            ExerciseDefinitionRow(
                                definition: definition,
                                onInfoTapped: {
                                    viewModel.selectedDetailDefinition = definition
                                }
                            )
                        }
                        .onAppear {
                            if definition.id == viewModel.displayedDefinitions.last?.id {
                                viewModel.handleLoadMore()
                            }
                        }
                    }

                    if viewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: - Create Exercise Button
private extension AddExerciseView {
    var createExerciseButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                viewModel.isAddingExercise = true
            } label: {
                Label("Create New Exercise", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - ExerciseDefinitionRow
private struct ExerciseDefinitionRow: View {
    let definition: ExerciseDefinition
    let onInfoTapped: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(definition.name)
                    .font(.body)
                    .bold()
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    ForEach(definition.primaryMuscles, id: \.self) { muscle in
                        Text(muscle.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.primaryColor.opacity(0.15))
                            .clipShape(.capsule)
                    }

                    if let equipment = definition.equipment {
                        Text(equipment.displayName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 4) {
                    Text(definition.level.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(levelColor(definition.level).opacity(0.15))
                        .foregroundStyle(levelColor(definition.level))
                        .clipShape(.capsule)

                    Text(definition.category.displayName)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Button("Info", systemImage: "info.circle") {
                onInfoTapped()
            }
            .labelStyle(.iconOnly)
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
        }
    }

    private func levelColor(_ level: ExerciseLevel) -> Color {
        switch level {
        case .beginner: .green
        case .intermediate: .orange
        case .expert: .red
        }
    }
}

// MARK: - Filter Menu
private struct FilterMenu<T: Hashable & CaseIterable & RawRepresentable>: View where T.AllCases: RandomAccessCollection {
    let title: String
    @Binding var selection: T?
    let options: T.AllCases

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    if selection == option {
                        Label(displayName(for: option), systemImage: "checkmark")
                    } else {
                        Text(displayName(for: option))
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selection.map { displayName(for: $0) } ?? title)
                    .font(.caption)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(selection != nil ? Color.primaryColor.opacity(0.15) : Color.secondary.opacity(0.1))
            .foregroundStyle(selection != nil ? Color.primaryColor : .secondary)
            .clipShape(.capsule)
        }
    }

    private func displayName(for option: T) -> String {
        if let muscle = option as? MuscleGroup { return muscle.displayName }
        if let equipment = option as? Equipment { return equipment.displayName }
        if let category = option as? ExerciseCategory { return category.displayName }
        return String(describing: option)
    }
}

// MARK: - Add New Exercise Sheet
private struct AddNewExerciseSheet: View {
    @Bindable var viewModel: AddExerciseView.ViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Exercise name", text: $viewModel.newExerciseName)
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.isAddingExercise = false
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.handleAddExerciseTapped()
                        dismiss()
                    }
                    .bold()
                    .disabled(viewModel.newExerciseName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Exercise Sheet Wrapper
private struct EditExerciseSheetWrapper: View {
    let exercise: Exercise
    let onFinishedEditing: (Exercise) -> Void
    @State private var editedExercise: Exercise

    init(exercise: Exercise, onFinishedEditing: @escaping (Exercise) -> Void) {
        self.exercise = exercise
        self.onFinishedEditing = onFinishedEditing
        _editedExercise = State(initialValue: exercise)
    }

    var body: some View {
        EditView(
            exercise: $editedExercise,
            onFinishedEditing: {
                onFinishedEditing(editedExercise)
            }
        )
    }
}

#Preview {
    AddExerciseView(
        exerciseDefinitionRepository: MockedExerciseDefinitionRepository(),
        exerciseRepository: MockedExerciseRepository(),
        onExerciseSelected: { _ in }
    )
}

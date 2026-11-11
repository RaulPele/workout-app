//
//  ExerciseLibraryPicker.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.05.2026.
//

import SwiftUI

// MARK: - Route
enum ExerciseLibraryRoute: Hashable {
    case create
    case edit(ExerciseDefinition)
}

struct ExerciseLibraryPicker: View {

    // MARK: - Properties
    @State private var viewModel: ViewModel
    @State private var path: [ExerciseLibraryRoute] = []
    @Environment(\.dismiss) private var dismiss

    private let onExerciseSelected: (Exercise) -> Void

    init(
        libraryRepository: any UserExerciseLibraryRepositoryProtocol,
        onExerciseSelected: @escaping (Exercise) -> Void
    ) {
        self._viewModel = State(wrappedValue: ViewModel(libraryRepository: libraryRepository))
        self.onExerciseSelected = onExerciseSelected
    }

    // MARK: - Body
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                searchField
                content
            }
            .background(Color.background)
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        path.append(.create)
                    } label: {
                        Label("New", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(for: ExerciseLibraryRoute.self) { route in
                switch route {
                case .create:
                    EditExerciseDefinitionView(
                        viewModel: .init(libraryRepository: viewModel.libraryRepository)
                    )
                case .edit(let definition):
                    EditExerciseDefinitionView(
                        viewModel: .init(
                            libraryRepository: viewModel.libraryRepository,
                            editing: definition
                        )
                    )
                }
            }
            .appBottomSheet(isPresented: $viewModel.showEditSetsSheet) {
                if let exercise = viewModel.selectedExercise {
                    EditView(
                        exercise: exercise,
                        onFinishedEditing: { editedExercise in
                            onExerciseSelected(editedExercise)
                            viewModel.showEditSetsSheet = false
                            dismiss()
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Search Field
private extension ExerciseLibraryPicker {
    var searchField: some View {
        AppTextField(
            "Search exercises",
            text: $viewModel.searchText,
            leadingIcon: "magnifyingglass",
            trailingIcon: viewModel.searchText.isEmpty ? nil : "xmark.circle.fill",
            onTrailingIconTapped: { viewModel.searchText = "" }
        )
        .padding()
    }
}

// MARK: - Content
private extension ExerciseLibraryPicker {
    @ViewBuilder
    var content: some View {
        if !viewModel.hasDefinitions {
            EmptyLibraryView {
                path.append(.create)
            }
            .frame(maxHeight: .infinity)
        } else if viewModel.displayedDefinitions.isEmpty {
            ContentUnavailableView(
                "No matches",
                systemImage: "magnifyingglass",
                description: Text("Try a different search term.")
            )
            .frame(maxHeight: .infinity)
        } else {
            definitionsList
        }
    }

    var definitionsList: some View {
        List {
            ForEach(viewModel.displayedDefinitions) { definition in
                Button {
                    viewModel.handleTap(definition)
                } label: {
                    LibraryRow(definition: definition)
                }
                .listRowBackground(Color.surface)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.handleDelete(definition)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .contextMenu {
                    Button {
                        path.append(.edit(definition))
                    } label: {
                        Label("Edit", systemImage: "square.and.pencil")
                    }

                    Button(role: .destructive) {
                        viewModel.handleDelete(definition)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.background)
    }
}

// MARK: - Empty State
private struct EmptyLibraryView: View {
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No exercises yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Create your own exercise library to use in your workouts.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Button {
                onCreate()
            } label: {
                Label("Create Exercise", systemImage: "plus")
                    .font(.subheadline)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Library Row
private struct LibraryRow: View {
    let definition: ExerciseDefinition

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(definition.name)
                    .font(.body)
                    .bold()
                    .foregroundStyle(Color.onBackground)

                if !definition.primaryMuscles.isEmpty || definition.equipment != nil {
                    HStack(spacing: 6) {
                        ForEach(definition.primaryMuscles, id: \.self) { muscle in
                            Text(muscle.displayName)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.primaryColor.opacity(0.15))
                                .foregroundStyle(Color.primaryColor)
                                .clipShape(.capsule)
                        }

                        if let equipment = definition.equipment {
                            Text(equipment.displayName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.onBackground.opacity(0.3))
        }
        .contentShape(.rect)
    }
}

// MARK: - Previews
#Preview("Empty") {
    ExerciseLibraryPicker(
        libraryRepository: MockedUserExerciseLibraryRepository(),
        onExerciseSelected: { _ in }
    )
}

#Preview("Populated") {
    ExerciseLibraryPicker(
        libraryRepository: MockedUserExerciseLibraryRepository(seed: [
            .mockedBBBenchPress,
            .mockedBBSquats,
            .mockedPullUp
        ]),
        onExerciseSelected: { _ in }
    )
}

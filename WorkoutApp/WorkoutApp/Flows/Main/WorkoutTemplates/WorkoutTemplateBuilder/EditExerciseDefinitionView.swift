//
//  EditExerciseDefinitionView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.05.2026.
//

import SwiftUI

struct EditExerciseDefinitionView: View {

    // MARK: - Properties
    @State private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                NameCard(name: $viewModel.name)
                MusclesCard(selection: $viewModel.primaryMuscles)
                EquipmentCard(selection: $viewModel.equipment)
                CategoryCard(selection: $viewModel.category)
                LevelCard(selection: $viewModel.level)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.background)
        .navigationTitle(viewModel.isEditing ? "Edit Exercise" : "New Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await viewModel.save()
                        dismiss()
                    }
                } label: {
                    Text("Save").bold()
                }
                .disabled(!viewModel.isValid || viewModel.isSaving)
            }
        }
    }
}

// MARK: - Name Card
private struct NameCard: View {
    @Binding var name: String

    var body: some View {
        SectionCard(icon: "textformat", title: "Name") {
            AppTextField("Exercise name", text: $name)
        }
    }
}

// MARK: - Muscles Card
private struct MusclesCard: View {
    @Binding var selection: Set<MuscleGroup>

    var body: some View {
        SectionCard(icon: "figure.strengthtraining.traditional", title: "Primary Muscles") {
            NavigationLink {
                MuscleSelectionView(selection: $selection)
            } label: {
                HStack(spacing: 12) {
                    summaryLabel
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.onBackground.opacity(0.4))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(Color.surface2)
                .clipShape(.rect(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var summaryLabel: some View {
        if selection.isEmpty {
            Text("Select muscles")
                .foregroundStyle(Color.onBackground.opacity(0.5))
        } else {
            let names = selection
                .sorted { $0.displayName < $1.displayName }
                .map(\.displayName)
                .joined(separator: ", ")
            Text(names)
                .foregroundStyle(Color.onBackground)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Equipment Card
private struct EquipmentCard: View {
    @Binding var selection: Equipment?

    var body: some View {
        SectionCard(icon: "wrench.and.screwdriver", title: "Equipment") {
            Menu {
                Button {
                    selection = nil
                } label: {
                    if selection == nil {
                        Label("None", systemImage: "checkmark")
                    } else {
                        Text("None")
                    }
                }

                ForEach(Equipment.allCases, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        if selection == option {
                            Label(option.displayName, systemImage: "checkmark")
                        } else {
                            Text(option.displayName)
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Text(selection?.displayName ?? "None")
                        .foregroundStyle(Color.onBackground)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.onBackground.opacity(0.4))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(Color.surface2)
                .clipShape(.rect(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Category Card
private struct CategoryCard: View {
    @Binding var selection: ExerciseCategory

    var body: some View {
        SectionCard(icon: "tag", title: "Category") {
            Menu {
                ForEach(ExerciseCategory.allCases, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        if selection == option {
                            Label(option.displayName, systemImage: "checkmark")
                        } else {
                            Text(option.displayName)
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Text(selection.displayName)
                        .foregroundStyle(Color.onBackground)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.onBackground.opacity(0.4))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(Color.surface2)
                .clipShape(.rect(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Level Card
private struct LevelCard: View {
    @Binding var selection: ExerciseLevel

    var body: some View {
        SectionCard(icon: "chart.bar", title: "Level") {
            Picker("Level", selection: $selection) {
                ForEach(ExerciseLevel.allCases, id: \.self) { level in
                    Text(level.displayName).tag(level)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

// MARK: - Section Card
private struct SectionCard<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(Color.onBackground)

            content()
                .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .clipShape(.rect(cornerRadius: 14))
        .shadow(color: Color.onBackground.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Muscle Selection
struct MuscleSelectionView: View {

    @Binding var selection: Set<MuscleGroup>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                Button {
                    if selection.contains(muscle) {
                        selection.remove(muscle)
                    } else {
                        selection.insert(muscle)
                    }
                } label: {
                    HStack {
                        Text(muscle.displayName)
                            .foregroundStyle(Color.onBackground)

                        Spacer()

                        if selection.contains(muscle) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.primaryColor)
                                .bold()
                        }
                    }
                }
                .listRowBackground(Color.surface)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.background)
        .navigationTitle("Primary Muscles")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
                    .bold()
            }
        }
    }
}

// MARK: - Previews
#Preview("Create") {
    NavigationStack {
        EditExerciseDefinitionView(
            viewModel: .init(libraryRepository: MockedUserExerciseLibraryRepository())
        )
    }
}

#Preview("Edit") {
    NavigationStack {
        EditExerciseDefinitionView(
            viewModel: .init(
                libraryRepository: MockedUserExerciseLibraryRepository(),
                editing: .mockedBBBenchPress
            )
        )
    }
}

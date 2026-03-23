//
//  ExerciseDefinitionDetailView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import SwiftUI

struct ExerciseDefinitionDetailView: View {

    // MARK: - Properties
    let definition: ExerciseDefinition
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    badgesSection
                    musclesSection
                    equipmentSection
                    instructionsSection
                    imageGallery
                }
                .padding()
            }
            .background(Color.background)
            .navigationTitle(definition.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Badges Section
private extension ExerciseDefinitionDetailView {
    var badgesSection: some View {
        HStack(spacing: 8) {
            Badge(text: definition.category.displayName, color: .primaryColor)
            Badge(text: definition.level.displayName, color: levelColor)

            if let force = definition.force {
                Badge(text: force.displayName, color: .secondary)
            }
            if let mechanic = definition.mechanic {
                Badge(text: mechanic.displayName, color: .secondary)
            }
        }
    }

    var levelColor: Color {
        switch definition.level {
        case .beginner: .green
        case .intermediate: .orange
        case .expert: .red
        }
    }
}

// MARK: - Muscles Section
private extension ExerciseDefinitionDetailView {
    var musclesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !definition.primaryMuscles.isEmpty {
                MuscleTagGroup(title: "Primary Muscles", muscles: definition.primaryMuscles, isPrimary: true)
            }
            if !definition.secondaryMuscles.isEmpty {
                MuscleTagGroup(title: "Secondary Muscles", muscles: definition.secondaryMuscles, isPrimary: false)
            }
        }
    }
}

// MARK: - Equipment Section
private extension ExerciseDefinitionDetailView {
    @ViewBuilder
    var equipmentSection: some View {
        if let equipment = definition.equipment {
            VStack(alignment: .leading, spacing: 6) {
                Text("Equipment")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Color.onBackground)

                HStack(spacing: 6) {
                    Image(systemName: "dumbbell")
                        .foregroundStyle(Color.primaryColor)
                    Text(equipment.displayName)
                        .foregroundStyle(Color.onBackground)
                }
                .font(.body)
            }
        }
    }
}

// MARK: - Instructions Section
private extension ExerciseDefinitionDetailView {
    @ViewBuilder
    var instructionsSection: some View {
        if !definition.instructions.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Instructions")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Color.onBackground)

                ForEach(definition.instructions.enumerated(), id: \.element) { index, instruction in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(Color.primaryColor)
                            .clipShape(.circle)

                        Text(instruction)
                            .font(.body)
                            .foregroundStyle(Color.onBackground)
                    }
                }
            }
        }
    }
}

// MARK: - Image Gallery
private extension ExerciseDefinitionDetailView {
    @ViewBuilder
    var imageGallery: some View {
        if !definition.images.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Images")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Color.onBackground)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(definition.images, id: \.self) { imageURL in
                            AsyncImage(url: URL(string: imageURL)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 200, height: 200)
                                        .clipShape(.rect(cornerRadius: 12))
                                case .failure:
                                    imagePlaceholder
                                case .empty:
                                    ProgressView()
                                        .frame(width: 200, height: 200)
                                @unknown default:
                                    imagePlaceholder
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.surface)
            .frame(width: 200, height: 200)
            .overlay {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
            }
    }
}

// MARK: - Badge
private struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .bold()
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(.capsule)
    }
}

// MARK: - Muscle Tag Group
private struct MuscleTagGroup: View {
    let title: String
    let muscles: [MuscleGroup]
    let isPrimary: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.onBackground)

            FlowLayout(spacing: 6) {
                ForEach(muscles, id: \.self) { muscle in
                    Text(muscle.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isPrimary ? Color.primaryColor.opacity(0.15) : Color.secondary.opacity(0.1))
                        .foregroundStyle(isPrimary ? Color.primaryColor : .secondary)
                        .clipShape(.capsule)
                }
            }
        }
    }
}

// MARK: - Flow Layout
private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions = [CGPoint]()
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX - spacing)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}

#Preview {
    ExerciseDefinitionDetailView(definition: .mockedBBBenchPress)
}

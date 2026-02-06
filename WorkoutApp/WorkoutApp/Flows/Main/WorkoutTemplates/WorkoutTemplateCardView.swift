//
//  WorkoutTemplateCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 30.05.2023.
//

import SwiftUI

struct WorkoutTemplateCardView: View {
    
    let workout: Workout
    
    private let maxVisibleExercises = 3
    private let cardCornerRadius: CGFloat = 16
    
    var body: some View {
        VStack(alignment: .leading) {
            CardHeaderView(title: workout.name)
            
            Divider()
                .foregroundStyle(.secondary.opacity(0.3))
                        
            if !workout.exercises.isEmpty {
                ExerciseListView(
                    exercises: workout.exercises,
                    maxVisible: maxVisibleExercises
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(ExerciseCountBadge(count: workout.exercises.count), alignment: .topTrailing)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surface)
        .clipShape(.rect(cornerRadius: cardCornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Card Header View

private struct CardHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.onSurface)
                .lineLimit(2)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Exercise Count Badge

private struct ExerciseCountBadge: View {
    let count: Int
    
    var body: some View {
        HStack {
            
            HStack(spacing: .small) {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(Color.primaryColor)
                    .font(.caption)
                
                Text(exerciseCountText)
                    .foregroundStyle(Color.onSurface)
                    .font(.subheadline)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.primaryColor.opacity(0.15))
            .clipShape(.rect(cornerRadius: 8))
        }
    }
    
    private var exerciseCountText: String {
        "\(count) \(count == 1 ? "exercise" : "exercises")"
    }
}

// MARK: - Exercise List View

private struct ExerciseListView: View {
    let exercises: [Exercise]
    let maxVisible: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: .extraSmall) {
            ForEach(exercises.prefix(maxVisible)) { exercise in
                ExerciseRowView(name: exercise.name)
            }
            
            if exercises.count > maxVisible {
                MoreExercisesIndicator(count: exercises.count - maxVisible)
            }
        }
        .padding(.top, .extraSmall)
    }
}

// MARK: - Exercise Row View

private struct ExerciseRowView: View {
    let name: String
    
    var body: some View {
        HStack(spacing: .small) {
            Circle()
                .fill(Color.primaryColor)
                .frame(width: 4, height: 4)
            
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - More Exercises Indicator

private struct MoreExercisesIndicator: View {
    let count: Int
    
    var body: some View {
        Text("+\(count) more")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.leading, 10)
    }
}

// MARK: - Spacing Extensions

private extension CGFloat {
    static let extraSmall: CGFloat = 4
    static let small: CGFloat = 6
    static let `default`: CGFloat = 12
}

#Preview {
    ZStack {
        Color.background
            .ignoresSafeArea()
        WorkoutTemplateCardView(workout: .mockedWorkoutTemplate)
    }
}

//
//  ExerciseCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.05.2023.
//

import Foundation
import SwiftUI

struct ExerciseCardView: View {
    
    //MARK: - Properties
    let exercise: Exercise
    let isEditMode: Bool
    let onDeleteAction: (() -> Void)?
    let onTapAction: (() -> Void)?
    
    @State private var glowOpacity: CGFloat = 0.6
    
    //MARK: - Initializers
    init(
        exercise: Exercise,
        isEditMode: Bool = false,
        onDeleteAction: (() -> Void)? = nil,
        onTapAction: (() -> Void)? = nil
    ) {
        self.exercise = exercise
        self.isEditMode = isEditMode
        self.onDeleteAction = onDeleteAction
        self.onTapAction = onTapAction
    }
    
    //MARK: - Properties
    var body: some View {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(exercise.name)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.onBackground)
//                    .lineLimit(2) //TODO: test with long names
                    
                    HStack(spacing: 6) {
                        metricCapsule(
                            systemImage: "repeat",
                            value: "\(exercise.numberOfSets)",
                            label: "Sets"
                        )
                        
                        metricCapsule(
                            systemImage: "number",
                            value: "\(exercise.setData.reps)",
                            label: "Reps"
                        )
                        
                        metricCapsule(
                            systemImage: "timer",
                            value: formatRestTime(exercise.restBetweenSets),
                            label: "Rest"
                        )
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .trailing) {
                deleteButton
            }
            .containerShape(.rect(cornerRadius: 16, style: .continuous))
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.surface)
            }
            .overlay {
                if isEditMode {
                    glowingBorder
                }
            }
            .shadow(color: isEditMode ? Color.primaryColor.opacity(0.3) : .black.opacity(0.05), 
                   radius: isEditMode ? 12 : 8, 
                   x: 0, 
                   y: 2)
            .onTapGesture {
                if isEditMode {
                    onTapAction?()
                }
            }
            .onAppear {
                if isEditMode {
                    startGlowAnimation()
                }
            }
            .onChange(of: isEditMode) { _, newValue in
                if newValue {
                    startGlowAnimation()
                } else {
                    glowOpacity = 0.6
                }
            }
//        .disabled(!isEditMode)
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            onDeleteAction?()
        } label: {
            Image(systemName: "trash")
                .font(.body)
                .foregroundStyle(.white)
                .frame(maxHeight: .infinity)
                .frame(width: 64)
                .background {
                    ConcentricRectangle()
                        .fill(Color.red)
                }
        }
        .accessibilityLabel("Remove exercise")
        .scaleEffect(x: isEditMode ? 1 : 0, anchor: .trailing)
        .opacity(isEditMode ? 1 : 0)
        .disabled(!isEditMode)
        .animation(.spring(duration: 0.3), value: isEditMode)
//        .allowsHitTesting(isEditMode)
    }
    
    private func metricCapsule(systemImage: String, value: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.caption2)
                .foregroundStyle(Color.primaryColor)
            
            Text("\(value) \(label)")
                .font(.caption)
                .foregroundStyle(Color.onBackground)
        }
        .lineLimit(1)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background {
            Capsule(style: .continuous)
                .fill(Color.primaryColor.opacity(0.1))
        }
    }
    
    private func formatRestTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    private var glowingBorder: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(
                Color.primaryColor.opacity(glowOpacity),
                lineWidth: 2.5
            )
            .shadow(
                color: Color.primaryColor.opacity(glowOpacity * 0.6),
                radius: 8
            )
    }
    
    private func startGlowAnimation() {
        glowOpacity = 0.6
        Task {
            try? await Task.sleep(for: .milliseconds(50))
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                glowOpacity = 1.0
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ExerciseCardView(
            exercise: .mockedBBSquats,
            isEditMode: true,
            onDeleteAction: {}
        )
        
        ExerciseCardView(
            exercise: .mockedBBBenchPress,
            isEditMode: false
        )
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background)
}

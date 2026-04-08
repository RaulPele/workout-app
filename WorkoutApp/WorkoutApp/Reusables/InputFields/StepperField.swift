//
//  StepperField.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.04.2026.
//

import SwiftUI

struct StepperField: View {

    // MARK: - Properties
    let label: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...999
    var step: Int = 1
    var formatValue: ((Int) -> String)? = nil
    var onValueTapped: (() -> Void)? = nil

    // MARK: - Body
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.onBackground.opacity(0.6))

            HStack(spacing: 16) {
                stepperButton(
                    label: "Decrease \(label)",
                    icon: "minus",
                    isDisabled: value <= range.lowerBound
                ) {
                    value = max(value - step, range.lowerBound)
                }

                valueDisplay

                stepperButton(
                    label: "Increase \(label)",
                    icon: "plus",
                    isDisabled: value >= range.upperBound
                ) {
                    value = min(value + step, range.upperBound)
                }
            }
        }
        .animation(.snappy, value: value)
    }
}

// MARK: - Value Display
private extension StepperField {
    var valueDisplay: some View {
        Group {
            let displayText = formatValue?(value) ?? "\(value)"
            Text(displayText)
                .font(.title2)
                .bold()
                .monospacedDigit()
                .foregroundStyle(Color.onBackground)
                .contentTransition(.numericText())
        }
        .onTapGesture {
            onValueTapped?()
        }
    }
}

// MARK: - Stepper Button
private extension StepperField {
    func stepperButton(label: String, icon: String, isDisabled: Bool, action: @escaping () -> Void) -> some View {
        Button(label, systemImage: icon) {
            action()
        }
        .labelStyle(.iconOnly)
        .font(.body.weight(.semibold))
        .foregroundStyle(Color.primaryColor)
        .frame(width: 40, height: 40)
        .background(Color.primaryColor.opacity(0.15))
        .clipShape(.circle)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.3 : 1)
    }
}

// MARK: - Previews
#Preview {
    VStack(spacing: 32) {
        HStack(spacing: 0) {
            StepperField(label: "Sets", value: .constant(4), range: 1...20)
                .frame(maxWidth: .infinity)
            StepperField(label: "Reps", value: .constant(10), range: 1...100)
                .frame(maxWidth: .infinity)
        }

        StepperField(
            label: "Rest",
            value: .constant(150),
            range: 0...600,
            step: 15,
            formatValue: { seconds in
                let m = seconds / 60
                let s = seconds % 60
                if m > 0 && s > 0 { return "\(m)m \(s)s" }
                if m > 0 { return "\(m)m" }
                return "\(s)s"
            },
            onValueTapped: {}
        )
    }
    .padding()
    .background(Color.background)
}

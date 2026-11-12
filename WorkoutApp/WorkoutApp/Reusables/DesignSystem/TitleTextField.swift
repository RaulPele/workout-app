//
//  TitleTextField.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - TitleTextField
/// A large, title-sized text field with an accent underline and an optional inline message.
struct TitleTextField: View {

    // MARK: - Properties
    let placeholder: String
    @Binding var text: String
    var message: String?
    var isError = false
    var autofocus = false

    @FocusState private var isFocused: Bool

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField(placeholder, text: $text)
                .font(.title.bold())
                .foregroundStyle(Color.onBackground)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .focused($isFocused)

            Capsule()
                .fill(isFocused ? Color.primaryColor : Color.divider)
                .frame(height: 2)
                .animation(.snappy, value: isFocused)

            if let message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(isError ? Color.red : Color.secondary)
                    .transition(.opacity)
            }
        }
        .animation(.snappy, value: message)
        .task {
            if autofocus {
                isFocused = true
            }
        }
    }
}

// MARK: - Previews
#Preview {
    TitleTextField(placeholder: "Workout name", text: .constant("Push Day"), message: "You already have a workout called Push Day.", isError: true)
        .padding()
        .background(Color.background)
}

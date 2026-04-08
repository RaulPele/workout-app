//
//  AppTextField.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.03.2026.
//

import SwiftUI

struct AppTextField: View {

    // MARK: - Properties
    let placeholder: String
    @Binding var text: String

    var leadingIcon: String?
    var trailingIcon: String?
    var onTrailingIconTapped: (() -> Void)?
    var keyboardType: UIKeyboardType = .default
    var textAlignment: TextAlignment = .leading
    var digitsOnly: Bool = false

    @FocusState private var isFocused: Bool

    // MARK: - Initializers
    init(
        _ placeholder: String,
        text: Binding<String>,
        leadingIcon: String? = nil,
        trailingIcon: String? = nil,
        onTrailingIconTapped: (() -> Void)? = nil,
        keyboardType: UIKeyboardType = .default,
        textAlignment: TextAlignment = .leading,
        digitsOnly: Bool = false
    ) {
        self.placeholder = placeholder
        self._text = text
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.onTrailingIconTapped = onTrailingIconTapped
        self.keyboardType = keyboardType
        self.textAlignment = textAlignment
        self.digitsOnly = digitsOnly
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 8) {
            leadingIconView
            textField
            trailingIconView
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(isFocused ? Color.surface2 : Color.surface)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused ? Color.primaryColor : Color.divider,
                    lineWidth: isFocused ? 1.5 : 1
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Leading Icon
private extension AppTextField {
    @ViewBuilder
    var leadingIconView: some View {
        if let leadingIcon {
            Image(systemName: leadingIcon)
                .foregroundStyle(isFocused ? Color.primaryColor : Color.onBackground.opacity(0.5))
        }
    }
}

// MARK: - Input Field
private extension AppTextField {
    var textField: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .multilineTextAlignment(textAlignment)
            .foregroundStyle(Color.onBackground)
            .focused($isFocused)
            .autocorrectionDisabled()
            .onChange(of: text) { _, newValue in
                guard digitsOnly else { return }
                let filtered = newValue.filter { "0123456789".contains($0) }
                if filtered != newValue {
                    text = filtered
                }
            }
    }
}

// MARK: - Trailing Icon
private extension AppTextField {
    @ViewBuilder
    var trailingIconView: some View {
        if let trailingIcon {
            Button {
                onTrailingIconTapped?()
            } label: {
                Image(systemName: trailingIcon)
                    .foregroundStyle(Color.onBackground.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Previews
#Preview("Search Field") {
    @Previewable @State var text = ""
    VStack(spacing: 16) {
        AppTextField(
            "Search exercises",
            text: $text,
            leadingIcon: "magnifyingglass",
            trailingIcon: text.isEmpty ? nil : "xmark.circle.fill",
            onTrailingIconTapped: { text = "" }
        )

        AppTextField("Exercise name", text: $text)

        HStack {
            Text("Sets")
            Spacer()
            AppTextField(
                "0",
                text: $text,
                keyboardType: .numberPad,
                textAlignment: .trailing,
                digitsOnly: true
            )
            .frame(width: 80)
        }
    }
    .padding()
    .background(Color.background)
}

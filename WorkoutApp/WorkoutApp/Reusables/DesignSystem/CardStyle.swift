//
//  CardStyle.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - CardStyle
/// The single card surface used across the app: padded content on a rounded `surface` background.
struct CardStyle: ViewModifier {
    static let cornerRadius: CGFloat = 20

    var background: Color = .surface

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: .rect(cornerRadius: Self.cornerRadius, style: .continuous))
            .contentShape(.rect(cornerRadius: Self.cornerRadius, style: .continuous))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: Self.cornerRadius, style: .continuous))
    }
}

// MARK: - View Extension
extension View {
    func cardStyle(background: Color = .surface) -> some View {
        modifier(CardStyle(background: background))
    }
}

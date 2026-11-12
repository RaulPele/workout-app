//
//  Binding+Presenting.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

extension Binding where Value == Bool {

    /// `true` while `item` holds a value; setting it to `false` clears the item.
    /// Handy for alerts and confirmation dialogs driven by an optional.
    init<Item>(presenting item: Binding<Item?>) {
        self.init(
            get: { item.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    item.wrappedValue = nil
                }
            }
        )
    }
}

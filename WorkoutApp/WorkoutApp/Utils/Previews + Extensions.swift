//
//  Previews + Extensions.swift
//  WorkoutApp
//
//  Created by Raul Pele on 08.04.2023.
//

import Foundation
import SwiftUI

extension PreviewDevice {
    
    static let iPhoneSE_3rd = PreviewDevice(rawValue: "iPhone SE (3rd generation)")
    static let iPhone13 = PreviewDevice(rawValue: "iPhone 13")
    static let iPhone14Pro = PreviewDevice(rawValue: "iPhone 14 Pro")
    static let iPhone13Max = PreviewDevice(rawValue: "iPhone 13 Pro Max")
    static let iPhone8Plus = PreviewDevice(rawValue: "iPhone 8 Plus")
//    static let iPhone8 = PreviewDevice(rawValue: "iPhone 8")
}

extension PreviewDevice: Identifiable {
    public var id: String { self.rawValue }
}

extension PreviewProvider {
    static var previewDevices: [PreviewDevice] {
        [.iPhone14Pro, .iPhoneSE_3rd]
    }
}

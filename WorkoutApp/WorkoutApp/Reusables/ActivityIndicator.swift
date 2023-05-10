//
//  ActivityIndicator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 08.04.2023.
//

import SwiftUI

struct ActivityIndicator: View {
    
    var color: Color = .gray
    var scale: CGFloat = 1
    
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(color)
            .scaleEffect(scale)
    }
}

#if DEBUG
struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator()
    }
}
#endif

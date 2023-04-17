//
//  ActivityIndicator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 08.04.2023.
//

import SwiftUI

struct ActivityIndicator: View {
    
    @State var color: Color = .gray
    
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(color)
    }
}

#if DEBUG
struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator()
    }
}
#endif

//
//  SeeSessionDetailsView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.06.2023.
//

import SwiftUI

struct SeeSessionDetailsView: View {
    var body: some View {
        VStack(spacing: 60) {
            Spacer()
            Text("Analyze your workout sessions!")
                .font(.heading1)
                .foregroundColor(Color.onBackground)
                .multilineTextAlignment(.center)
            
                Image("workout-details-view")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .shadow(color: .white, radius: 8)
                    .frame(maxWidth: 250)
            Spacer()
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.background)
    }
    
}

struct SeeSessionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        SeeSessionDetailsView()
    }
}

//
//  WorkoutCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.05.2023.
//

import SwiftUI

extension TimeInterval {
    
    func formatted() -> String {
        let formatter = DateComponentsFormatter()
        return formatter.string(from: self) ?? "cannot format date"
    }
}

struct WorkoutCardView: View {
    
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
                Text(workout.title ?? "No title")
                    .foregroundColor(.white)
                    .font(.heading3)
                Text(workout.duration?.formatted() ?? "0:00:00")
                    .foregroundColor(.white)
                    .bold()
                Text("\(workout.activeCalories ?? 0) KCAL")
                    .foregroundColor(.white)
                //                .font(<#T##font: Font?##Font?#>)
                
            }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(dateView, alignment: .bottomTrailing)
        .padding()
        .background(Color.background)
        .cornerRadius(15)
    }
}

private extension WorkoutCardView {
    
    var dateView: some View {
        Text(workout.endDate ?? .now, style: .date)
            .foregroundColor(.white)
    }
}

#if DEBUG
struct WorkoutCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background
            WorkoutCardView(workout: .mocked1)
        }
    }
}
#endif

//
//  WorkoutTemplateCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 30.05.2023.
//

import SwiftUI

struct WorkoutTemplateCardView: View {
    
    let workoutTemplate: WorkoutTemplate
    let maxExerciseCount = 3
       
       var body: some View {
           VStack(alignment: .leading, spacing: 8) {
               Text(workoutTemplate.name)
                   .font(.heading2)
                   .foregroundColor(.onSurface)

               Text("Exercises: \(workoutTemplate.exercises.count)")
                   .foregroundColor(.onSurface)
           }
           .padding()
           .frame(maxWidth: .infinity, alignment: .leading)
           .background(Color.surface)
           .cornerRadius(15)
           .shadow(radius: 3)
       }
    }

#if DEBUG
struct WorkoutTemplateCardView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(previewDevices) { device in
            WorkoutTemplateCardView(workoutTemplate: .mockedWorkoutTemplate)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.background)
                .preview(device)
        }
    }
}
#endif

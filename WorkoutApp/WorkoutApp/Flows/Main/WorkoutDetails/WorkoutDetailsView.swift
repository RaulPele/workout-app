//
//  WorkoutDetailsView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 04.05.2023.
//

import SwiftUI


struct WorkoutDetails {
    
    struct ContentView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        private let detailsColumns = [GridItem(.flexible()), GridItem(.flexible())]
        
        var body: some View {
            VStack {
                NavigationBar(
                    title: viewModel.workout.title ?? "No title",
                    backButtonAction: {
                        viewModel.onBack?()
                    }
                )
                
                ScrollView {
                    
                    VStack(spacing: 20) {
                        workoutDetailsView
                        exercisesView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal)
            }
            .background(Color.background)
        }
        
        private var titleView: some View {
            Text(viewModel.workout.title ?? "No title")
                .foregroundColor(Color.onBackground)
                .font(.heading1)
        }
        
        private var workoutDetailsView: some View {
            VStack(alignment: .leading) {
                
                Text("Workout details")
                    .foregroundColor(.onBackground)
                    .font(.heading2)
                
                ListView(items: viewModel.workoutDetailsData, backgroundColor: .surface2) { rowData in
                    rowView(for: rowData)
                }
                
            }
            
        }
        
        private var exercisesView: some View {
            VStack(alignment: .leading) {
                Text("Performed exercises")
                    .foregroundColor(.onBackground)
                    .font(.heading2)
                
                ListView(items: viewModel.workout.performedExercises, backgroundColor: .surface2) { performedExercise in
                    ExerciseListItemView(for: performedExercise)
                }
                
            }
        }
        
        private var divider: some View {
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 1)
        }
        
        private func rowView(for rowData: WorkoutDetails.RowData) -> some View {
            HStack {
                cellView(for: rowData.first)
                    .frame(maxWidth: .infinity, alignment: .leading)
                cellView(for: rowData.second)
                    .frame(maxWidth: .infinity, alignment: .leading)

            }
        }
        
        private func cellView(for characteristic: WorkoutCharacteristic) -> some View {
            
            VStack(alignment: .leading) {
                Text(characteristic.key.title)
                Text(characteristic.displayValue)
            }
            .foregroundColor(foregroundColor(for: characteristic))
        }
        
        private func foregroundColor(for characteristic: WorkoutCharacteristic) -> Color {
            switch characteristic.key {
            case .totalCalories, .activeCalories:
                return .primaryColor
            case .duration:
                return .green
            
            case .avgHeartRate:
                return .red
                
            default:
                return .white
            }
        }
        
        struct ExerciseListItemView: View {
            
            @State private var performedExercise: PerformedExercise
            @State private var isExpanded = false
            init(for exercise: PerformedExercise) {
                self._performedExercise = State(initialValue: exercise)
            }
            
            var body: some View {
                VStack(alignment: .leading, spacing: 5) {
                    exercisePreview
                    
                    if isExpanded {
                        Group {
                            Text("Sets: \(performedExercise.sets.count ) / \(performedExercise.exercise.numberOfSets) ")
                            Text("Reps target: \(performedExercise.exercise.setData.reps)")
                            Text("Set rest time: \(performedExercise.exercise.restBetweenSets.formatted())")
                            VStack(spacing: 15) {
                                ForEach(performedExercise.sets) { performedSet in
                                    setView(for: performedSet)
                                }
                            }
                            .padding(.vertical, 10)
                            
                        }.padding(.leading, 12)
                    }
                }
                .foregroundColor(.primaryColor)
            }
            
            private var exercisePreview: some View {
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text(performedExercise.exercise.name)
//                        Text("\(performedExercise.sets.count) x \(performedExercise.sets[0].reps) x \(performedExercise.sets[0].weight.formatted(.number)) kg")
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .padding(.vertical, 10)
                }
            }
            
            @ViewBuilder
            private func setView(for performedSet: PerformedSet) -> some View {
                VStack {
                    let index = performedExercise.sets.firstIndex { $0.id == performedSet.id} ?? -1
                    VStack(alignment: .leading) {
                        Text("Set \(index + 1)")
                        VStack(alignment: .leading) {
                            Text("Reps: \(performedSet.reps) x \(performedSet.weight.formatted(.number)) kg")
                            if index != performedExercise.sets.count - 1 {
                                Text("Rest: \(performedSet.restTime.formatted())")
                            }
                        }
                    }
                        
                    
                        
                }
            }
        }
    }
    
    
}

#if DEBUG
struct WorkoutDetailsView_Previews: PreviewProvider {
    
    private static let viewModel = WorkoutDetails.ViewModel(workout: .mocked2)
    
    static var previews: some View {
        
        ForEach(previewDevices) { device in
            WorkoutDetails.ContentView(viewModel: viewModel)
                .preview(device)
        }
    }
}
#endif

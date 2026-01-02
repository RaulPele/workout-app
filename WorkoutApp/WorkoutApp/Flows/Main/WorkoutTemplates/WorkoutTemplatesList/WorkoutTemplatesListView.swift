//
//  WorkoutTemplatesListView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 29.05.2023.
//

import SwiftUI

struct WorkoutTemplatesList {
    
    struct ContentView: View {
        
        var viewModel: ViewModel
        
        var body: some View {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: .default) {
                    if viewModel.workoutTemplates.isEmpty && !viewModel.isLoading {
                        EmptyStateView(onCreateTemplate: {
                            viewModel.handleAddButtonTapped()
                        })
                    } else if !viewModel.workoutTemplates.isEmpty {
                        ForEach(viewModel.workoutTemplates) { template in
                            TemplateCardButton(
                                template: template,
                                onTap: {
                                    viewModel.handleTemplateTapped(template)
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                    }
                }
                .padding(.horizontal, .default)
                .padding(.vertical, .small)
            }
            .background(Color.background)
            .navigationTitle("My Workouts")
            .navigationSubtitle(templateCountSubtitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") {
                        viewModel.handleAddButtonTapped()
                    }
                }
            }
            .refreshable {
                await viewModel.refreshTemplates()
            }
            .overlay {
                if viewModel.isLoading && viewModel.workoutTemplates.isEmpty {
                    LoadingOverlayView()
                }
            }
            .onAppear {
                viewModel.handleOnAppear()
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.workoutTemplates)
        }
        
        private var templateCountSubtitle: String {
            let count = viewModel.workoutTemplates.count
            return "\(count) workout\(count == 1 ? "" : "s")"
        }
    }
}

// MARK: - Template Card Button

private struct TemplateCardButton: View {
    let template: WorkoutTemplate
    let onTap: () -> Void
    @State private var tapCount = 0
    
    var body: some View {
        Button(action: {
            tapCount += 1
            onTap()
        }) {
            WorkoutTemplateCardView(workoutTemplate: template)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: tapCount)
    }
}

// MARK: - Empty State View

private struct EmptyStateView: View {
    let onCreateTemplate: () -> Void
    
    var body: some View {
        VStack(spacing: .large) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 64))
                .foregroundStyle(.secondary.opacity(0.6))
            
            VStack(spacing: .small) {
                Text("No Workout Templates")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.onBackground)
                
                Text("Create your first workout template to get started")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .extraLarge)
            }
            
            Button("Create Template", systemImage: "plus.circle.fill") {
                onCreateTemplate()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .extraLarge)
    }
}

// MARK: - Loading Overlay View

private struct LoadingOverlayView: View {
    var body: some View {
        ZStack {
            Color.background.opacity(0.8)
            ProgressView()
                .scaleEffect(1.2)
        }
    }
}

// MARK: - Padding Extensions

private extension CGFloat {
    static let small: CGFloat = 8
    static let `default`: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 80
}

#Preview {
    NavigationStack {
        WorkoutTemplatesList.ContentView(viewModel: .init(workoutTemplateService: MockedWorkoutTemplateService()))
    }
}


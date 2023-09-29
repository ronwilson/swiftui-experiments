//
//  NewRoundView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/25/23.
//

import SwiftUI

enum ScoringMode {
    case individual
    case group
}

enum ScoringSystem {
    case stroke
    case stableford
    case par
}

struct NewRoundView: View {
    @State private var scoremode = ScoringMode.individual
    @State private var scoresystem = ScoringSystem.stroke
//    @ObservedObject var courseModel : CourseModel
    @EnvironmentObject var model : ContentViewModel


    var body: some View {
        Self._printChanges()
        return VStack {
            HStack {
                Text("Scoring Mode:")
                Picker("Scoring Mode", selection: $scoremode) {
                    Text("Individual").tag(ScoringMode.individual)
                    Text("Group").tag(ScoringMode.group)
                }
                .pickerStyle(.segmented)
                .onChange(of: scoremode) { value in
                    if value == .individual {
                        print("Individual Score Mode")
                    } else {
                        print("Group Score Mode")
                    }
                }
            }
            HStack {
                Text("Scoring System:")
                Picker("Scoring System", selection: $scoresystem) {
                    Text("Stroke").tag(ScoringSystem.stroke)
                    Text("Stableford").tag(ScoringSystem.stableford)
                    Text("Par").tag(ScoringSystem.par)
                }
                .onChange(of: scoresystem) { value in
                    switch value {
                    case .stroke:
                        print("Stroke System")
                    case .stableford:
                        print("Stableford System")
                    case .par:
                        print("Par System")
                    }
                }
            }
            .disabled(scoremode == .individual)

            if case let .loaded(courses) = model.courses.state {
                List(courses) { course in
                    NavigationLink(value: course) {
                        VStack(alignment: .leading){
                            Text("\(course.name)")
                            //Text("\(course.id)")
                        }
                    }
                }
                .listStyle(.plain)
                .navigationDestination(for: Course.self) { course in
                    // Navigate to the Tee Selection View
                    ChooseTeeView()
                }
            } else {
                ProgressView("Loading Courses")
            }
        }
        .padding()
        .navigationTitle("New Round")
        .navigationBarTitleDisplayMode(.inline)
    }
}

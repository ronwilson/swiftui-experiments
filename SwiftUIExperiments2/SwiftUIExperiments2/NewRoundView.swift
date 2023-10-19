//
//  NewRoundView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/25/23.
//

import SwiftUI

struct NewRoundView: View {
//    @ObservedObject var courseModel : CourseModel
    @EnvironmentObject var model : CoursesViewModel

    var body: some View {
        Self._printChanges()
        return VStack {
            Section(header: Text("Choose Course:")) {
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
                        ChooseTeeView(course: course)
                    }
                } else {
                    ProgressView("Loading Courses")
                }
            }
        }
        .padding()
        .navigationTitle("New Round")
        .navigationBarTitleDisplayMode(.inline)
    }
}

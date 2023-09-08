//
//  CourseDetailView.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import SwiftUI

struct CourseDetailView: View {
    let course: Course
    @State var courseName: String = ""
    @State var revision: Int = 0

    init(course: Course) {
        self.course = course
        _courseName = State(initialValue: course.name)
    }

    var body: some View {
        Self._printChanges()
        _ = revision
        return VStack {
            HStack {
                Text("Course Id:")
                Text("\(course.id)")
            }
            Section(header: Text("Course Data")) {
                HStack {
                    Text("Course Name:")
                    TextField("Course name:", text: $courseName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            print("Course name is now \(courseName)")
                            course.name = courseName
                        }
                }
            }
            Section(header: Text("Tees")) {
                List(course.tees) { tee in
                    NavigationLink(value: tee) {
                        Text("\(tee.color)")
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive, action: { course.deleteTee(color: tee.color) } ) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .listStyle(.plain)
                .navigationDestination(for: Tee.self) { tee in
                    TeeView(course: course, tee: tee)
                }
            }
        }
        .padding()
        .navigationTitle("Course")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(course.$tees) { _ in
            revision += 1
        }
        .toolbar {
            Button(action: {
                course.addTee()
            }) {
                Image(systemName: "plus")
                Text("Tee")
            }
        }
    }

}

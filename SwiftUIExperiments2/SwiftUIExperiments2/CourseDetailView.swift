//
//  CourseDetailView.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import SwiftUI

struct CourseDetailView: View {
    let courseModel: CourseModel
    @ObservedObject var course: Course

    var body: some View {
        Self._printChanges()
        return VStack {
            HStack {
                Text("Course Id:")
                Text("\(course.id)")
            }
            Section(header: Text("Course Data")) {
                HStack {
                    Text("Course Name:")
                    TextField("Course name:", text: $course.name)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            print("Course name is now \(course.name)")
                            // This will trigger an update of the CourseModel to refresh the course names in the CourseView.
                            courseModel.refresh()
                        }
                }
            }
            Section(header: Text("Tees")) {
                List(course.tees) { tee in
                    NavigationLink(value: tee) {
                        Text("\(tee.color)")
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive, action: { course.deleteTee(teeid: tee.id) } ) {
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

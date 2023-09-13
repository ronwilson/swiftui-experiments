//
//  CourseDetailView.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import SwiftUI

struct CourseDetailView: View {
    // courseModel does not need to be an @ObservedObject because there's nothing on
    // this view that depends on changes in the courseModel. The only reason to have
    // courseModel here is so that when a course name is changed, we can trigger an
    // update in the CourseView.
    let courseModel: CourseModel
    // course needs to be observed so that changes in the list of Tees for the course
    // will cause automatic updates for the List(course.tees) below.
    @ObservedObject var course: Course

    var body: some View {
        Self._printChanges()
        return VStack {
            // This can be commented out. There's no functional reason to display the id value
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
                // TODO: Add the remaining Course attributes here so they can be edited
            }
            Section(header: Text("Tees")) {
                // The list of Tees for the Course. This list and the delete swipe action work the
                // same as in the CourseView.
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
                    // Navigate to the TeeView
                    TeeView(course: course, tee: tee)
                }
            }
        }
        .padding()
        .navigationTitle("Course")
        .navigationBarTitleDisplayMode(.inline)
        // Put a "Add Tee" button on the toolbar
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

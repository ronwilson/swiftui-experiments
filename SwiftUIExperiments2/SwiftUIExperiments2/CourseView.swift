//
//  CourseView.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import SwiftUI

struct CourseView: View {
    @ObservedObject var courseModel : CourseModel

    var body: some View {
        Self._printChanges()
        return List(courseModel.courses) { course in
            NavigationLink(value: course) {
                VStack(alignment: .leading){
                    Text("\(course.name)")
                    Text("\(course.id)")
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive, action: { courseModel.deleteCourse(course) } ) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Courses")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Course.self) { course in
            CourseDetailView(courseModel: courseModel, course: course)
        }
        .toolbar {
            Button(action: {
                courseModel.addCourse(Course(name: "Course", holes:18))
            }) {
                Image(systemName: "plus")
            }
        }
    }
}

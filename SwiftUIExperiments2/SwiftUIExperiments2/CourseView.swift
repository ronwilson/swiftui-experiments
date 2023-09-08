//
//  CourseView.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import SwiftUI

struct CourseView: View {
//   @ObservedObject var viewModel: CourseViewModel
//    @Binding var courses: [Course]
    let courseModel : CourseModel
    @State var revision: Int = 0

    var body: some View {
        Self._printChanges()
        _ = revision
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
            .onReceive(course.$name) { _ in
                revision += 1
            }
        }
        .listStyle(.plain)
        .navigationTitle("Courses")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Course.self) { course in
            CourseDetailView(course: course)
        }
        .onReceive(courseModel.$courses) { _ in
            revision += 1
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

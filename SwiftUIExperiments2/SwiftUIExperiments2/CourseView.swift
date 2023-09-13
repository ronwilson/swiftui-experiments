//
//  CourseView.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import SwiftUI

// This view shows a list of Courses.
// Courses can be
//  - Added         There is a + button at the top of the View.
//  - Deleted       Swipe the table line containing the Course to the left, then tap the trash symbol.
//  - Modified      Tap the course (this navigates to the CourseDetailView)
struct CourseView: View {
    // Observe the courseModel so that changes in the courses array are automatically seen
    @ObservedObject var courseModel : CourseModel
    // To see how the @ObservedObject property wrapper in the line above affects how this
    // view works, comment out the line above and then uncomment the line below.
    // (so that the CourseModel is a plain var). Then run
    // the app again and try to add some courses. In the debug console, you should see
    // "Adding course Course" every time the Add course button is tapped. But there will be
    // no Courses added to this View. If you then navigate back one level to the top and
    // re-select Courses to navigate back here, then any Courses that were added will show
    // up.
//    var courseModel : CourseModel

    var body: some View {
        Self._printChanges()
        return List(courseModel.courses) { course in
            NavigationLink(value: course) {
                VStack(alignment: .leading){
                    Text("\(course.name)")
                    Text("\(course.id)")
                }
            }
            // Note the allowsFullSwipe: false. This forces the user to tap the trash symbol.
            // Kind of like saying "are you sure". Allowing full swipe deletes might be
            // a little dangerous unless Undo/Redo management is added.
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
            // Navigate to the CourseDetailView for the tapped Course
            CourseDetailView(courseModel: courseModel, course: course)
        }
        // Put a "Add Course" button on the toolbar
        .toolbar {
            Button(action: {
                // pass the add course action on to the top level model.
                // When the addCourse function adds a Course to the courses
                // array, the List View above will be automatically updated
                // because 1) the courseModel variable has the @ObservedObject property wrapper
                // and 2) the List(courseModel.courses) View automatically sets up the
                // Publish-Subscribe conection so that the List view will be invalidated
                // and re-drawn when the courses array is changed.
                courseModel.addCourse(Course(name: "Course", holes:18))
            }) {
                Image(systemName: "plus")
            }
        }
    }
}

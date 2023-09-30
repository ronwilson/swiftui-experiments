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
    @ObservedObject var model: ContentViewModel

    // InnerView is needed because we want to observe changes to the courses object (a LoadableObject).
    // The courses start loading when the main ContentView first appears. See ContentView, .onAppear().
    // This view (CourseView) can be selected by the user before the courses are finished loading.
    // In this view, we return a VStack that may contain one of three views:
    //  1. A spinner with the label "Loading Courses"
    //  2. An error string when the courses can't be loaded
    //  3. The List of courses.
    // We want what's displayed to change automatically when the state of the courses LoadableObject
    // changes. To do that, we need to observe the LoadableObject because observing changes of children
    // variables more than one level deep in objects does not work. Observation only extends to
    // the Published variables of the object that is observed. For example, here we have a ContentViewModel
    // at the top level, containing a published LoadableCourses object, containing a LoadingValueState.
    //      ContentViewModel            @ObservedObject
    //          LoadableCourses         @Published
    //              LoadingValueState   @Published
    // Without the InnerView, we would have to write the below switch statement as switch model.courses.state,
    // but 'state' is two levels deep in reference objects and therefore changes in 'state' will not cause
    // the CourseView to be updated.
    // We need 'courses' to be an @ObservedObject, so the solution is to create the InnerView
    // and pass the courses to it in the initializer. Then the switch statement can be written with one level
    // of child property observation as shown.

    private struct InnerView: View {

        @ObservedObject var model: ContentViewModel
        @ObservedObject var courses: LoadableCourses

        var body: some View {
            Self._printChanges()
            return VStack {
                switch courses.state {
                case .idle:
                    ProgressView("Courses Idle")
                case .loading:
                    ProgressView("Loading Courses")
                case let .failed(err, courseA):
                    ListView(err:err, model:model, courses:courseA)
                case let .loaded(courseA):
                    ListView(err:nil, model:model, courses:courseA)
                }
                //Text("\(courses.state.stateValue)")
            }
            .padding()
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
                    model.addCourse(Course(name: "Course", holes:18))
                }) {
                    Image(systemName: "plus")
                }
                .disabled(!(2...3).contains(courses.state.stateValue))
            }
        }
    }

    private struct ListView: View {
        var err: Error?
        var model: ContentViewModel
        var courses: [Course]
        @State var revision: Int = 0
        var body: some View {
            Self._printChanges()
            _ = revision
            return VStack {
                if let e = err {
                    Text("\(e.localizedDescription)")
                }
                List(courses) { course in
                    NavigationLink(value: course) {
                        VStack(alignment: .leading){
                            Text("\(course.name)")
                            //Text("\(course.id)")
                        }
                    }
                    .onReceive(course.$name) { _ in
                        print("CourseView ListView course name changed received")
                        revision += 1
                    }
                    // Note the allowsFullSwipe: false. This forces the user to tap the trash symbol.
                    // Kind of like saying "are you sure". Allowing full swipe deletes might be
                    // a little dangerous unless Undo/Redo management is added.
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive, action: { model.deleteCourse(course) } ) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .listStyle(.plain)
                .onAppear() {
                    if courses.count > 0 {
                        // always save the model when exiting this view if the
                        // courses array is not empty
                        model.changesPending = true
                    }
                }
            }
        }
    }

    var body: some View {
        Self._printChanges()
        return InnerView(model:model, courses:model.courses)
        .navigationTitle("Courses")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Course.self) { course in
            // Navigate to the CourseDetailView for the tapped Course
            CourseDetailView(model: model, course: course)
        }
    }
}

//
//  ContentViewModel.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/27/23.
//

import SwiftUI


class LoadableCourses: LoadableObject {
    @Published var state: LoadingValueState<[Course]> = LoadingValueState<[Course]>.idle
    typealias Output = [Course]
//    @Published var courses: [Course] = [Course]()
    func load() {
        PersistenceManager.shared.loadCourses(self)
    }
//    func hasCourses() -> Bool {
//        var has = false
//        switch self.state {
//        case .idle, .loading, .failed(_,_):
//            has = false
//        case .loaded(let coursesA):
//            has = coursesA.count > 0
//        }
//        return has
//    }
    func loaded(value: [Course]?, error: Error?) {
        Task {
            await loadingComplete(value, error:error)
        }
    }
    @MainActor func loadingComplete(_ courses: [Course]?, error: Error?) {
        if let coursesA = courses {
            print("Courses loaded, count = \(coursesA.count)")
            self.state = .loaded(coursesA)
        } else if let err = error {
            print("Course loading failed: \(err.localizedDescription)")
            self.state = .failed(err, [Course]())
        } else {
            fatalError("Courses Loading error: courses array is nil and error is nil")
        }
    }
}

final class CoursesViewModel: ObservableObject {

    @Published var courses: LoadableCourses = LoadableCourses()
    var changesPending: Bool = false

    func addCourse(_ course: Course) {
        switch courses.state {
        case .idle, .loading:
            print("addCourse called when state is \(courses.state)")
        case .failed(_,var courseA):
            print("Adding course \(course.name)")
            courseA.append(course)
            courses.state = .loaded(courseA)
        case .loaded(var courseA):
            print("Adding course \(course.name)")
            courseA.append(course)
            courses.state = .loaded(courseA)
        }
        // always save the model
        changesPending = true
    }

    func deleteCourse(_ course: Course) {
        if case var .loaded(courseA) = courses.state {
            print("Deleting course name \(course.name) (id \(course.id))")
            courseA.removeAll(where: { $0.id == course.id })
            courses.state = .loaded(courseA)
        } else {
            print("deleteCourse called when state is \(courses.state)")
        }
        // always save the model
        changesPending = true
    }

    func course(withId id: UUID) -> Course? {
        if case let .loaded(courseA) = courses.state {
            return courseA.first(where: { $0.id == id })
        }
        return nil

    }

    func tee(withColor color: String, for courseId: UUID) -> Tee? {
        if case let .loaded(courseA) = courses.state {
            if let c = courseA.first(where: { $0.id == courseId }) {
                return c.tee(withColor: color)
            }
        }
        return nil
    }
}

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
    @Published var courses: [Course] = [Course]()
    func load() {
        PersistenceManager.shared.loadCourses(self)
    }
}

final class ContentViewModel: ObservableObject {

    @Published var courses: LoadableCourses = LoadableCourses()

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
//            refresh()
        }
    }

    func deleteCourse(_ course: Course) {
        if case var .loaded(courseA) = courses.state {
            print("Deleting course name \(course.name) (id \(course.id))")
            courseA.removeAll(where: { $0.id == course.id })
//            courses.state = .loaded(courseA)
        } else {
            print("deleteCourse called when state is \(courses.state)")
        }
    }

    func refresh() {
        objectWillChange.send()
    }

    func courseUpdated() {
        courses.objectWillChange.send()
    }
}

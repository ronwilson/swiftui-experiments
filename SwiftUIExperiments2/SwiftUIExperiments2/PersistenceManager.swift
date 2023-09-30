//
//  PersistenceManager.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/25/23.
//

//import Foundation
import SwiftUI

enum CourseError: Error {
    // Throw when the main Courses file is not found
    case coursesNotFound

    // Throw when an expected resource is not found
    case notFound

    // Throw when a resource can't be decoded
    case decoding

    // Throw in all other cases
    case unexpected(code: Int)
}

class PersistenceManager {

    //
    static let shared = PersistenceManager()

    var loadedCourses: LoadableCourses?
    //var model: ContentViewModel?
    var coursesDirectoryPath: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let coursesDirectory: String = "courses"
    var coursesFileName: String = "courses.json"
    var appSupportFolder: String = "SwiftUIExperiments"
    var saveStatus: Binding<PersistenceStatus>? = nil
    var simulatePersistenceDelays = false

    func courses(from data: Data) throws -> [Course] {
        let decoder = JSONDecoder()
        return try decoder.decode([Course].self, from: data)
    }

    func courseData(from courseA: [Course]) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(courseA)
    }

    func loadCoursesFile(from url: URL) async -> Result<[Course], Error> {
        do {
            // simulate extended async delay
            if simulatePersistenceDelays {
                try await Task.sleep(nanoseconds: UInt64(5 * Double(NSEC_PER_SEC)))
            }

            // if this fails, there is no courses file
            let data = try Data(contentsOf: url)
            do {
                let courses = try self.courses(from: data)
                return .success(courses)
            } catch {
                return .failure(CourseError.decoding)
            }
        } catch {
            return .failure(CourseError.coursesNotFound)
        }
    }

    func loadCourses(_ courses: LoadableCourses) {
        loadedCourses = courses
        loadedCourses?.state = .loading

        let coursesUrl = coursesDirectoryPath.appending(components: appSupportFolder, coursesDirectory, coursesFileName)
        Task.detached(priority: .background) {
            let result = await self.loadCoursesFile(from: coursesUrl)

            switch result {
            case .success(let courses):
                await self.loadingSuccess(courses)
            case .failure(let err):
                await self.loadingError(err)
            }
        }
    }

    @MainActor func loadingSuccess(_ courses: [Course]) {
        print("PersistenceManager loaded \(courses.count) Courses")
        guard let model = self.loadedCourses else {
            fatalError("PersistenceManager loadingSuccess called when model is nil")
        }
        model.state = .loaded(courses)
    }

    @MainActor func loadingError(_ err: Error) {
        print("PersistenceManager loading error \(err)")
        guard let model = self.loadedCourses else {
            fatalError("PersistenceManager loadingError called when model is nil")
        }
        model.state = .failed(err, [Course]())
    }

    func saveCoursesFile(courses: [Course]) async -> Error? {
        do {
            let coursesDirectoryUrl = coursesDirectoryPath.appending(components: appSupportFolder, coursesDirectory)
            let coursesFileUrl = coursesDirectoryUrl.appendingPathComponent(coursesFileName)
            try FileManager.default.createDirectory(at: coursesDirectoryUrl, withIntermediateDirectories: true)

            let data = try courseData(from: courses)
            try data.write(to: coursesFileUrl, options: .atomic)

            // simulate extended async delay
            if simulatePersistenceDelays {
                try await Task.sleep(nanoseconds: UInt64(5 * Double(NSEC_PER_SEC)))
            }

            return nil
        } catch {
            return error
        }
    }

    func saveCourses(_ courses: LoadableCourses, status: Binding<PersistenceStatus>) {
        loadedCourses = courses
        saveStatus = status
        saveStatus?.wrappedValue = .savingCourses

        if case let .loaded(courseA) = courses.state {
            if !courseA.isEmpty {
                Task.detached(priority: .background) {
                    await self.coursesSaved(await self.saveCoursesFile(courses: courseA))
                }
            }
        } else {
        }
    }

    @MainActor func coursesSaved(_ err: Error?) {
        if let e = err {
            print("PersistenceManager saved courses, error \(e)")
        } else {
            print("PersistenceManager saved courses")
        }
        saveStatus?.wrappedValue = .idle
        saveStatus = nil
    }

}

extension CourseError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .coursesNotFound:
            return "The Courses file was not found"
        case .notFound:
            return "Resource not found"
        case .decoding:
            return "Data decoding failed"
        case .unexpected(let code):
            return "Unexpected error occurred, code \(code)"
        }
    }
}

extension CourseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .coursesNotFound:
            return NSLocalizedString(
                "The course list is empty. Tap '+' to create a new course.",
                comment: "Main Courses file was not found"
            )
        case .notFound:
            return NSLocalizedString(
                "Expected resource not found.",
                comment: "Expected resource not found"
            )
        case .decoding:
            return NSLocalizedString(
                "Data decoding error.",
                comment: "Data decoding error"
            )
        case .unexpected(let code):
            return NSLocalizedString(
                "An unexpected error occurred, code \(code).",
                comment: "Unexpected Error"
            )
        }
    }
}

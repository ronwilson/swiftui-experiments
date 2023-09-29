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
    var coursesFileName: String = "courses"
    var appSupportFolder: String = "SwiftUIExperiments"

    func writeCoursesFile(to url: URL, data: Data) async {
        do {
            try data.write(to: url)
        } catch {
            print("Error: saving courses file failed with '\(error)'")
        }
    }

    func saveCoursesFile(loadedCourses: LoadableCourses) {
        if case let .loaded(courses) = loadedCourses.state {
            let encoder = JSONEncoder()
            //        encoder.outputFormatting = .prettyPrinted
            let data = try! encoder.encode(courses)
            let coursesurl = coursesDirectoryPath.appending(path: appSupportFolder).appending(path: coursesFileName)
            Task {
                await writeCoursesFile(to: coursesurl, data: data)
            }
        }
    }

    func courses(from data: Data) throws -> [Course] {
        let decoder = JSONDecoder()
        return try decoder.decode([Course].self, from: data)
    }

//    func readCoursesFile(from url: URL) async throws -> Data {
//        try await Task.sleep(nanoseconds: UInt64(5 * Double(NSEC_PER_SEC)))
////        do {
//            let data = try Data(contentsOf: url)
//            return data
////        } catch {
////            return nil
////        }
//    }

    func loadCoursesFile(from url: URL) async -> Result<[Course], Error> {
        do {
            // simulate extended async delay
            try await Task.sleep(nanoseconds: UInt64(5 * Double(NSEC_PER_SEC)))
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

//    func loadCoursesFile() -> CourseModel {
//        Task {
//            let coursesurl = coursesDirectoryPath.appending(path: appSupportFolder).appending(path: coursesFileName)
//            do {
//                let coursedata = try await readCoursesFile(from: coursesurl)
//                loadedCourses = courses(from: coursedata)
//            } catch {
//                print("Error: reading course data from courses file failed with '\(error)'")
//                loadedCourses = CourseModel()
//            }
//        }
//        return self.loadedCourses
//    }

    /*
     struct Loader {
     var model: CourseModel

     func load() {
     Task.detached(priority: .background) {
     try await Task.sleep(nanoseconds: UInt64(5 * Double(NSEC_PER_SEC)))
     await loaded(2)
     }
     }

     @MainActor func loaded(_ value: Int) {
     model.state = .loaded(value)
     model.state2 = .loaded
     model.value = value
     print("Loaded \(value)")
     }
     }

     */

    func loadCourses(_ courses: LoadableCourses) {
        loadedCourses = courses
        loadedCourses?.state = .loading
//        self.model = model
//        self.model!.courses.state = .loading

        let localData = true    // $$$ make this a setting to allow for remote downloads
        var coursesUrl: URL?
        if localData {
            coursesUrl = coursesDirectoryPath.appending(path: appSupportFolder).appending(path: coursesFileName)
        }
        if let url = coursesUrl {
            Task.detached(priority: .background) {
                let result = await self.loadCoursesFile(from: url)

                switch result {
                case .success(let courses):
                    await self.loadingSuccess(courses)
                case .failure(let err):
                    await self.loadingError(err)
                }
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

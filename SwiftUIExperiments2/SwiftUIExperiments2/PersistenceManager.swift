//
//  PersistenceManager.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/25/23.
//

//import Foundation
import SwiftUI

enum PersistenceError: Error {
    // Throw when the main Courses file is not found
    case coursesNotFound

    // Throw when the main Rounds file is not found
    case roundsNotFound

    // Throw when an expected resource is not found
    case notFound

    // Throw when a resource can't be decoded
    case decoding

    // Throw when a resource can't be decoded
    case encoding

    // Throw in all other cases
    case unexpected(code: Int)
}

class PersistenceManager {

    // singleton
    static let shared = PersistenceManager()

    var loadedCourses: LoadableCourses?
    var loadedRounds: LoadableRounds?
    var appSupportDirectoryPath: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    var appSupportFolder: String = "SwiftUIExperiments"
    let coursesDirectory: String = "courses"
    var coursesFileName: String = "courses.json"
    let roundsDirectory: String = "rounds"
    var roundsFileName: String = "rounds.json"
    var saveCoursesStatus: Binding<PersistenceStatus>? = nil
    var saveRoundsStatus: Binding<PersistenceStatus>? = nil

    // MARK: -
    // MARK: Courses

    private func courses(from data: Data) throws -> [Course] {
        let decoder = JSONDecoder()
        return try decoder.decode([Course].self, from: data)
    }

    private func courseData(from courseA: [Course]) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(courseA)
    }

    func loadCoursesFile(from url: URL) async -> Result<[Course], Error> {
        do {
#if SIMULATED_RESOURCE_ISSUES
            // simulate extended async delay
            if UserDefaults.simulateCoursesLoadingDelay {
                try await Task.sleep(nanoseconds: UInt64(5 * Double(NSEC_PER_SEC)))
            }
#endif
            // if this fails, there is no courses file
            let data = try Data(contentsOf: url)
            do {
                let courses = try self.courses(from: data)
#if SIMULATED_RESOURCE_ISSUES
                // simulate data error
                if UserDefaults.simulateCoursesLoadingError {
                    return .failure(PersistenceError.decoding)
                }
#endif
                return .success(courses)
            } catch {
                return .failure(PersistenceError.decoding)
            }
        } catch {
            return .failure(PersistenceError.coursesNotFound)
        }
    }

    func loadCourses(_ courses: LoadableCourses) {
        loadedCourses = courses
        loadedCourses?.state = .loading

        let coursesUrl = appSupportDirectoryPath.appending(components: appSupportFolder, coursesDirectory, coursesFileName)
//        print("\(coursesUrl)")
        Task.detached(priority: .background) {
            let result = await self.loadCoursesFile(from: coursesUrl)

            switch result {
            case .success(let courses):
                self.loadedCourses?.loaded(value:courses, error: nil)
            case .failure(let err):
                self.loadedCourses?.loaded(value: nil, error: err)
            }
        }
    }

    func saveCoursesFile(courses: [Course]) async -> Error? {
        do {
            let coursesDirectoryUrl = appSupportDirectoryPath.appending(components: appSupportFolder, coursesDirectory)
            let coursesFileUrl = coursesDirectoryUrl.appendingPathComponent(coursesFileName)
            try FileManager.default.createDirectory(at: coursesDirectoryUrl, withIntermediateDirectories: true)

            let data = try courseData(from: courses)
            try data.write(to: coursesFileUrl, options: .atomic)

#if SIMULATED_RESOURCE_ISSUES
            // simulate extended async delay
            if UserDefaults.simulateCoursesSavingDelay {
                try await Task.sleep(nanoseconds: UInt64(5 * Double(NSEC_PER_SEC)))
            }
            if UserDefaults.simulateCoursesSavingError {
                return PersistenceError.decoding
            }
#endif
            return nil
        } catch {
            return error
        }
    }

    func saveCourses(_ courses: LoadableCourses, status: Binding<PersistenceStatus>) {
        loadedCourses = courses
        saveCoursesStatus = status
        saveCoursesStatus?.wrappedValue = .savingCourses

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
        saveCoursesStatus?.wrappedValue = .idle
        saveCoursesStatus = nil
    }

    // MARK: -
    // MARK: Rounds

    private func rounds(from data: Data) throws -> [Round] {
        let decoder = JSONDecoder()
        return try decoder.decode([Round].self, from: data)
    }

    private func roundsdata(from roundmetaA: [Round]) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(roundmetaA)
    }

    func loadRoundsFile(from url: URL) async -> Result<[Round], Error> {
        do {
#if SIMULATED_RESOURCE_ISSUES
            // simulate extended async delay
            if UserDefaults.simulateRoundsLoadingDelay {
                try await Task.sleep(nanoseconds: UInt64(4 * Double(NSEC_PER_SEC)))
            }
#endif
            // if this fails, there is no courses file
            let data = try Data(contentsOf: url)
            do {
                let rounds = try self.rounds(from: data)
#if SIMULATED_RESOURCE_ISSUES
                // simulate data error
                if UserDefaults.simulateRoundsLoadingError {
                    return .failure(PersistenceError.decoding)
                }
#endif
                return .success(rounds)
            } catch {
                return .failure(PersistenceError.decoding)
            }
        } catch {
            return .failure(PersistenceError.roundsNotFound)
        }
    }

    func loadRounds(_ rounds: LoadableRounds) {
        loadedRounds = rounds
        loadedRounds?.state = .loading

        let roundsUrl = appSupportDirectoryPath.appending(components: appSupportFolder, roundsDirectory, roundsFileName)
        Task.detached(priority: .background) {
            let result = await self.loadRoundsFile(from: roundsUrl)

            switch result {
            case .success(let roundsA):
                self.loadedRounds?.loaded(value: roundsA, error: nil)
                //await self.roundsLoadingSuccess(roundsA)
            case .failure(let err):
                self.loadedRounds?.loaded(value: nil, error: err)
                //await self.roundsLoadingErr(err)
            }
        }
    }

//    @MainActor func roundsLoadingSuccess(_ rounds: [Round]) {
//        print("PersistenceManager loaded \(rounds.count) Rounds")
//        guard let model = self.loadedRounds else {
//            fatalError("PersistenceManager roundsLoadingSuccess called when rounds model is nil")
//        }
//        model.state = .loaded(rounds)
//    }
//
//    @MainActor func roundsLoadingErr(_ err: Error) {
//        print("PersistenceManager roundsLoadingErr \(err)")
//        guard let model = self.loadedRounds else {
//            fatalError("PersistenceManager roundsLoadingErr called when model is nil")
//        }
//        model.state = .failed(err, [Round]())
//    }





    func saveRoundsFile(rounds: [Round]) async -> Error? {
        do {
            let roundsDirectoryUrl = appSupportDirectoryPath.appending(components: appSupportFolder, roundsDirectory)
            let roundsFileUrl = roundsDirectoryUrl.appendingPathComponent(roundsFileName)
            try FileManager.default.createDirectory(at: roundsDirectoryUrl, withIntermediateDirectories: true)

            let data = try roundsdata(from: rounds)
            try data.write(to: roundsFileUrl, options: .atomic)

#if SIMULATED_RESOURCE_ISSUES
            // simulate extended async delay
            if UserDefaults.simulateRoundsSavingDelay {
                try await Task.sleep(nanoseconds: UInt64(5 * Double(NSEC_PER_SEC)))
            }
            if UserDefaults.simulateRoundsSavingError {
                return PersistenceError.encoding
            }
#endif
            return nil
        } catch {
            return error
        }
    }

    func saveRounds(_ rounds: LoadableRounds, status: Binding<PersistenceStatus>) {
        loadedRounds = rounds
        saveRoundsStatus = status
        saveRoundsStatus?.wrappedValue = .savingRounds

        if case let .loaded(roundsA) = rounds.state {
            if !roundsA.isEmpty {
                Task.detached(priority: .background) {
                    await self.roundsSaved(await self.saveRoundsFile(rounds: roundsA))
                }
            }
        } else {
        }
    }

    @MainActor func roundsSaved(_ err: Error?) {
        if let e = err {
            print("PersistenceManager saved rounds, error \(e)")
        } else {
            print("PersistenceManager saved rounds")
        }
        saveRoundsStatus?.wrappedValue = .idle
        saveRoundsStatus = nil
    }

}

extension PersistenceError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .coursesNotFound:
            return "The courses resource file was not found"
        case .roundsNotFound:
            return "The rounds file was not found"
        case .notFound:
            return "Resource not found"
        case .decoding:
            return "Data decoding failed"
        case .encoding:
            return "Data encoding failed"
        case .unexpected(let code):
            return "Unexpected error occurred, code \(code)"
        }
    }
}

extension PersistenceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .coursesNotFound:
            return NSLocalizedString(
                "The course list is empty. ",
                comment: "Main Courses file was not found"
            )
        case .roundsNotFound:
            return NSLocalizedString(
                "The rounds list is empty.  ",
                comment: "Main Rounds file was not found"
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
        case .encoding:
            return NSLocalizedString(
                "Data encoding error.",
                comment: "Data encoding error"
            )
        case .unexpected(let code):
            return NSLocalizedString(
                "An unexpected error occurred, code \(code).",
                comment: "Unexpected Error"
            )
        }
    }
}

//extension PersistenceManager {
//    static let rounds: [Round] = [
//        Round(id: UUID(), date: "5/18/23", courseName: "Aviara", teeColor: "Blue", status: .submitted),
//        Round(id: UUID(), courseName: "Encinitas Ranch", teeColor: "Blue", date: "5/24/23", status: .submitted),
//        Round(id: UUID(), courseName: "Aviara", teeColor: "White", date: "7/4/23", status: .complete),
//        Round(id: UUID(), courseName: "Pebble Beach", teeColor: "Black", date: "8/1/23", status: .submitted),
//        Round(id: UUID(), courseName: "Encinitas Ranch", teeColor: "Blue", date: "9/18/23", status: .incomplete),
//    ]
//
//}

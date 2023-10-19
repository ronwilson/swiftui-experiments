//
//  UserDefaults.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/8/23.
//

import Foundation

extension UserDefaults {

    private struct Keys {
        static let myName = "myName"
        static let myHandicapIndex = "myHandicapIndex"
        static let scorecardFontSize = "scorecardFontSize"
#if SIMULATED_RESOURCE_ISSUES
        static let simulateCoursesSavingDelay = "simulateCoursesSavingDelay"
        static let simulateCoursesLoadingDelay = "simulateCoursesLoadingDelay"
        static let simulateRoundsSavingDelay = "simulateRoundsSavingDelay"
        static let simulateRoundsLoadingDelay = "simulateRoundsLoadingDelay"
        static let simulateCoursesSavingError = "simulateCoursesSavingError"
        static let simulateCoursesLoadingError = "simulateCoursesLoadingError"
        static let simulateRoundsSavingError = "simulateRoundsSavingError"
        static let simulateRoundsLoadingError = "simulateRoundsLoadingError"
#endif
    }

    // My Info
    static var myName: String {
        get {
            if let name = UserDefaults.standard.string(forKey: Keys.myName) {
                return name
            }
            return "MyName"
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.myName) }
    }

    static var myHcpIndex: Double {
        get {
            if let hcpi = UserDefaults.standard.value(forKey: Keys.myHandicapIndex) {
                return hcpi as! Double
            }
            return 13.0
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.myHandicapIndex) }
    }

    // Scorecard Font Size
    static var scorecardFontSize: Int {
        get {
            let value = UserDefaults.standard.integer(forKey: Keys.scorecardFontSize)
            // For string values:
            // if let value = UserDefaults.standard.object(forKey: Keys.key) as? String
            if value > 0 {
                return value
            }
            return 14
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.scorecardFontSize) }
    }

#if SIMULATED_RESOURCE_ISSUES
    // Simulate Course File I/O Issues
    static var simulateCoursesSavingDelay: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.simulateCoursesSavingDelay)
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.simulateCoursesSavingDelay) }
    }
    static var simulateCoursesLoadingDelay: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.simulateCoursesLoadingDelay)
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.simulateCoursesLoadingDelay) }
    }
    static var simulateCoursesSavingError: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.simulateCoursesSavingError)
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.simulateCoursesSavingError) }
    }
    static var simulateCoursesLoadingError: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.simulateCoursesLoadingError)
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.simulateCoursesLoadingError) }
    }
    // Simulate Rounds Metadata File I/O Issues
    static var simulateRoundsSavingDelay: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.simulateRoundsSavingDelay)
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.simulateRoundsSavingDelay) }
    }
    static var simulateRoundsLoadingDelay: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.simulateRoundsLoadingDelay)
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.simulateRoundsLoadingDelay) }
    }
    static var simulateRoundsSavingError: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.simulateRoundsSavingError)
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.simulateRoundsSavingError) }
    }
    static var simulateRoundsLoadingError: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.simulateRoundsLoadingError)
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.simulateRoundsLoadingError) }
    }
#endif
}

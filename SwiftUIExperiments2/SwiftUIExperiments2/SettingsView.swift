//
//  SettingsView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/4/23.
//

import SwiftUI

struct SettingsView: View {

    static let fontSizes = [12, 14, 16, 18, 20, 22, 24, 28, 32]

    @ObservedObject var settingsStore: SettingsStore = SettingsStore()
    @FocusState var focus:FocusedField?

    var body: some View {
        Self._printChanges()
        return VStack {
            VStack {

                TextField("My Name", text: $settingsStore.myName, onCommit: {
                    focusNext()
                })
                .textFieldStyle(.roundedBorder)
                .focused($focus, equals: .name)

                TextField("My Hcp Index", value: $settingsStore.myHcpIndex, formatter: Self.hcpFormatter, onCommit: {
                    focusNext()
                })
                .textFieldStyle(.roundedBorder)
                .focused($focus, equals: .hcpindex)

                HStack {
                    Text("Scorecard Font Size: ")
                    Picker("Font Size for Scorecard View", selection: $settingsStore.scorecardFontSize) {
                        ForEach(SettingsView.fontSizes, id: \.self) {
                            Text("\($0)")
                        }
                    }
                }
#if SIMULATED_RESOURCE_ISSUES
                Section("Simulated File I/O Delays") {
                    Toggle("Course File Saving", isOn: $settingsStore.simulateCoursesSavingDelay)
                    Toggle("Course File Loading", isOn: $settingsStore.simulateCoursesLoadingDelay)
                    Toggle("Rounds File Saving", isOn: $settingsStore.simulateRoundsSavingDelay)
                    Toggle("Rounds File Loading", isOn: $settingsStore.simulateRoundsLoadingDelay)
                }
                Section("Simulated File I/O Errors") {
                    Toggle("Course File Saving", isOn: $settingsStore.simulateCoursesSavingError)
                    Toggle("Course File Loading", isOn: $settingsStore.simulateCoursesLoadingError)
                    Toggle("Rounds File Saving", isOn: $settingsStore.simulateRoundsSavingError)
                    Toggle("Rounds File Loading", isOn: $settingsStore.simulateRoundsLoadingError)
                }
#endif
            }
        }
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    static let hcpFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    enum FocusedField: Hashable{
        case name, hcpindex
    }

    func focusNext() {
        if case .name = focus {
            focus = .hcpindex
        } else if case .hcpindex = focus {
            focus = .name
        }
    }
}

final class SettingsStore: ObservableObject {

    // My Name
    @Published var myName: String = UserDefaults.myName {
        willSet {
            UserDefaults.myName = newValue
        }
    }

    // My Hcp Index
    @Published var myHcpIndex: Double = UserDefaults.myHcpIndex {
        willSet {
            UserDefaults.myHcpIndex = newValue
        }
    }

    // Scorecard Font Size
    @Published var scorecardFontSize: Int = UserDefaults.scorecardFontSize {
        willSet {
            UserDefaults.scorecardFontSize = newValue
        }
    }
#if SIMULATED_RESOURCE_ISSUES
    @Published var simulateCoursesSavingDelay: Bool = UserDefaults.simulateCoursesSavingDelay {
        willSet {
            UserDefaults.simulateCoursesSavingDelay = newValue
        }
    }
    @Published var simulateCoursesLoadingDelay: Bool = UserDefaults.simulateCoursesLoadingDelay {
        willSet {
            UserDefaults.simulateCoursesLoadingDelay = newValue
        }
    }
    @Published var simulateRoundsSavingDelay: Bool = UserDefaults.simulateRoundsSavingDelay {
        willSet {
            UserDefaults.simulateRoundsSavingDelay = newValue
        }
    }
    @Published var simulateRoundsLoadingDelay: Bool = UserDefaults.simulateRoundsLoadingDelay {
        willSet {
            UserDefaults.simulateRoundsLoadingDelay = newValue
        }
    }
    @Published var simulateCoursesSavingError: Bool = UserDefaults.simulateCoursesSavingError {
        willSet {
            UserDefaults.simulateCoursesSavingError = newValue
        }
    }
    @Published var simulateCoursesLoadingError: Bool = UserDefaults.simulateCoursesLoadingError {
        willSet {
            UserDefaults.simulateCoursesLoadingError = newValue
        }
    }
    @Published var simulateRoundsSavingError: Bool = UserDefaults.simulateRoundsSavingError {
        willSet {
            UserDefaults.simulateRoundsSavingError = newValue
        }
    }
    @Published var simulateRoundsLoadingError: Bool = UserDefaults.simulateRoundsLoadingError {
        willSet {
            UserDefaults.simulateRoundsLoadingError = newValue
        }
    }
#endif
}


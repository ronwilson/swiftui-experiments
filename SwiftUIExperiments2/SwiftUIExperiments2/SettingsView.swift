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

    var body: some View {
        Self._printChanges()
        return VStack {
            VStack {
                HStack {
                    Text("Scorecard Font Size: ")
                    Picker("Font Size for Scorecard View", selection: $settingsStore.scorecardFontSize) {
                        ForEach(SettingsView.fontSizes, id: \.self) {
                            Text("\($0)")
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

final class SettingsStore: ObservableObject {

    // Scorecard Font Size
    @Published var scorecardFontSize: Int = UserDefaults.scorecardFontSize {
        willSet {
            UserDefaults.scorecardFontSize = newValue
        }
    }
}

extension UserDefaults {

    private struct Keys {
        static let scorecardFontSize = "scorecardFontSize"
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
}

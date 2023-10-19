//
//  ChooseTeeView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/25/23.
//

import SwiftUI

struct ChooseTeeView: View {

    var course: Course

    @EnvironmentObject var nav: NavigationStateManager
    @EnvironmentObject var roundsModel: RoundsViewModel

    var body: some View {
        Self._printChanges()
        return VStack {
            Section(header: Text("\(course.name)")) {
                List(course.tees) { tee in
                    NavigationLink(value: tee) {
                        Text("\(tee.color)")
                    }
                }
                .listStyle(.plain)
                .navigationDestination(for: Tee.self) { tee in
                    // Navigate to setting the players for the round
                    ScoreModeView(course: course, tee: tee)
                }
            }
        }
        .onAppear() {
//            print("\(nav.path)")
            print("roundsModel changesPending: \(roundsModel.changesPending)")
        }
        .navigationTitle("Choose Tee")
        .navigationBarTitleDisplayMode(.inline)
    }
}


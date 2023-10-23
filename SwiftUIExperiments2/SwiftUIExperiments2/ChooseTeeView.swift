//
//  ChooseTeeView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/25/23.
//

import SwiftUI

struct ChooseTeeView: View {

    var course: Course
//    @ObservedObject var round: Round
//    var round: Round

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
//                    ScoreModeView(course: course, tee: tee, round: round(for: tee))
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

//    func round(for tee: Tee) -> Round {
//        round.teeId = tee.id
//        round.players[0].name = UserDefaults.myName
//        round.players[0].hcpIndex = UserDefaults.myHcpIndex
//        round.players[0].courseHcp = tee.playerCourseHandicap(hcpIndex: round.players[0].hcpIndex)
//        return round
//    }
}


//
//  ScorecardView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/23/23.
//

import SwiftUI

enum RoundStatus: String {
    case new = "New"
    case incomplete = "Incomplete"
    case complete = "Complete"
    case submitted = "Submitted"
}

struct Round : Identifiable, Hashable {
    let id: UUID
    let course: String
    let tee: String
    let date: String
    let status: RoundStatus
}



// This view shows a list of Rounds.
// Rounds can be
//  - Added         There is a + button at the top of the View.
//  - Deleted       Swipe the table line containing the Course to the left, then tap the trash symbol.
//  - Modified      Tap the course (this navigates to the CourseDetailView)
struct RoundsView: View {
    @EnvironmentObject var coursesModel : CoursesViewModel
    let tee: Tee
    @State private var addstate: String? = nil
    @State var playerscore: PlayerScore = PlayerScore(id: UUID(), name:"Ron", hcp: 10)

    let rounds: [Round] = [
        Round(id: UUID(), course: "Aviara", tee: "Blue", date: "5/18/23", status: .submitted),
        Round(id: UUID(), course: "Encinitas Ranch", tee: "Blue", date: "5/24/23", status: .submitted),
        Round(id: UUID(), course: "Aviara", tee: "White", date: "7/4/23", status: .complete),
        Round(id: UUID(), course: "Pebble Beach", tee: "Black", date: "8/1/23", status: .submitted),
        Round(id: UUID(), course: "Encinitas Ranch", tee: "Blue", date: "9/18/23", status: .incomplete),
    ]

    var body: some View {
        Self._printChanges()
        return List(rounds) { round in
            NavigationLink(value: round) {
                HStack {
                    VStack(alignment: .leading){
                        Text("\(round.course)")
                        HStack {
                            Text("\(round.tee)")
                            Text("\(round.date)")
                        }
                    }
                    Spacer()
                    Text("\(round.status.rawValue)")
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Rounds")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Round.self) { round in
            switch round.status {
            case .new:
                NewRoundView()
            case .incomplete:
                ScoreView(playerscore: playerscore, tee: tee)
            case .complete:
                // $$$ Go to Review Score View
                ScoreView(playerscore: playerscore, tee: tee)
            case .submitted:
                // $$$ Go to Analyze Score View
                ScoreView(playerscore: playerscore, tee: tee, startHole: Int.random(in: 1...6))
            }
        }
        .toolbar {
            NavigationLink(value: newRound()) {
                Image(systemName: "plus")
            }
            .disabled(coursesModel.courses.courses.isEmpty)
        }
    }

    private func newRound() -> Round {
        return Round(id: UUID(), course: "", tee: "", date: "", status: .new)
    }
}

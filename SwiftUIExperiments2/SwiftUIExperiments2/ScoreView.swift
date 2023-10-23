//
//  ScoreView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/23/23.
//

import SwiftUI

struct ScoreView: View {

    var course: Course
    var tee: Tee
    @ObservedObject var round: Round

//    @State var rvm: RoundViewModel
    let startHole: Int
    let holeCount: Int
    let lastHoleIndex: Int
    @State private var holeindex: Int
    @State private var date: Date

    @EnvironmentObject var nav: NavigationStateManager
    @EnvironmentObject var roundsModel: RoundsViewModel

    init(course: Course, tee: Tee, round: Round) {
//        _rvm = State(initialValue: round)
        self.course = course
        self.tee = tee
        self.round = round

        self.startHole = round.startHole
        assert(startHole <= tee.teeboxes.count)
        self.holeCount = tee.teeboxes.count
        self.lastHoleIndex = (startHole - 2 + holeCount) % holeCount
        _holeindex = State(initialValue: round.lastHoleIndexEdited)
        let dateFormatStyle = Date.FormatStyle(date: .abbreviated, time: .omitted)
        if let rounddate = try? dateFormatStyle.parse(round.date) {
            _date = State(initialValue: rounddate)
        } else {
            _date = State(initialValue: Date())
        }
    }

    var body: some View {
        Self._printChanges()
        return VStack {
            VStack {
                Text("\(course.name)")
                HStack {
                    Text("\(tee.color) Tee")
                    Spacer()
                    DatePicker("", selection: $date, in: ...Date.now, displayedComponents: .date)
                        .onChange(of: date) { val in
                            round.date = date.formatted(date: .abbreviated, time: .omitted)
                        }
                }
            }
            HoleScoreView(score: round.players[0].holescores[holeindex], holeindex: holeindex, lastHoleIndex: lastHoleIndex, tee: tee)
            HStack {
                VStack {
                    Text("Hole")
                    Text("\(holeindex == 0 ? holeCount : holeindex)")
                }
                .opacity(holeindex == startHole - 1 ? 0.0 : 1.0)

                Button(action: {
                    print("Prev")
                    holeindex = (holeindex - 1 + holeCount) % holeCount
                    round.lastHoleIndexEdited = holeindex
//                    holescore = playerscore.holescores[holeindex]
                }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }
                .disabled(holeindex == startHole - 1)

                Button(action: {
                    print("Next")
                    holeindex = (holeindex + 1 + holeCount) % holeCount
                    round.lastHoleIndexEdited = holeindex
//                    holescore = playerscore.holescores[holeindex]
                }) {
                    Image(systemName: "arrow.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }
                .padding(.leading,
                         10)
                .disabled(holeindex == lastHoleIndex)

                VStack {
                    Text("Hole")
                    Text("\(holeindex == holeCount - 2 ? holeCount : (holeindex+2) % holeCount)")
                }
                .opacity(holeindex == lastHoleIndex ? 0.0 : 1.0)
            }
        }
        .padding()
        .navigationTitle("Scoring")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
//        .onAppear() {
//            print("\(nav.path)")
//        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    nav.removeAllButOne()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Rounds")
                    }
                }
            }
        }
    }
}


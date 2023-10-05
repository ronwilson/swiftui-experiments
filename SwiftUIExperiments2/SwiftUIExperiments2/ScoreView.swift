//
//  ScoreView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/23/23.
//

import SwiftUI

struct ScoreView: View {

    @State var playerscore: PlayerScore
    let tee: Tee
    let startHole: Int
    let holeCount: Int

    @State var holeindex: Int
    let lastHoleIndex: Int
    @ObservedObject var holescore: HoleScore
    @State private var date = "9/18/23"

    init(playerscore: PlayerScore, tee: Tee, startHole: Int = 1) {
        _playerscore = State(initialValue: playerscore)
        self.tee = tee
        assert(startHole <= tee.teeboxes.count)
        self.startHole = startHole
        self.holeCount = tee.teeboxes.count
        self.lastHoleIndex = (startHole - 2 + holeCount) % holeCount
        self.holescore = playerscore.holescores[startHole - 1]
        _holeindex = State(initialValue: startHole - 1)
    }

    var body: some View {
        Self._printChanges()
        return VStack {
            VStack {
                Text("Aviara Golf Club")
                HStack {
                    Text("Blue Tee")
                    Spacer()
                    Button(action: {
                        print("Select Date")
                    }) {
                        Text(self.date)
                    }
                }
            }
            HoleScoreView(score: playerscore.holescores[holeindex], holeindex: holeindex, lastHoleIndex: lastHoleIndex, tee: tee)
            HStack {
                VStack {
                    Text("Hole")
                    Text("\(holeindex == 0 ? holeCount : holeindex)")
                }
                .opacity(holeindex == startHole - 1 ? 0.0 : 1.0)

                Button(action: {
                    print("Prev")
                    holeindex = (holeindex - 1 + holeCount) % holeCount
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
    }


}


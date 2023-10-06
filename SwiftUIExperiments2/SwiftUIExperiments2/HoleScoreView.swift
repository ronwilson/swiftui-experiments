//
//  HoleScoreView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/3/23.
//

import SwiftUI

struct HoleScoreView: View {
    @ObservedObject var score: HoleScore
    let holeindex: Int
    let lastHoleIndex: Int
    let tee: Tee

    enum Menu: String {
        case scorecard
        case group
        case finish
    }

    var body: some View {
        Self._printChanges()
        return VStack {
            HStack(alignment: .top) {
                VStack {
                    GroupBox {
                        VStack {
                            Text("\(holeindex+1)")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            HStack {
                                Text("Par")
                                Text("\(tee.teeboxes[holeindex].par)")
                            }
                            HStack {
                                Text("Hcp")
                                Text("\(tee.teeboxes[holeindex].hcp)")
                            }
                        }
                        .fixedSize()
                        .frame(width: 60)
                    }
                }
                VStack {
                    GroupBox {
                        Grid(alignment: .leading) {
                            GridRow {
                                Text("Shots: ")
                                Picker("Choose the number of stokes for this hole", selection: $score.strokes) {
                                    ForEach(1 ..< 20, id: \.self) {
                                        Text("\($0)")
                                    }
                                }
                            }
                            GridRow {
                                Text("Putts: ")
                                Picker("Choose the number of putts for this hole", selection: $score.putts) {
                                    ForEach(1 ..< 10, id: \.self) {
                                        Text("\($0)")
                                    }
                                }
                            }
                            GridRow {
                                Text("Penalties: ")
                                Picker("Select the penalty count", selection: $score.penalties) {
                                    ForEach(0 ..< 10) {
                                        Text("\($0)")
                                    }
                                }
                            }
                            GridRow {
                                Text("Good Shots: ")
                                Picker("Choose the number of good shots", selection: $score.goodshots) {
                                    ForEach(0 ..< 6) {
                                        Text("\($0)")
                                    }
                                }
                            }
                        }
                    }
                }
                VStack {
                    NavigationLink(value: Menu.scorecard) {
                        Image(systemName: "tablecells")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 20)
                    //.padding(.leading, 10)

                    NavigationLink(value: Menu.group) {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 10)
                    //.padding(.leading, 10)
                    
                    NavigationLink(value: Menu.finish) {
                        Image(systemName: "flag.checkered.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(holeindex == lastHoleIndex ? .primary : Color(.systemGray3))
                    }
                    .padding(.top, 20)
                    .disabled(holeindex != lastHoleIndex)
                }
                .padding(.leading, 10)
                .navigationDestination(for: Menu.self) { menu in
                    switch menu {
                    case .scorecard:
                        ScorecardView(tee: tee)
                    case .group:
                        GroupScoreView()
                    case .finish:
                        ReviewScoreView()
                    }
                }
            }
            //.background(.blue)
            HStack (alignment: .top) {
                LandingAreaView(drive:$score.drive, approach: $score.approach)
                    .onReceive(score.$approach) { a in
                        if a == .green || a == .other {
                            score.sand = false
                        }
                    }
                VStack {
                    Text ("  Approach:  ")
                    //.padding(.leading, 20)
                        .padding(.top, 20)
                    Text (score.approach.rawValue)
                    Text (score.sand ? "Sand" : " ")
                    SandTrapView(hitSandTrap:$score.sand)
                        .frame(width: 76, height: 50)
                        .disabled(score.isSandDisabled())
                    Spacer()
                    Text ("Drive:")
                        .padding(.horizontal, 20)
                    Text (score.drive.rawValue)
                        .padding(.bottom, 20)
                }
            }
            //.background(.orange)
        }
        //.background(.yellow)
    }
}

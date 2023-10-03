//
//  ScoreView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/23/23.
//

import SwiftUI

struct ScoreView: View {

    enum Menu: String {
        case scorecard
        case group
    }

    let tee: Tee
    //$$$ These should be bindings or an observed score model

    @State private var penalties = 0
    @State private var goodshots = 0
    @State private var strokes = 0
    @State private var putts = 0
    @State private var score = 0
    @State var drive: String = "N/A"
    @State var approach: String = "N/A"
    @State var sand: String = " "
    @State var hitsand: Bool = false
    @State private var date = "9/18/23"

//    let navigationItems = [
//        NavigationItem(title: "Scorecard", icon: "tablecells", item: .scorecard),
//        NavigationItem(title: "Group", icon: "person.3.fill", item: .groupsome),
//    ]

    //let columns = [GridItem(.flexible()), GridItem(.flexible())]

    func onTapArea(area: LandingArea) {
        print("Tapped \(area)")
        switch (area) {
        case .approachnone:
            self.approach = "N/A"
        case .drivenone:
            self.drive = "N/A"
        case .green:
            self.approach = "GIR"
        case .backleft:
            self.approach = "Back Left"
        case .back:
            self.approach = "Back"
        case .backright:
            self.approach = "Back Right"
        case .left:
            self.approach = "Left"
        case .right:
            self.approach = "Right"
        case .frontleft:
            self.approach = "Front Left"
        case .front:
            self.approach = "Front"
        case .frontright:
            self.approach = "Front Right"
        case .fairway:
            self.drive = "On Fairway"
        case .leftruff:
            self.drive = "Left Rough"
        case .rightruff:
            self.drive = "Right Rough"
        }
        //$$$ change the score model
    }

    func onTapSandTrap() {
        self.hitsand = !self.hitsand
        sand = self.hitsand ? "Sand" : " "
        print("Hit Sand: \(self.hitsand)")
        //$$$ change the score model
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
            HStack {
                HStack(alignment: .top) {
                    VStack {
                        //                    Text("Hole")
                        GroupBox {
                            VStack {
                                Text("18")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                HStack {
                                    Text("Par")
                                    Text("4")
                                }
                                HStack {
                                    Text("Hcp")
                                    Text("12")
                                }
                            }
                        }
                    }
                    VStack {
                        //Text("Summary")
                        GroupBox {
                            Grid(alignment: .leading) {
                                GridRow {
                                    Text("Shots: ")
                                    Picker("Choose the number of stokes for this hole", selection: $strokes) {
                                        ForEach(1 ..< 20) {
                                            Text("\($0)")
                                            //                                      Text("^[\($0) Stroke](inflect: true)")
                                        }
                                    }
                                }
                                GridRow {
                                    Text("Putts: ")
                                    Picker("Choose the number of putts for this hole", selection: $putts) {
                                        ForEach(1 ..< 10) {
                                            Text("\($0)")
                                            //                                      Text("^[\($0) Putt](inflect: true)")
                                        }
                                    }
                                }
                                GridRow {
                                    Text("Penalties: ")
                                    Picker("Select the penalty count", selection: $penalties) {
                                        ForEach(0 ..< 10) {
                                            Text("\($0)")
                                            //                                        Text("^[\($0) Stroke](inflect: true)")
                                        }
                                    }
                                }
                                GridRow {
                                    Text("Good Shots: ")
                                    Picker("Choose the number of good shots", selection: $goodshots) {
                                        ForEach(0 ..< 6) {
                                            Text("\($0)")
                                            //                                        Text("^[\($0) Shot](inflect: true)")
                                        }
                                    }
                                }
                                //                            GridRow {
                                //                                Text("Score: ")
                                //                                Text("\(self.score)")
                                //                            }
                            }
                        }
                    }
                }
                HStack {
                    VStack {
                        NavigationLink(value: ScoreView.Menu.scorecard) {
                            Image(systemName: "tablecells")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.primary)
                        }
                        .padding(.bottom, 20)

                        NavigationLink(value: ScoreView.Menu.group) {
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.primary)
                        }


//                        List(navigationItems) { item in
//                                NavigationLink(value: item) {
//                                    Image(item.icon)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 35, height: 35)
//                                        .foregroundColor(.primary)
//                                }
//                                //.disabled(item.item == NavItemId.courses && status == .savingCourses)
//                            }
//                            .listStyle(.plain)
//                            .navigationDestination(for: NavigationItem.self) { item in
//                                switch item.item.rawValue {
//                                case NavItemId.scorecard.rawValue:
//                                    ScorecardView()
//                                case NavItemId.groupsome.rawValue:
//                                    ScorecardView()
//                                default: EmptyView()
//                                }
//                            }

//                        Button(action: {
//                            print("Group Score")
//                        }) {
//                            Image(systemName: "person.3.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 35, height: 35)
//                        }
                    }
                    .navigationDestination(for: ScoreView.Menu.self) { menu in
                        switch menu {
                        case .scorecard:
                            ScorecardView(tee: tee)
                        case .group:
                            ScorecardView(tee: tee)
                        }
                    }
                }
            }
            HStack (alignment: .top) {
                LandingAreaView(landingAreaTapHandler: onTapArea)
                VStack {
                    Text ("Approach")
                        .padding(.leading, 20)
                        .padding(.top, 20)
                    Text (self.approach)
                    Text (self.sand)
                    SandTrapView(sandTrapTapHandler: onTapSandTrap)
                        .frame(width: 76, height: 50)
                    Spacer()
                    Text ("Drive")
                        .padding(.horizontal, 20)
                    Text (self.drive)
                        .padding(.bottom, 20)
                }
            }
            HStack {
                VStack {
                    Text("Hole")
                    Text("17")
                }

                Button(action: {
                    print("Prev")
                }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }

                Button(action: {
                    print("Next")
                }) {
                    Image(systemName: "arrow.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }
                .padding(.leading,
                         10)

                Text("Review &\nFinish")
            }
        }
        .padding()
        .navigationTitle("Scoring")
        .navigationBarTitleDisplayMode(.inline)
    }
}


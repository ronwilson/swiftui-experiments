//
//  ScoreModeView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/14/23.
//

import SwiftUI


/*  
ScoreView
    RoundViewModel                              struct
        Round                                   struct
            date
            courseId
            teeId
            players: [PlayerScore]
                PlayerScore                     struct
                    name
                    hcpIndex
                    courseHcp
                    holescores: [HoleScore]
                        HoleScore               object
            startHole
            holeCount
            RoundStatus
        Course                                  object
        Tee                                     struct



 */

struct ScoreModeView: View {

    var course: Course
    var tee: Tee
    @State private var playerCount = 1
    @State private var numPlayers = 1
    @State private var roundModel: RoundViewModel
    @State private var round: Round
    @State private var dummyText = ""
    @State private var date = Date()
    @State private var fieldsFilled = false

    @FocusState private var focused: FocusedField?
    @State private var lastFocused: FocusedField?

    @EnvironmentObject var nav: NavigationStateManager
    @EnvironmentObject var roundsModel: RoundsViewModel

    init(course: Course, tee: Tee) {
        self.course = course
        self.tee = tee
        let rnd = Round(id: UUID(), name: UserDefaults.myName, hcpIndex: UserDefaults.myHcpIndex, course: course, tee: tee)
        _round = State(initialValue: rnd)
        _roundModel = State(initialValue: RoundViewModel(id: UUID(), round: rnd, course: course, tee: tee))
    }

    var body: some View {
        Self._printChanges()
        return VStack {
            /*
             Date

             Start Hole
             Number of Holes

             Num Players
             1 2 3 4

             Player  Hcp Index   Course Hcp
             Jon     10.8        12
             ______                              + (add to friends)
             ______                              + (add to friends)
             ______                              + (add to friends)
             Match Scoring
             Match   picker stroke, stableford, par, etc

             Play ->
             */
            Text("\(course.name)")
            Text("\(tee.color) Tee")

            HStack {
                DatePicker("Round date", selection: $date, in: ...Date.now, displayedComponents: .date)
                    .padding()
                    .onChange(of: date) { val in
                        //print("Date selected: \(Self.dateFormatter.string(from: val))")
                        round.date = Self.dateFormatter.string(from: val)
                        round.objectWillChange.send()
                    }
            }

            HStack {
                Text("Start Hole: ")
                Picker("Choose the starting hole", selection: $round.startHole) {
                    ForEach(1 ... course.holes, id: \.self) {
                        Text("\($0)")
                    }
                }
            }

            HStack {
                Text("Holes to Play: ")
                Picker("Choose the number of holes to be played", selection: $round.holeCount) {
                    ForEach(1 ... course.holes, id: \.self) {
                        Text("\($0)")
                    }
                }
            }

            HStack {
                Text("Players:")
                Picker("Player Count", selection: $numPlayers) {
                    ForEach(1...4, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: numPlayers) { pcount in
                    round.adjustPlayers(count: numPlayers)
                    playerCount = numPlayers
                }
            }
            /*
                Excellent Post on TextField events and focus:
                https://fatbobman.medium.com/advanced-swiftui-textfield-events-focus-keyboard-c99bc9f57c91
             */
            Grid(alignment: .leading) {
                GridRow {
                    Text("Player").fontWeight(.semibold)
                    Text("Hcp Index").fontWeight(.semibold)
                    Text("Course Hcp").fontWeight(.semibold)
                }
                GridRow {
                    Text("\(round.players[0].name)")
                    Text(String(format: "%0.1lf", round.players[0].hcpIndex))
                    Text("\(round.players[0].courseHcp)")
                }
                if playerCount > 1 {
                    ForEach(2...playerCount, id: \.self) { n in
                        GridRow {
                            TextField("", text: $round.players[n-1].name)
                                .textFieldStyle(.roundedBorder)
                                .focused($focused, equals: .name(n), last:lastFocused) {isFocused in
                                    if !isFocused {
                                        // A name field just lost focus.
                                        // Do validity checks
                                        checkPlayerEntries()
                                    }
                                }
                                .onSubmit {
                                    //print("player \(n) name: \(round.round.players[n-1].name)")
                                    focusNext()
                                }

                            TextField("", value: $round.players[n-1].hcpIndex, format: .hcpindex())
                                .focused($focused, equals: .hcpindex(n), last:lastFocused) {isFocused in
                                    print("hcpIndex row \(n) focused: \(isFocused)")
                                    if !isFocused {
                                        // A hcp index field just lost focus.
                                        // Set the associated course handicap
                                        round.players[n-1].courseHcp = tee.playerCourseHandicap(hcpIndex: round.players[n-1].hcpIndex)
                                        // Do validity checks
                                        checkPlayerEntries()
                                    }
                                }
                                .onSubmit {
                                    //print("player \(n) hcpIndex: \(round.round.players[n-1].hcpIndex)")
                                    focusNext()
                                }
                            .textFieldStyle(.roundedBorder)
                            .focused($focused, equals: .hcpindex(n))

                            Text("\(round.players[n-1].courseHcp)")
                        }
                    }
                }
                if playerCount < 4 {
                    ForEach(1 ... (4 - playerCount), id: \.self) { n in
                        GridRow {
                            TextField("", text: $dummyText)
                                .textFieldStyle(.roundedBorder)
                            TextField("", text: $dummyText)
                                .textFieldStyle(.roundedBorder)
                            Text("")
                        }
                        .disabled(true)
                    }
                }
            }
            .padding()
            .storeLastFocus(current: $focused, last: $lastFocused) // save lastest focsed value

            HStack {
                Text("Scoring System:")
                Picker("Scoring System", selection: $round.scoringSystem) {
                    Text("Stroke").tag(ScoringSystem.stroke)
                    Text("Stableford").tag(ScoringSystem.stableford)
                    Text("Par").tag(ScoringSystem.par)
                }
                .onChange(of: round.scoringSystem) { value in
                    switch value {
                    case .stroke:
                        print("Stroke System")
                    case .stableford:
                        print("Stableford System")
                    case .par:
                        print("Par System")
                    }
                }
            }
            .disabled(playerCount == 1)

            NavigationLink(value: round) {
                Text("Play")
            }
            .padding()
            .disabled(!fieldsFilled)

            Spacer()
        }
        .padding()
        .navigationTitle("Round Setup")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
//            print("\(nav.path)")
            roundsModel.addRound(roundModel)
            checkPlayerEntries()
        }
        .onChange(of: playerCount) { value in
            checkPlayerEntries()
        }
        .navigationDestination(for: RoundViewModel.self) { round in
            ScoreView(round: round, playerCount: playerCount)
        }
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    enum FocusedField: Hashable{
        case name(Int), hcpindex(Int)
    }

    func focusNext() {
        if case let .name(val) = focused {
//            print("focusing player \(val) hcpindex")
            focused = .hcpindex(val)
        } else if case let .hcpindex(val) = focused {
            var nameRow = val + 1
            if nameRow > playerCount {
                nameRow = 2
            }
//            print("focusing player name \(val)")
            focused = .name(nameRow)
        }
    }

    func checkPlayerEntries() {
        var failures = 0
        for index in 0..<playerCount {
            let pscore = round.players[index]
            if pscore.name.isEmpty || pscore.hcpIndex.isNaN {
                failures += 1
            }
        }
        fieldsFilled = failures == 0
    }
}

public struct HcpIndexParseStrategy: ParseStrategy {
    public func parse(_ value: String) throws -> Double {
        if value.isEmpty {
            return .nan
        } else {
            return Double(value)!
        }
    }
}

struct HcpIndexNumberFormat: ParseableFormatStyle {
    typealias Strategy = HcpIndexParseStrategy
    var parseStrategy: HcpIndexParseStrategy

    func format(_ value: Double) -> String {
        if value.isNaN {
            return ""
        } else {
            return value.formatted(.number.precision(.fractionLength(0...1)))
        }
    }
}

extension FormatStyle where Self == HcpIndexNumberFormat {
    static func hcpindex() -> HcpIndexNumberFormat { .init(parseStrategy: HcpIndexParseStrategy()) }
}


public extension View {
    func storeLastFocus<Value: Hashable>(current: FocusState<Value?>.Binding, last: Binding<Value?>) -> some View {
        onChange(of: current.wrappedValue) { _ in
            if current.wrappedValue != last.wrappedValue {
                last.wrappedValue = current.wrappedValue
            }
        }
    }

    func focused<Value>(_ binding: FocusState<Value>.Binding, equals value: Value, last: Value?, onFocus: @escaping (Bool) -> Void) -> some View where Value: Hashable {
        return focused(binding, equals: value)
            .onChange(of: binding.wrappedValue) { focusValue in
                if focusValue == value {
                    onFocus(true)
                } else if last == value { // only call once
                    onFocus(false)
                }
            }
    }
}

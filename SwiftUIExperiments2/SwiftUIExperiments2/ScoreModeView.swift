//
//  ScoreModeView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/14/23.
//

import SwiftUI


/*  
ScoreView
    Round                                   object
        date
        courseId
        teeId
        players: [PlayerScore]
            PlayerScore                     object
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

struct ScoreModeViewNavItem: Identifiable, Hashable {
    var id = UUID()
}

struct ScoreModeView: View {

    var course: Course
    var tee: Tee
    /*
     Interesting post on @StateObject vs @ObservedObject
     https://www.hackingwithswift.com/quick-start/swiftui/whats-the-difference-between-observedobject-state-and-environmentobject
     Initially, I used @ObservedObject for var round.
     However, when the "Play" button is tapped (at least in the simulator),
     there is a crash in the view body on the line
     TextField("", text: $round.players[n-1].name)
     when additional players have been added to the round (e.g. 3).
     The crash is due to 'n' being out of range. This is after the call to roundsModel.addRound(round)
     and the newRound = addedRound.
     Note that the var round is never changed, but it seems that there is a side effect from adding the
     round to the roundsModel.
     I confirmed that the round has three players, the newRound has three players, but after adding
     round to the roundsModel, the code binds to round.players[n-1] crashes because n is out of range.
     Changing @ObservedObject var round to @StateObject var round fixes the problem.
     The only thing I can see being a possible explanation is that @ObservedObject is documented as
     being owned externally to the view, while @StateObject is documented as being the source of truth
     and owned by this view.
     */
    @StateObject var round: Round
    @State private var newRound: Round = Round()

    @State private var playerCount = 1
    @State private var numPlayers = 1
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
        _round = StateObject(wrappedValue: Round(name: UserDefaults.myName, hcpIndex: UserDefaults.myHcpIndex, course: course, tee: tee))
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
                        // date is stored in the round as a string so we need to monitor the DatePicker
                        // and convert to a string when the date is changed.
                        round.date = val.formatted(date: .abbreviated, time: .omitted)
                    }
            }

            HStack {
                Text("Start Hole: ")
                Picker("Choose the starting hole", selection: $round.startHole) {
                    ForEach(1 ... course.holes, id: \.self) {
                        Text("\($0)")
                    }
                }
                .onChange(of: round.startHole) { val in
                    round.lastHoleIndexEdited = val - 1
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
                    // The round has to be changed according to the player count.
                    // The players array must be increased or reduced and that contains objects,
                    // so it isn't easy to make this a simple binding.
                    round.adjustPlayers(count: numPlayers)
                    playerCount = numPlayers
                }
            }
            Grid(alignment: .leading) {
                GridRow {
                    Text("Player").fontWeight(.semibold)
                    Text("Hcp Index").fontWeight(.semibold)
                    Text("Course Hcp").fontWeight(.semibold)
                }
                // player 0 is always the app user
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
                                .focused($focused, equals: .name(n), last:lastFocused) { isFocused in
                                    // focus changes when the user taps in a new field or uses the tab key on macOS
                                    if !isFocused {
                                        // A name field just lost focus.
                                        // Do validity checks
                                        checkPlayerEntries()
                                    }
                                }
                                .onSubmit {
                                    // This is called when the user uses the return key on macOS or dismisses the keyboard on iOS
                                    //print("player \(n) name: \(round.round.players[n-1].name)")
                                    focusNext()
                                }

                            TextField("", value: $round.players[n-1].hcpIndex, format: .hcpindex())
                                .textFieldStyle(.roundedBorder)
                                .focused($focused, equals: .hcpindex(n), last:lastFocused) { isFocused in
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

                            Text("\(round.players[n-1].courseHcp)")
                        }
                    }
                }
                // Add dummy grid rows just to keep the UI the same
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

            /*
             This button acts like a NavigationLink. I first had a standard NavigationLink link here
             but it turns out it's not possible to publish state changes from within a NavigationLink.
             The design of this view is that it's working on an internal Round object up to the point
             where the user hits the 'play' button. At that point, we want to add the Round to the global
             rounds model (i.e. make the Round 'official') and then navigate to the Round editing view.
             Adding the temporary round to the roundsViewModel is a major state change and causes several
             published changes. SwiftUI detects those publishing changes and warns about them. I tried all
             kinds of ways to make the changes but it either didn't compile or caused infinite loops at
             runtime. Removing the NavigationLink, and doing the state changes before triggering the
             navigation avoids the issues. Instead of doing state changes inside the NavigationLink
             (which is a View builder), the changes are done first and then the navigation path is changed
             to trigger a transition to the Round editor view.

             Note: Another design would be to add the Round to the global roundsViewModel in a higher-level
             view so that this View is working with an ObservedObject that was already added to the
             roundsViewModel. However, there are other issues with that idea. What we want is a flow like
             this:
                    1. User Selects Add New Round
                    2. User Selects the Course (which is in another global model)
                    3. User Selects the Tee (which is in the selected course model)
                    4. User sets up the round parameters (other players, start hold, date, etc)
                    5. Go to the Scoring View (Round editor view)
             If we add the new round to the global model at the top, how do we handle aborting the process?
             What if the user never gets to step 4 or 5? What we want is for the user to get all the way through
             step 4 before we commit to adding the Round to the roundsViewModel. We only want to add fully configured
             Rounds to the master model (and thus to persistent storage). Even so, I tried to add the Round at step
             one and even that did not work because there's no opportunity to make the model changes outside
             of a View builder. SwiftUI complained about every attempt at programmatic model changes. Note that
             we don't have that problem with the Courses API because adding a course immediately affects the
             course list only, and the user must select the new course to edit it. I didn't want to do that with
             a Round because it seems like an extra unnecessary step and also because there would be a new,
             completely unconfigured Round sitting in the Rounds list and possible saved to file.
             */
            Button(action: {
                // Add the round to the global view model
                roundsModel.addRound(round)
//                print ("round player count: \(round.players.count)")
                // I'm not sure this is necessary, but this pulls the newly added round
                // out of the global roundsModel (making sure the round got added)
                // and presumably decouples newRound from the round owned by this View.
                if let addedRound = roundsModel.round(withId: round.id) {
//                    print ("Added and got model round")
                    newRound = addedRound
//                    print ("newRound player count: \(newRound.players.count)")

                    // This is how to manually modify the nav path and trigger a transition.
                    // This takes the place of a NavigationLink. Seems just as easy.
                    nav.path.append(ScoreModeViewNavItem())
                }
            }) {
                Text("Play")
            }
            .padding()
            // disable the play button unless the user has filled in the player data
            .disabled(!fieldsFilled)

            Spacer()
        }
        .padding()
        .navigationTitle("Round Setup")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            checkPlayerEntries()
        }
        .onChange(of: playerCount) { value in
            checkPlayerEntries()
        }
        .navigationDestination(for: ScoreModeViewNavItem.self) { item in
            ScoreView(course: course, tee: tee, round: newRound)
        }
    }

    // Note this enum has associated values for the cases.
    // This is so that the rows of TextFields for player data
    // can be identified
    enum FocusedField: Hashable{
        case name(Int), hcpindex(Int)
    }

    // moves the focus to the next TextField
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

    // checks that the player data has been filled in
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

/*
    Excellent Post on TextField events and focus:
    https://fatbobman.medium.com/advanced-swiftui-textfield-events-focus-keyboard-c99bc9f57c91

    I wanted to use the new TextField initializer that uses the new formatter scheme.
    The new TextField API removes the onEditingChanged and onCommit closures.
    I ended up implementing the workarounds that allow one to determine when the focus
    has changed and also for the return key handling.
 */

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

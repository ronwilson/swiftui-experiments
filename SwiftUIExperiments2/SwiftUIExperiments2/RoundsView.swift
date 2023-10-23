//
//  ScorecardView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/23/23.
//

import SwiftUI

// This view shows a list of Rounds.
// Rounds can be
//  - Added         There is a + button at the top of the View.
//  - Deleted       Swipe the table line containing the Course to the left, then tap the trash symbol.
//  - Modified      Tap the course (this navigates to the CourseDetailView)
struct RoundsView: View {
    // The view models are Observable objects and they handle the loading state of the courses
    // and rounds. They are put into the view environment by the top level ContentView.
    // Using the view environment is more convenient than injecting these through each subview's initializer.
    @EnvironmentObject var coursesModel : CoursesViewModel
    @EnvironmentObject var roundsModel: RoundsViewModel

    // For detecting changes to a round
    @State var roundData: Data?
    @State var editedRound: Round?

    // loading
    @State private var persistenceStatus = PersistenceStatus.idle

    // Uncomment here and below to see the navigation path state
//    @EnvironmentObject var nav: NavigationStateManager

    // The RoundsView contains an InnerView. The InnerView monitors the loading of Rounds from persistent storage.
    // The InnerView needs to observe the loading state of the Rounds, so it takes in the LoadableRounds
    // as an @ObservedObject.
    // While the Rounds are loading, the InnerView displays a ProgressView with a message about loading.
    // Once the Rounds are loaded, the InnerView displays a List of Rounds where each Round is displayed
    // by a RoundListItemView. The RoundListItemView is a separate subview so that each round can be
    // observed independently as an @ObservedObject.
    //
    // RoundsView body
    //      InnerView
    //          ListView
    //              RoundListItemView
    //          or Progress View

    // This View monitors the loading state of Rounds and either displays the rounds
    // in a ListView subview or puts up a progress view announcing the loading status of Rounds.
    private struct InnerView: View {
        // This view monitors the state of the rounds loading.
        // Note that when this view is instantiated, the Courses loading state will already be resolved.
        @ObservedObject var rounds: LoadableRounds

        // A function can be used to factor commonality from the view body property.
        // There are places where we want to wait for the courses to load in the body builder below so
        // I refactored the common code to this function.
// this is no longer needed. The ContentView disables the Rounds menu item when courses loading fails
// or there are no courses. I'm leaving this comment just to document how a function can be included as a @ViewBuilder.
// @ViewBuilder can also be used on structs that are not Views themselves.
//        @ViewBuilder private func waitForCoursesLoading(rounds: [Round], courses: LoadableCourses) -> some View {
//            switch courses.state {
//            case .idle:
//                ProgressView("Courses Idle")
//            case .loading:
//                ProgressView("Loading Courses")
//            case .failed(_,_):
//                //Text("\(err.localizedDescription), course count: \(courseA.count)")
//                fatalError("Loading Courses failed while trying to display the Rounds.")
//            case .loaded(_):
//                ListView(err:nil, rounds:rounds)
//            }
//        }

        var body: some View {
            Self._printChanges()
            return VStack {
                switch rounds.state {
                case .idle:
                    // This shouldn't be seen if the ContentView started the Rounds loading process
                    ProgressView("Rounds Idle")
                case .loading:
                    // Rounds are still loading from persistent storage.
                    ProgressView("Loading Rounds")
                case let .failed(err, roundsA):
                    // Rounds failed to load. We'll assume that's because there are no rounds yet.
                    //TODO: display the rounds loading error message?
                    ListView(err:err, rounds:roundsA)
                case let .loaded(roundsA):
                    // Rounds have loaded from persistent storage.
                    ListView(err:nil, rounds:roundsA)
                }
            }
            .padding()
            .toolbar {
                NavigationLink(value: newRound()) {
                    Image(systemName: "plus")
                }
            }
        }

        private func newRound() -> Round {
            let round = Round()
            return round
        }
    }

    // A line item in the Rounds list
    // The reason it's pulled out of the ListView as a separate view
    // is so that changes to a Round will cause just this view to be updated.
    // In ListView, the rounds are in an array and so won't be monitored for changes.
    // By making a view for each Round, the round can be an @ObservedObject and thus monitored for changes.
    // For example, if the round's date is changed in the ScoreView then this view will be
    // updated.
    private struct RoundListItemView: View {
        @ObservedObject var round: Round
        @EnvironmentObject var coursesModel : CoursesViewModel
        var body: some View {
            Self._printChanges()
            return VStack(alignment: .leading){
                Text("\(coursesModel.courseName(for: round.courseId))")
                HStack {
                    Text("\(coursesModel.teeColor(for: round.teeId, in: round.courseId)) Tee")
                    Text("\(round.date)")
                        .padding(.leading)
                    Spacer()
                    Text("\(round.status.rawValue)")
                }
            }
        }
    }

    // This is a subview of InnerView. It displays the list of Rounds. It is displayed only if the loading
    // of rounds from persistent storage has completed (whether successful or not, whether there are rounds or not).
    private struct ListView: View {
        var err: Error?
        var rounds: [Round]
        @State var revision: Int = 0
        @EnvironmentObject var roundsModel: RoundsViewModel

        var body: some View {
            Self._printChanges()
            _ = revision
            return VStack {
                // If there was any error loading the Rounds, assume it's because there are no
                // persisted rounds. Prompt the user to create a new round.
                if let e = err {
                    Text("\(e.localizedDescription) Tap '+' to start a new round.")
                }
                // The list of rounds
                List(rounds) { round in
                    NavigationLink(value: round) {
                        RoundListItemView(round: round)
                    }
                    // Note the allowsFullSwipe: false. This forces the user to tap the trash symbol.
                    // Kind of like saying "are you sure". Allowing full swipe deletes might be
                    // a little dangerous unless Undo/Redo management is added.
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive, action: { roundsModel.deleteRound(round.id) } ) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    var body: some View {
        Self._printChanges()
        return VStack {
            InnerView(rounds: roundsModel.rounds)
                .disabled(persistenceStatus == .savingRounds)
                .navigationTitle("Rounds")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Round.self) { round in
                    // Navigate to the CourseDetailView for the tapped Course
                    switch round.status {
                    case .new:
                        // The .new state will be set only for a round that has been newly added
                        // through the NavigationLink in the InnerView.
                        // Switch to the view that will prompt for the course.
                        NewRoundView()
                    case .incomplete:
                        if let course = coursesModel.course(withId :round.courseId) {
                            if let coursetee = course.tee(withId: round.teeId) {
                                ScoreView(course: course, tee:coursetee, round: copyRound(round))
                            }
                            //TODO: else error
                        }
                        // TODO: else error
                    case .complete:
                        // $$$ Go to Review Score View
                        if let course = coursesModel.course(withId :round.courseId) {
                            if let coursetee = course.tee(withId: round.teeId) {
                                ScoreView(course: course, tee:coursetee, round: copyRound(round))
                            }
                        }
                    case .submitted:
                        // $$$ Go to Analyze Score View
                        if let course = coursesModel.course(withId :round.courseId) {
                            if let coursetee = course.tee(withId: round.teeId) {
                                ScoreView(course: course, tee:coursetee, round: copyRound(round))
                            }
                        }
                    }
                }
                .onAppear() {
                    print("RoundsView appear")
                    // Uncomment to see the navigation path state
                    // print("\(nav.path)")

                    if let data = roundData, let changedround = editedRound {
                        if let originalround = round(from: data) {
                            if changedround != originalround {
                                roundsModel.changesPending = true
                            } else {
                                changedround.lastHoleIndexEdited = originalround.lastHoleIndexEdited
                            }
                        }
                    }
                    if roundsModel.changesPending {
                        print("Round was created or modified, need to save rounds data")
                        PersistenceManager.shared.saveRounds(roundsModel.rounds, status: $persistenceStatus)
                    }
                    roundData = nil
                    editedRound = nil
                    roundsModel.changesPending = false
                }
            if persistenceStatus == .savingRounds {
                ProgressView("Saving Rounds")
            }
        }
    }

    private func copyRound(_ round: Round) -> Round {
        roundData = roundData(round)
        editedRound = round
        return round
    }

    private func roundData(_ round: Round) -> Data? {
        do {
            let encoder = JSONEncoder()
            return try encoder.encode(round)
        } catch {
            return nil
        }
    }

    private func round(from data: Data) -> Round? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Round.self, from: data)
        } catch {
            return nil
        }
    }

}


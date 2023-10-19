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
    @EnvironmentObject var coursesModel : CoursesViewModel
//    let tee: Tee
//    @ObservedObject var rounds: RoundsViewModel
    @EnvironmentObject var roundsModel: RoundsViewModel

    @State private var addstate: String? = nil
    //@State var playerscore: PlayerScore = PlayerScore(id: UUID(), name:"Ron", hcp: 10)

    @EnvironmentObject var nav: NavigationStateManager

    private struct InnerView: View {

//        @EnvironmentObject var coursesModel : CoursesViewModel
//        @ObservedObject var coursesModel : CoursesViewModel
//        @ObservedObject var courses: LoadableCourses
        @EnvironmentObject var courses: LoadableCourses
//        @EnvironmentObject var roundsModel: RoundsViewModel
//        @ObservedObject var roundsModel: RoundsViewModel
//        @ObservedObject var rounds: LoadableRounds
        @EnvironmentObject var rounds: LoadableRounds

        var body: some View {
            Self._printChanges()
            return VStack {
                switch rounds.state {
                case .idle:
                    ProgressView("Rounds Idle")
                case .loading:
                    ProgressView("Loading Rounds")
                case let .failed(err, roundsA):
                    //Text("\(err.localizedDescription)")
                    ListView(err:err, rounds:roundsA)
                case let .loaded(roundsA):
                    switch courses.state {
                    case .idle:
                        ProgressView("Courses Idle")
                    case .loading:
                        ProgressView("Loading Courses")
                    case let .failed(err, courseA):
                        Text("\(err.localizedDescription), course count: \(courseA.count)")
                        fatalError("Loading Courses failed while trying to display the Rounds.")
                    case .loaded(_):
                        ListView(err:nil, rounds:roundsA)
                    }
                }
                //Text("\(roundsMeta.state.stateValue)")
            }
            .padding()
            .toolbar {
                NavigationLink(value: newRound()) {
                    Image(systemName: "plus")
                }
//                .disabled(!coursesModel.courses.hasCourses())
            }
            // Put a "New Round" button on the toolbar
            //            .toolbar {
            //                Button(action: {
            //                    // pass the add course action on to the top level model.
            //                    // When the addCourse function adds a Course to the courses
            //                    // array, the List View above will be automatically updated
            //                    // because 1) the courseModel variable has the @ObservedObject property wrapper
            //                    // and 2) the List(courseModel.courses) View automatically sets up the
            //                    // Publish-Subscribe conection so that the List view will be invalidated
            //                    // and re-drawn when the courses array is changed.
            //                    model.addCourse(Course(name: "Course", holes:18))
            //                }) {
            //                    Image(systemName: "plus")
            //                }
            //                .disabled(!(2...3).contains(courses.state.stateValue))
            //            }
        }
        private func newRound() -> Round {
            //return RoundMetadata(id: UUID(), course: "", tee: "", date: "", status: .new)
            return Round(id: UUID())
        }
    }

    private struct ListView: View {
        var err: Error?
//        var model: RoundsViewModel
        var rounds: [Round]
        @State var revision: Int = 0
        @EnvironmentObject var roundsModel: RoundsViewModel

        var body: some View {
            Self._printChanges()
            _ = revision
            return VStack {
                if let e = err {
                    Text("\(e.localizedDescription) Tap '+' to start a new round.")
                }
                List(rounds) { round in
                    NavigationLink(value: round) {
                        HStack {
                            VStack(alignment: .leading){
                                Text("\(round.courseId)")
                                HStack {
                                    Text("\(round.teeId)")
                                    Text("\(round.date)")
                                }
                            }
                            Spacer()
                            Text("\(round.status.rawValue)")
                        }
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
//        return InnerView(coursesModel:coursesModel, courses: coursesModel.courses, roundsModel: rounds, rounds: rounds.rounds)
        return InnerView()
        .navigationTitle("Rounds")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Round.self) { round in
            // Navigate to the CourseDetailView for the tapped Course
            switch round.status {
            case .new:
                NewRoundView()
            case .incomplete:
                if let course = coursesModel.course(withId :round.courseId) {
                    if let coursetee = course.tee(withId: round.teeId) {
                        ScoreView(round: RoundViewModel(id: UUID(), round: round, course: course, tee:coursetee), playerCount: round.players.count)
                    }
                }
            case .complete:
                // $$$ Go to Review Score View
                if let course = coursesModel.course(withId :round.courseId) {
                    if let coursetee = course.tee(withId: round.teeId) {
                        ScoreView(round: RoundViewModel(id: UUID(), round: round, course: course, tee: coursetee), playerCount: round.players.count)
                    }
                }
            case .submitted:
                // $$$ Go to Analyze Score View
                if let course = coursesModel.course(withId :round.courseId) {
                    if let coursetee = course.tee(withId: round.teeId) {
                        ScoreView(round: RoundViewModel(id: UUID(), round: round, course: course, tee: coursetee), playerCount: round.players.count)
                    }
                }
            }

        }
//        .onAppear() {
//            print("\(nav.path)")
//        }
        .environmentObject(coursesModel.courses)
        .environmentObject(roundsModel.rounds)
    }
}


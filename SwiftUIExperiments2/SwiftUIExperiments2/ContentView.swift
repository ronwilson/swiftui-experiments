//
//  ContentView.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import SwiftUI

struct NavigationItem: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var icon: String
    var menu: Menu
}

var navigationItems = [
    NavigationItem(title: "Courses", icon: "person.circle", menu: .courses),
    NavigationItem(title: "Rounds", icon: "tablecells", menu: .rounds),
    NavigationItem(title: "Analysis", icon: "chart.line.uptrend.xyaxis", menu: .analysis),
    NavigationItem(title: "Settings", icon: "gear", menu: .settings),
]

enum Menu: String {
    case courses
    case rounds
    case analysis
    case settings
}

enum PersistenceStatus {
    case idle
    case savingCourses
    case savingRounds
}

// I needed a formatter for integers in multiple Views.
// For some reason, using this exact code in multiple Views
// that are in the same NavigationStack causes some kind of
// cyclical referencing and the app goes into an infinite loop.
// Using a global variable is probably not the way to fix the problem,
// but it lets me get to where all the experimental views are working.
//let intFormatter: NumberFormatter = {
//    let formatter = NumberFormatter()
//    formatter.numberStyle = .decimal
//    formatter.maximumFractionDigits = 0
//    return formatter
//}()

// this is the top-level view for the app
struct ContentView: View {
    @StateObject var coursesModel = CoursesViewModel()
    @StateObject var roundsModel = RoundsViewModel()
    @StateObject var nav = NavigationStateManager()
    @State private var showingAlert = false
    @State private var status = PersistenceStatus.idle
    @State private var haveCourses = false
#if SIM_COURSE_LOADING_DELAY
    @State private var simulateCoursesLoadingDelay = false
#endif
#if SIM_ROUNDSMETA_LOADING_DELAY
    @State private var simulateRoundsMetaLoadingDelay = false
#endif
    var body: some View {
        Self._printChanges()
        return NavigationStack(path: $nav.path) {

            List(navigationItems) { item in
                    NavigationLink(value: item) {
                        Label(item.title, systemImage: item.icon)
                            .foregroundColor(.primary)
                    }
                    .disabled(item.menu == .courses && status == .savingCourses ||
                              item.menu == .rounds && (status == .savingRounds || !haveCourses))
                }
                .listStyle(.plain)
                .navigationTitle("Features")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: NavigationItem.self) { item in
                    switch item.menu {
                    case .courses:
                        CourseView(model: coursesModel)
                    case .rounds:
                        // Note this does the same thing as .courses. It's just so we can have three items
                        // in the view. Three is not special, one would work but I wanted to understand
                        // how a list works.
                        RoundsView()
//                        RoundsView(rounds: roundsModel)
                    case .analysis:
                        // Note this does the same thing as .courses. It's just so we can have three items
                        // in the view. Three is not special, one would work but I wanted to understand
                        // how a list works.
                        //                    CourseView(courseModel: courseModel)
                        //RoundsView(rounds: roundsMetaModel)
                        EmptyView()
                    case .settings:
                        SettingsView()
                    }
                }
                .onAppear() {
                    print ("ContentView onAppear")
//                    print ("coursesModel.courses.hasCourses = \(coursesModel.courses.hasCourses())")
                    if case .idle = coursesModel.courses.state {
                        coursesModel.courses.load()
                    }
                    if coursesModel.changesPending {
                        PersistenceManager.shared.saveCourses(coursesModel.courses, status: $status)
                        coursesModel.changesPending = false
                    }
                    if case .idle = roundsModel.rounds.state {
                        roundsModel.rounds.load()
                    }
                }
                .onReceive(coursesModel.courses.$state) { value in
                    print("courses state change: \(value)")
                    if case let .loaded(coursesA) = value {
                        haveCourses = coursesA.count > 0

                    }
                }
            if status == .savingCourses {
                Spacer()
                ProgressView("Saving Courses")
            }
#if SIM_COURSE_LOADING_DELAY
            Toggle(isOn: $simulateCoursesLoadingDelay) {
                Text("Simulate Courses Loading Delay")
            }
            .padding()
            .onChange(of: simulateCoursesLoadingDelay) { value in
                PersistenceManager.shared.simulateCoursesLoadingDelay = value
            }
#endif
#if SIM_ROUNDSMETA_LOADING_DELAY
            Toggle(isOn: $simulateRoundsMetaLoadingDelay) {
                Text("Simulate Rounds Meta Loading Delay")
            }
            .padding()
            .onChange(of: simulateRoundsMetaLoadingDelay) { value in
                PersistenceManager.shared.simulateRoundsMetaLoadingDelay = value
            }
#endif

        }
        .environmentObject(nav)
        .environmentObject(coursesModel)
        .environmentObject(roundsModel)
    }

//    private struct DemoRoundsView: View {
//        let model: CoursesViewModel
//        var body: some View {
//            if case let .loaded(courseA) = model.courses.state {
//                if courseA.count > 0 && courseA[0].tees.count > 0 {
//                    RoundsView(tee: courseA[0].tees[0])
//                } else {
//                    RoundsView(tee: Tee(id: UUID(), holes: 18, oddHcp: true))
//                }
//            } else {
//                RoundsView(tee: Tee(id: UUID(), holes: 18, oddHcp: true))
//            }
//        }
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

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
    NavigationItem(title: "Rounds", icon: "tablecells", menu: .scoring),
    NavigationItem(title: "Analysis", icon: "chart.line.uptrend.xyaxis", menu: .analysis),
]

enum Menu: String {
    case courses
    case scoring
    case analysis
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
    @State private var model = ContentViewModel()
    @StateObject var nav = NavigationStateManager()
    @State private var showingAlert = false

    var body: some View {
        Self._printChanges()
        return NavigationStack(path: $nav.path) {

            List(navigationItems) { item in
                    NavigationLink(value: item) {
                        Label(item.title, systemImage: item.icon)
                            .foregroundColor(.primary)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Features")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: NavigationItem.self) { item in
                    switch item.menu {
                    case .courses:
                        CourseView(model: model)
                    case .scoring:
                        // Note this does the same thing as .courses. It's just so we can have three items
                        // in the view. Three is not special, one would work but I wanted to understand
                        // how a list works.
                        RoundsView()
                    case .analysis:
                        // Note this does the same thing as .courses. It's just so we can have three items
                        // in the view. Three is not special, one would work but I wanted to understand
                        // how a list works.
                        //                    CourseView(courseModel: courseModel)
                        RoundsView()
                    }
                }
                .onAppear() {
                    if case .idle = model.courses.state {
                        model.courses.load()
                    }
                }
                .environmentObject(model.courses)
//            }
        }
        .environmentObject(nav)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

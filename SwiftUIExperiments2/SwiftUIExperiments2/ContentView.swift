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
    NavigationItem(title: "Golfers (Not Functional)", icon: "figure.golf", menu: .golfers),
    NavigationItem(title: "Hackers (Not Functional)", icon: "keyboard", menu: .hackers),
]

enum Menu: String {
    case courses
    case golfers
    case hackers
}


struct ContentView: View {
    let courseModel = CourseModel()
    private var invalidNavMenuItem : Bool = false

    var body: some View {
        Self._printChanges()
        return NavigationStack {
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
                    CourseView(courseModel: courseModel)
                case .golfers:
                    CourseView(courseModel: courseModel)
                case .hackers:
                    CourseView(courseModel: courseModel)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  NavigationStateManager.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/25/23.
//

import SwiftUI

class NavigationStateManager: ObservableObject {

    @Published var path = NavigationPath()
    func popToRoot() {
        path = NavigationPath()
    }
    func goToScoreView() {

    }
    func removeAllButOne() {
        if path.count > 1 {
            print("Nav stacks: \(path.count)")
            path.removeLast(path.count - 1)
        }
    }
}

//
//  ChooseTeeView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/25/23.
//

import SwiftUI

struct ChooseTeeView: View {

    @EnvironmentObject var nav: NavigationStateManager

    var body: some View {
        Self._printChanges()
        return VStack {
            Text("This view should pick the Tee for the new round")
        }
        .onAppear() {
            print("\(nav.path)")
        }
    }
}


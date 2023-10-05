//
//  GroupScoreView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/4/23.
//

import SwiftUI

struct GroupScoreView: View {

    var body: some View {
        Self._printChanges()
        return VStack {
            Text("This is where scores for other people in the group can be entered.")
        }
        .padding()
        .navigationTitle("Group Scoring")
        .navigationBarTitleDisplayMode(.inline)
    }
}

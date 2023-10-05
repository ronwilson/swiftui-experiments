//
//  ReviewScoreView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/4/23.
//

import SwiftUI

struct ReviewScoreView: View {

    var body: some View {
        Self._printChanges()
        return VStack {
            Text("This is where the scoring should be reviewed and finalized (state changed to submitted)")
            Text("This view should only be reachable from the last hole")
        }
        .padding()
        .navigationTitle("Submit Score")
        .navigationBarTitleDisplayMode(.inline)
    }
}

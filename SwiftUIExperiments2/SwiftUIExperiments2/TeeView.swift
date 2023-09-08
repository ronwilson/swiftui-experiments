//
//  TeeView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/7/23.
//

import SwiftUI

struct TeeView: View {
    let course: Course
    let tee: Tee
    @State private var teeColor: String = ""

    init(course: Course, tee: Tee) {
        self.course = course
        self.tee = tee
        _teeColor = State(initialValue: tee.color)
    }

    var body: some View {
        Self._printChanges()
        return VStack {
            HStack {
                Text("Tee Id:")
                Text("\(tee.id)")
            }
            HStack {
                Text("Tee Color:")
                TextField("color:", text: $teeColor)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        print("Tee color is now \(teeColor)")
                        course.setTeeColor(teeid: tee.id, color: teeColor)
                        //tee.color = teeColor
                    }
            }
        }
        .padding()
        .navigationTitle("Tee")
        .navigationBarTitleDisplayMode(.inline)
    }

}

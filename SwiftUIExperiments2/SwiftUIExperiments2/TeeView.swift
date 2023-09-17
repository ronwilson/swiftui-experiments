//
//  TeeView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/7/23.
//

import SwiftUI

struct TeeView: View {
    // changes to the course will not affect this view,
    // so course does not need to be Observed.
    let course: Course
    // Tee is a Struct, not a Class, so we'll need a copy of the Tee from
    // the caller (the CourseDetailView), and we need it to be wrapped with @State
    // so that the values can be edited through Bindings.
    @State var tee: Tee // This is a COPY of the Tee in the course instance, not a reference to a Class instance.
    @State var teepar: Int

    init(course: Course, tee: Tee) {
        self.course = course
        _tee = State(initialValue: tee)
        _teepar = State(initialValue: tee.par)
    }

    // Fonts and Formatters for the editing controls
    let gridHeaderFont = Font.system(Font.TextStyle.headline)
    let gridNumbersFont = Font.system(Font.TextStyle.body)

    let ratingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    // This is the source of the cycling view dependency and the infinite loop in the app. When this view
    // and the TeeboxEditView both have the same code to create a intFormatter, the app will enter an
    // infinite loop when navigating to the TeeboxEditView.
    // To see this, uncomment this code in both this TeeView and the TeeboxEditView and then run the app
    // and navigate to a TeeboxEditView.
    private let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    var body: some View {
        Self._printChanges()
        return VStack {
// The Tee id value is unimportant but if you want to see the value..
//            HStack {
//                Text("Tee Id:")
//                Text("\(tee.id)")
//            }
            Section(header: Text("\(course.name)")) {
                HStack {
                    Text("Tee Color:")
                    // Control to change the Tee color.
                    // When the user enters a Tee color, the binding is for the local
                    // @State above. I.e., the TextField updates the tee.color, which is
                    // a local state. The course must be notified that the tee color has changed
                    // for the Tee with tee.id. This is implemented here using the closure that is
                    // called when the TextField editing has ended. Another option would be to
                    // wait to call course.updateTee(tee: tee) only when the navigation stack is
                    // unwound (i.e. when going back to the CourseDetailView).
                    TextField("color:", text: $tee.color) { started in
                        if !started {
                            print("Tee color is now \(tee.color)")
                            // Have the course record the change of Tee color
                            course.updateTee(tee: tee)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                }
                // The Rating and Slope editor controls work like Tee Color above, the same comments apply.
                HStack {
                    Text("Rating:")
                    TextField("rating:", value: $tee.rating, formatter: ratingFormatter) { started in
                        if !started {
                            print("Tee rating is now \(tee.rating)")
                            course.updateTee(tee: tee)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    Text("Slope:")
                    TextField("slope:", value: $tee.slope, formatter: intFormatter) { started in
                        if !started {
                            print("Tee slope is now \(tee.slope)")
                            course.updateTee(tee: tee)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                }
                HStack {
                    Text("Par:")
                    Text("\(teepar)")
                }
            }
            Section {
                // I refactored the teebox editing functionality to its own View
                // because editing the teeboxes required several state variables.

                // The last parameter is a Binding to the teepar State variable that
                // is displayed in the HStack just above. When the user edits the
                // par values for the holes, this binding is update in the
                // TeeboxEditView code, which will cause the Text view above to be
                // updated.
                TeeboxEditView(tee: tee, course:course, holes: course.holes, teepar: $teepar)
            }
        }
        .padding()
        .navigationTitle("Tee")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func secondsValue(for date: Date) -> Double {
        let seconds = Calendar.current.component(.second, from: date)
        return Double(seconds) / 60
    }

}

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
//    @State var editingTeeboxes = false

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
//    private let intFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.maximumFractionDigits = 0
//        return formatter
//    }()

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
            }
            Section {
//                NavigationLink("Edit Teeboxes") {
//                    // Navigate to a view where the teebox data can be modified.
//                    // I did this just to avoid making this view any more complicated.
//                    TeeboxEditView(course: course, tee: tee)
//                }
                // Display all the Teeboxes (pars and handicaps) for this Tee.
                // This is a VStack where each line is an HStack, and each HStack is divided
                // into 3 columns where each column is 1/3 of the screen width.
                GeometryReader { reader in
                    VStack {
                        // Make a header row
                        HStack(alignment: .top, spacing: 8) {
                            Text("Hole")
                                .font(gridHeaderFont)
                                .frame(width: reader.size.width * 0.33, alignment: .leading)
                            Text("Par")
                                .font(gridHeaderFont)
                                .frame(width: reader.size.width * 0.33, alignment: .leading)
                            Text("Hcp")
                                .font(gridHeaderFont)
                                .frame(width: reader.size.width * 0.33, alignment: .leading)
                        }

                        // The list of teebox data can be scrollable if you want to support
                        // running the app in Landscape mode. However, all the Views for
                        // Course managment fit comfortably in a vertical orientation, so it's just easier to
                        // avoid the ScrollView and just support Portait orientation only.
                        // However, I'm using this ScrollView to show some other cool features.
                        ScrollView {
                            
                            // ForEach is another way to make a list. ForEach basically creates a View
                            // for each item in a RandomAccessCollection of some data type.
                            // The closure passed to a ForEach is run inside a result builder.
                            // Unlike the 'body' attribute for SwiftUI Views, you can't add a return
                            // statement before creating a view.
                            // If the code is changed to something like
                            //   ForEach(tee.teeboxes) { teebox in
                            //      let i = 0
                            //      return HStack(alignment: .top) {
                            // you'll get the error "Cannot use explicit 'return' statement in the body of
                            // result builder 'TableRowBuilder<_>'"
                            ForEach(tee.teeboxes) { teebox in
                                // Each item in a ForEach must be a View. Here were making each row be an HStack
                                HStack(alignment: .top) {
                                    // The hole number
                                    Text("\(teebox.hole)")
                                        .font(gridNumbersFont)
                                        .frame(width: reader.size.width * 0.33, alignment: .leading)

                                    // The par value
                                    Text("\(teebox.par)")
                                        .font(gridNumbersFont)
                                        .frame(width: reader.size.width * 0.33, alignment: .leading)        // 1/3 of screen
                                        .gesture(DragGesture(minimumDistance: 0).onChanged { gesture in
                                            //print("hole \(teebox.hole) : \(gesture.translation)")
                                            if gesture.translation.height < -30.0 {
                                                if teebox.par == 5 {
                                                    print("hole \(teebox.hole) : par 3")
                                                }
                                            } else if gesture.translation.height < -10.0 {
                                                if teebox.par > 3 {
                                                    print("hole \(teebox.hole) : par \(teebox.par - 1)")
                                                }
                                            } else if gesture.translation.height > 10.0 {
                                                if teebox.par < 5 {
                                                    print("hole \(teebox.hole) : par \(teebox.par + 1)")
                                                }
                                            } else if gesture.translation.height > 30.0 {
                                                if teebox.par == 3 {
                                                    print("hole \(teebox.hole) : par 5")
                                                }
                                            }
                                        })
                                    //                                .onEnded { _ in
                                    //                                    if abs(offset.width) > 100 {
                                    //                                        // remove the card
                                    //                                    } else {
                                    //                                        offset = .zero
                                    //                                    }
                                    //                                }
                                    Text("\(teebox.hcp)")
                                        .font(gridNumbersFont)
                                        .frame(width: reader.size.width * 0.33, alignment: .leading)
                                        .gesture(DragGesture(minimumDistance: 0).onChanged { gesture in
                                        })
                                }
                            }
                            
                        } // ScrollView
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Tee")
        .navigationBarTitleDisplayMode(.inline)
    }

}

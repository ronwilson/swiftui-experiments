//
//  TeeboxEditView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/9/23.
//

import SwiftUI

struct TeeboxEditView: View {
//    let teebox: CourseTeebox
    @ObservedObject var course: Course
    @State var tee: Tee
    @State private var editHoleIndex = 0
    let gridHeaderFont = Font.system(Font.TextStyle.headline)
    let gridNumbersFont = Font.system(Font.TextStyle.body)

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

    @Environment(\.isPresented) var isPresented

//    init(course: Course, teeForEditing: Tee) {
//        self.course = course
//        _tee = State(initialValue: teeForEditing)
//        //print("TeeboxEditView init tee id \(self.tee.id)")
//    }

//    init(teebox: CourseTeebox, editHoleIndex: Int = 0) {
//        self.teebox = teebox
//        self.editHoleIndex = editHoleIndex
////        _tee = State(initialValue: teebox.tee)
//        print("TeeboxEditView init teebox tee id \(teebox.tee.id)")
//    }

    var body: some View {
        Self._printChanges()
        return VStack {

            GeometryReader { reader in
                VStack {
//                    VStack {
//                        HStack {
//                            Stepper("Edit Teebox:", value: $editHoleIndex, in: 0...tee.teeboxes.count-1)
//                            //                                Stepper(value: $editHoleIndex, in 1...tee.teeboxes.count, step:1, label:Label("Edit Teebox")) { changed in
//                            //                                    print("Teebox changed \(changed)")
//                            //                                }
//                        }
//                        HStack {
//                            Text("\(editHoleIndex+1)")
//                            //                                    .foregroundColor(table.labelColor)
//                                .frame(width: reader.size.width * 0.33, alignment: .leading)
//                            TextField("par", value: $tee.teeboxes[editHoleIndex].par, formatter:intFormatter)
//                                .textFieldStyle(.roundedBorder)
//                                .labelsHidden()
//                                .frame(width: reader.size.width * 0.33, alignment: .leading)
//                            TextField("hcp", value: $tee.teeboxes[editHoleIndex].hcp, formatter:intFormatter)
//                                .textFieldStyle(.roundedBorder)
//                                .labelsHidden()
//                                .frame(width: reader.size.width * 0.33, alignment: .leading)
//                        }
//                    }
                    HStack(alignment: .top, spacing: 8) {
                        Text("Hole")
                            .font(gridHeaderFont)
                        //                                    .foregroundColor(table.labelColor)
                            .frame(width: reader.size.width * 0.33, alignment: .leading)
                        Text("Par")
                            .font(gridHeaderFont)
                        //                                    .foregroundColor(table.labelColor)
                            .frame(width: reader.size.width * 0.33, alignment: .leading)
                        Text("Hcp")
                            .font(gridHeaderFont)
                        //                                    .foregroundColor(table.labelColor)
                            .frame(width: reader.size.width * 0.33, alignment: .leading)
                    }
                    ScrollView {
                        ForEach(tee.teeboxes) { teebox in
                            HStack(alignment: .top) {
                                Text("\(teebox.hole)")
                                    .font(gridNumbersFont)
                                //                                    .foregroundColor(table.labelColor)
                                    .frame(width: reader.size.width * 0.33, alignment: .leading)
                                Text("\(teebox.par)")
                                    .font(gridNumbersFont)
                                //                                    .foregroundColor(table.labelColor)
                                    .frame(width: reader.size.width * 0.33, alignment: .leading)
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
                                //                                    .foregroundColor(table.labelColor)
                                    .frame(width: reader.size.width * 0.33, alignment: .leading)
                                    .gesture(DragGesture(minimumDistance: 0).onChanged { gesture in
                                        print("\(gesture.translation)")
                                    })
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Teeboxes")
        .navigationBarTitleDisplayMode(.inline)
//        .onChange(of: isPresented) { newValue in
//            if !newValue {
////                course.updateTee(tee: tee)
//            }
//        }
    }

}

//
//  TeeView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/7/23.
//

import SwiftUI

//struct CourseTeebox : Hashable {
//    let course: Course
//    @Binding var tee: Tee
//    static func == (lhs: CourseTeebox, rhs: CourseTeebox) -> Bool {
//        return true
//    }
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(course)
//        hasher.combine(tee.id)
//    }
//}

//struct TeeViewNavItem : Identifiable, Hashable {
//    let id: UUID = UUID()
//    let type: String
//}

struct TeeView: View {
    @ObservedObject var course: Course
    @State var tee: Tee
    @State var editingTeeboxes = false

//    @State private var editHoleIndex = 0
    let gridHeaderFont = Font.system(Font.TextStyle.headline)
    let gridNumbersFont = Font.system(Font.TextStyle.body)
    let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    let ratingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()
//    let navigationItems = [TeeViewNavItem(type: "Teeboxes")]

    var body: some View {
        Self._printChanges()
        return VStack {
//            HStack {
//                Text("Tee Id:")
//                Text("\(tee.id)")
//            }
            Section(header: Text("\(course.name)")) {
                HStack {
                    Text("Tee Color:")
                    TextField("color:", text: $tee.color) { started in
                        if !started {
                            print("Tee color is now \(tee.color)")
                            course.updateTee(tee: tee)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
//                    .onSubmit {
//                        print("Tee color is now \(tee.color)")
//                        course.updateTee(tee: tee)
//                    }
                }
                HStack {
                    Text("Rating:")
                    TextField("rating:", value: $tee.rating, formatter: ratingFormatter) { started in
                        if !started {
                            print("Tee rating is now \(tee.rating)")
                            course.updateTee(tee: tee)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
//                    .onSubmit {
//                        print("Tee rating is now \(tee.rating)")
//                        course.updateTee(tee: tee)
//                    }
                    Text("Slope:")
                    TextField("slope:", value: $tee.slope, formatter: intFormatter) { started in
                        if !started {
                            print("Tee slope is now \(tee.slope)")
                            course.updateTee(tee: tee)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
//                    .onSubmit {
//                        print("Tee slope is now \(tee.slope)")
//                        course.updateTee(tee: tee)
//                    }
                }
                HStack {
                    Text("Yardage:")
                    TextField("yardage:", value: $tee.yardage, formatter: intFormatter) { started in
                        if !started {
                            print("Tee yardage is now \(tee.yardage)")
                            course.updateTee(tee: tee)
                        }
                    }
                        .textFieldStyle(.roundedBorder)
//                        .onSubmit {
//                            print("Tee yardage is now \(tee.yardage)")
//                            course.updateTee(tee: tee)
//                        }
                }
            }
//            Section(header: Text("Tee Boxes")) {
            Section {
                NavigationLink("Edit Teeboxes") {
                    TeeboxEditView(course: course, tee: tee)
                }
                GeometryReader { reader in
                    VStack {
//                        VStack {
//                            HStack {
//                                Stepper("Edit Teebox:", value: $editHoleIndex, in: 0...tee.teeboxes.count-1)
//                                //                                Stepper(value: $editHoleIndex, in 1...tee.teeboxes.count, step:1, label:Label("Edit Teebox")) { changed in
//                                //                                    print("Teebox changed \(changed)")
//                                //                                }
//                            }
//                            HStack {
//                                Text("\(editHoleIndex+1)")
//                                //                                    .foregroundColor(table.labelColor)
//                                    .frame(width: reader.size.width * 0.33, alignment: .leading)
//                                TextField("par", value: $tee.teeboxes[editHoleIndex].par, formatter:intFormatter)
//                                    .textFieldStyle(.roundedBorder)
//                                    .labelsHidden()
//                                    .frame(width: reader.size.width * 0.33, alignment: .leading)
//                                TextField("hcp", value: $tee.teeboxes[editHoleIndex].hcp, formatter:intFormatter)
//                                    .textFieldStyle(.roundedBorder)
//                                    .labelsHidden()
//                                    .frame(width: reader.size.width * 0.33, alignment: .leading)
//                            }
//                        }
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
                                        .gesture(DragGesture().onChanged { gesture in
                                            print("\(gesture.translation)")
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
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Tee")
        .navigationBarTitleDisplayMode(.inline)
    }

}

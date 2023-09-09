//
//  TeeboxEditView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/9/23.
//

import SwiftUI

struct TeeboxEditView: View {
    let teebox: CourseTeebox
//    let course: Course
//    let tee: Tee
//    @State private var edittee: Tee = Tee(holes: 18)
    @State private var editHoleIndex = 0
    let gridHeaderFont = Font.system(Font.TextStyle.headline)
    let gridNumbersFont = Font.system(Font.TextStyle.body)
    let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    @State var tee: Tee = Tee(id: UUID(), holes: 18)
    @Environment(\.isPresented) var isPresented

    init(teebox: CourseTeebox, editHoleIndex: Int = 0) {
        self.teebox = teebox
        self.editHoleIndex = editHoleIndex
        _tee = State(initialValue: teebox.tee)
        print("TeeboxEditView init teebox tee id \(teebox.tee.id), tee id \(tee.id))")
    }

    var body: some View {
        Self._printChanges()
        return VStack {

            GeometryReader { reader in
                VStack {
                    VStack {
                        HStack {
                            Stepper("Edit Teebox:", value: $editHoleIndex, in: 0...teebox.tee.teeboxes.count-1)
                            //                                Stepper(value: $editHoleIndex, in 1...tee.teeboxes.count, step:1, label:Label("Edit Teebox")) { changed in
                            //                                    print("Teebox changed \(changed)")
                            //                                }
                        }
                        HStack {
                            Text("\(editHoleIndex+1)")
                            //                                    .foregroundColor(table.labelColor)
                                .frame(width: reader.size.width * 0.33, alignment: .leading)
                            TextField("par", value: $tee.teeboxes[editHoleIndex].par, formatter:intFormatter)
                                .textFieldStyle(.roundedBorder)
                                .labelsHidden()
                                .frame(width: reader.size.width * 0.33, alignment: .leading)
                            TextField("hcp", value: $tee.teeboxes[editHoleIndex].hcp, formatter:intFormatter)
                                .textFieldStyle(.roundedBorder)
                                .labelsHidden()
                                .frame(width: reader.size.width * 0.33, alignment: .leading)
                        }
                    }
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
        .padding()
        .navigationTitle("Teeboxes")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: isPresented) { newValue in
            if !newValue {
                teebox.course.updateTee(tee: tee)
            }
        }
    }

}

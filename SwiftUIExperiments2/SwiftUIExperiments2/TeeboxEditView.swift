//
//  TeeboxEditView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/9/23.
//

import SwiftUI

// This allows .noDragRow to be used where an Int is expected. .noDragRow means "not initialized" or "invalid value".
extension Int {
    public static let noDragRow: Int = -10000
}

// This is a refactored view supporting editing of the teebox pars and handicaps.
// This view is not a Navigation target, it is embedded within the TeeView view.
struct TeeboxEditView: View {

    // Fonts
    let teeboxHeaderFont = Font.system(Font.TextStyle.headline)
    let teeboxNumbersFont = Font.system(Font.TextStyle.body)
    // values passed from TeeView
    @State var tee: Tee
    let course: Course
    let holes: Int
    @Binding var teepar: Int    // A binding to a State var in the parent view
    // State for tracking editing
    @State private var teeboxDisplaySize: CGSize = .zero
    @State private var teeboxRowHeight: CGFloat = 0
    @State private var dragStartRow: Int = .noDragRow
    @State private var draggingPar: Bool = true
    @State private var dragValue: Int = 0
    @State private var holeEditPosition: CGPoint = .zero

    /*
        Scroll
            HStack
                VStack            ZStack
                                     VStack
                                        HStack
                    holes                   Pars    Hcp
                                     Canvas
                    0
                    1
                    2
     */

    var body: some View {
        Self._printChanges()
        return GeometryReader { geo in
            VStack {
                HStack(alignment: .top, spacing: 8) {
                    Text("Hole")
                        .font(teeboxHeaderFont)
                        .frame(width: geo.size.width * 0.33, alignment: .leading)
                    Text("Par")
                        .font(teeboxHeaderFont)
                        .frame(width: geo.size.width * 0.33, alignment: .leading)
                    Text("Hcp")
                        .font(teeboxHeaderFont)
                        .frame(width: geo.size.width * 0.33, alignment: .leading)
                }
                ScrollView {
                    HStack {
                        // The hole numbers are draggable and effect the scroll view movement.
                        VStack {
                            ForEach(tee.teeboxes) { teebox in
                                Text("\(teebox.hole)")
                                    .font(teeboxNumbersFont)
                                    .frame(width: geo.size.width * 0.33, alignment: .leading)
                            }
                        }
                        .frame(width: geo.size.width * 0.33)
                        //                            .background(Color.green)
                        // Use another GeometryReader so that we can get the dimensions of the canvas
                        GeometryReader { tbReader in
                            ZStack {
                                VStack {
                                    ForEach(tee.teeboxes) { teebox in
                                        HStack {
                                            Text("\(teebox.par)")
                                                .font(teeboxNumbersFont)
                                                .frame(width: geo.size.width * 0.33, alignment: .leading)        // 1/3 of screen
                                                //.background(Color(hue: Double(teebox.hole)/18, saturation: 1.0, brightness: 1.0))
                                            Text("\(teebox.hcp)")
                                                .font(teeboxNumbersFont)
                                                .frame(width: geo.size.width * 0.33, alignment: .leading)
                                                //.background(Color(hue: 1.0 - Double(teebox.hole)/18, saturation: 1.0, brightness: 1.0))
                                        }
                                    }
                                }
                                .onAppear {
                                    teeboxDisplaySize = tbReader.size
                                    teeboxRowHeight = teeboxDisplaySize.height / Double(holes)
                                }
                            }

                            //                                .background(Color.yellow)
                            // The canvas is used to draw the par or hcp text values as the user is doing
                            // the drag gesture.
                            Canvas(
                                opaque: false,
                                colorMode: .linear,
                                rendersAsynchronously: false
                            ) { context, size in
                                // This closure gets called when the user taps on the Canvas because the
                                // minimumDistance for the drag gesture is set to zero.

                                // If we're currently doing a drag action, update the value text
                                if dragStartRow != .noDragRow {
                                    // The dragValue and holeEditPosition will have been set in the gesture's onChanged
                                    // closure since that is called before the canvas is redrawn.
                                    let text = Text(verbatim: "\(dragValue)").font(.largeTitle)
                                    var resolvedText = context.resolve(text)
                                    resolvedText.shading = .color(.blue)
                                    context.draw(resolvedText, at: holeEditPosition, anchor: .center)
                                }
                            }
                            // This gesture takes priority over the normal ScrollView drag gesture because
                            // the minimumDistance is set to 0, meaning the gesture starts as soon as the user
                            // taps on the Canvas view. For the scroll view, the user must move the location
                            // (start dragging) before SwiftUI will recognize the action as a drag of the scroll view.
                            // Even though the Canvas is contained in the scroll view, only one gesture can be active
                            // at a time, so this one gets priority.
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { gesture in
                                // The canvas is layered on top of the VStack containing the teebox pars and handicaps
                                // and inside the same ZStack. The canvas will therefore have the same dimensions as
                                // teebox pars and handicaps.
                                // The row that was tapped can be calculated by dividing the canvas height by the number
                                // of holes.
                                let row = Int(gesture.location.y / teeboxDisplaySize.height * Double(holes))
                                // If we're not currently doing a drag action, start one now
                                if dragStartRow == .noDragRow {
                                    dragStartRow = row
                                    // If the user tapped over the pars, start a par editing drag
                                    if gesture.location.x < tbReader.size.width / 1.8 {
                                        // get the par for the tapped row
                                        dragValue = tee.teeboxes[row].par
                                        draggingPar = true
                                        // The par or hcp value will be drawn at a fixed X offset and centered on the
                                        // row that the gesture is currently over.
                                        // Note that this produces a 'snapping' effect when dragging the hcp values.
                                        holeEditPosition = CGPoint(x:20, y:(Double(row) + 0.5)*teeboxRowHeight)
                                        //print("Start Drag for Par row \(dragStartRow)")
                                    } else {
                                        // get the handicap for the row that was tapped
                                        dragValue = tee.teeboxes[row].hcp
                                        draggingPar = false
                                        // The par or hcp value will be drawn at a fixed X offset and centered on the
                                        // row that the gesture is currently over.
                                        // Note that this produces a 'snapping' effect when dragging the hcp values.
                                        holeEditPosition = CGPoint(x:tbReader.size.width / 2.0 + 40, y:(Double(row) + 0.5)*teeboxRowHeight)
                                        //print("Start Drag for Hcp row \(dragStartRow)")
                                    }
                                }
                                if draggingPar {
                                    // Par editing works like a picker in that the value will be changed
                                    // depending on how far the user drags up or down, and limited to a range
                                    // of 3 to 5.
                                    dragValue = dragPar(row:row)
                                    //print("new par for hole \(dragStartRow + 1) would be \(dragValue)")
                                } else {
                                    // while continuing the drag gesture, update the location for drawing
                                    // the handicap value. The effect is that the handicap value appears to
                                    // be moved rather than changed as for the par editing.
                                    holeEditPosition.y = (Double(row) + 0.5)*teeboxRowHeight
                                }
                            }.onEnded({ gesture in
                                // The user has stopped the drag gesture.
                                // Calculate that final row position.
                                let row = Int(gesture.location.y / teeboxDisplaySize.height * Double(tee.teeboxes.count))
                                if draggingPar {
                                    // Par column
                                    //print("End Drag on Par row \(row), \(gesture.location), translation \(gesture.translation)")
                                    // Get the final edited par value
                                    let newpar = dragPar(row:row)
                                    // If this is a change then set the new value and update the course model
                                    if tee.teeboxes[dragStartRow].par != newpar {
                                        // print("new par for hole \(dragStartRow + 1) is now \(newpar)")
                                        tee.teeboxes[dragStartRow].par = newpar
                                        course.updateTee(tee: tee)
                                        // update the total par binding for the Tee.
                                        // This is displayed just above the pars and hcps for the individual holes.
                                        teepar = tee.par
                                    }
                                } else {
                                    // Hcp column
                                    // print("End Drag on Hcp row \(row), \(gesture.location), translation \(gesture.translation)")
                                    // The effect for handicaps is that the hcp value from the starting row will be swapped with
                                    // the value currently on the row where the drag ended.
                                    // If the user ended the gesture off the top of bottom of the canvas, the calculated
                                    // row may be out of bounds. Just ignore the gesture in this case.
                                    if row >= 0 && row < 18 {
                                        // swap the hcp values for the start row and end row.
                                        let temphcp = tee.teeboxes[row].hcp
                                        tee.teeboxes[dragStartRow].hcp = temphcp
                                        tee.teeboxes[row].hcp = dragValue
                                        course.updateTee(tee: tee)
                                    }
                                }
                                // clear dragging state
                                dragStartRow = .noDragRow
                                draggingPar = false
                            }))
                        }
                    }
                }
            }
        }
    }

    // Calculate the change to the par value based on the number of rows the user is above or below the
    // starting row. Up 1 = subtract one, Up 2 = subtract two, Down 1 = add one, etc.
    // If the result is < 3 or > 5, limit the par to the range (3,5).
    private func dragPar(row: Int) -> Int {
        let currpar = tee.teeboxes[dragStartRow].par
        // if the drag is within the top and bottom rows, adjust the par.
        if dragStartRow >= 0 && dragStartRow < holes {
            let delta = row - dragStartRow
            var proposedpar = currpar + delta
            if proposedpar < 3 {
                proposedpar = 3
            }
            if proposedpar > 5 {
                proposedpar = 5
            }
            return proposedpar
        }
        // else user dragged off top or bottom, just return the current value.
        return currpar
    }

}

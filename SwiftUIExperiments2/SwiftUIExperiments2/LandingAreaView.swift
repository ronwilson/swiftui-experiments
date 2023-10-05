//
//  LandingAreaView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/23/23.
//

import SwiftUI

struct LandingAreaView: View {

//    typealias TapHandler = (LandingArea) -> Void
//    var approachTapHandler: TapHandler

    @Binding var drive: Drive
    @Binding var approach: Approach
//    @State var selectedDriveArea: LandingArea = .drivenone
//    @State var selectedApproachArea: LandingArea = .approachnone

    func onTapDriveArea(area: Drive) {
        if self.drive == area {
            // toggle all off
            self.drive = .other
//            approachTapHandler(.drivenone)
        } else {
            // toggling selected area on
            self.drive = area
//            approachTapHandler(area)
        }
    }

    func onTapApproachArea(area: Approach) {
        if approach == area {
            // toggle all off
            approach = .other
//            approachTapHandler(.approachnone)
        } else {
            // toggling selected area on
            approach = area
//            approachTapHandler(area)
        }
    }

    var body: some View {
        Self._printChanges()
        return VStack {
            ZStack {
                ZStack {
                    LandingAreaFairway()
                        .fill(self.drive == .fairway ? .green : Color(.systemGray3))
                        .driveTapHandler(.fairway, tapHandler: onTapDriveArea)
                    LandingAreaFairway()
                        .stroke(.black)
                    LandingAreaLeftRuff()
                        .fill(self.drive == .leftruff ? .yellow : .gray)
                        .driveTapHandler(.leftruff, tapHandler: onTapDriveArea)
                    LandingAreaLeftRuff()
                        .stroke(.black)
                    LandingAreaRightRuff()
                        .fill(self.drive == .rightruff ? .yellow : .gray)
                        .driveTapHandler(.rightruff, tapHandler: onTapDriveArea)
                    LandingAreaRightRuff()
                        .stroke(.black)
                }
                ZStack {
                    ZStack {
                        LandingAreaBack()
                            .fill(self.approach == .back ? .yellow : .gray)
                            .approachTapHandler(.back, tapHandler: onTapApproachArea)
                        LandingAreaBack()
                            .stroke(.black)
                        LandingAreaRight()
                            .fill(self.approach == .right ? .yellow : .gray)
                            .approachTapHandler(.right, tapHandler: onTapApproachArea)
                        LandingAreaRight()
                            .stroke(.black)
                        LandingAreaFront()
                            .fill(self.approach == .front ? .yellow : .gray)
                            .approachTapHandler(.front, tapHandler: onTapApproachArea)
                        LandingAreaFront()
                            .stroke(.black)
                        LandingAreaLeft()
                            .fill(self.approach == .left ? .yellow : .gray)
                            .approachTapHandler(.left, tapHandler: onTapApproachArea)
                        LandingAreaLeft()
                            .stroke(.black)
                    }
                    ZStack {
                        LandingAreaBackLeft()
                            .fill(self.approach == .backleft ? .yellow : Color(.systemGray2))
                            .approachTapHandler(.backleft, tapHandler: onTapApproachArea)
                        LandingAreaBackLeft()
                            .stroke(.black)
                        LandingAreaBackRight()
                            .fill(self.approach == .backright ? .yellow : Color(.systemGray2))
                            .approachTapHandler(.backright, tapHandler: onTapApproachArea)
                        LandingAreaBackRight()
                            .stroke(.black)
                        LandingAreaFrontRight()
                            .fill(self.approach == .frontright ? .yellow : Color(.systemGray2))
                            .approachTapHandler(.frontright, tapHandler: onTapApproachArea)
                        LandingAreaFrontRight()
                            .stroke(.black)
                        LandingAreaFrontLeft()
                            .fill(self.approach == .frontleft ? .yellow : Color(.systemGray2))
                            .approachTapHandler(.frontleft, tapHandler: onTapApproachArea)
                        LandingAreaFrontLeft()
                            .stroke(.black)
                    }
                    ZStack {
                        LandingAreaGreen()
                            .fill(self.approach == .green ? .green : Color(.systemGray3))
                            .approachTapHandler(.green, tapHandler: onTapApproachArea)
                        LandingAreaGreen()
                            .stroke(.black)
                    }
                }
            }
        }
    }
}

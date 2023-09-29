//
//  LandingAreaView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/23/23.
//

import SwiftUI

struct LandingAreaView: View {

    var landingAreaTapHandler: (LandingArea) -> Void

    @State var selectedDriveArea: LandingArea = .drivenone
    @State var selectedApproachArea: LandingArea = .approachnone

    func onTapDriveArea(area: LandingArea) {
        if self.selectedDriveArea == area {
            // toggle all off
            self.selectedDriveArea = .drivenone
            landingAreaTapHandler(.drivenone)
        } else {
            // toggling selected area on
            self.selectedDriveArea = area
            landingAreaTapHandler(area)
        }
    }

    func onTapApproachArea(area: LandingArea) {
        if self.selectedApproachArea == area {
            // toggle all off
            self.selectedApproachArea = .approachnone
            landingAreaTapHandler(.approachnone)
        } else {
            // toggling selected area on
            self.selectedApproachArea = area
            landingAreaTapHandler(area)
        }
    }

    var body: some View {
        Self._printChanges()
        return VStack {
            ZStack {
                ZStack {
                    LandingAreaFairway()
                        .fill(self.selectedDriveArea == .fairway ? .green : Color(.systemGray3))
                        .landingAreaTapHandler(.fairway, tapHandler: onTapDriveArea)
                    LandingAreaFairway()
                        .stroke(.black)
                    LandingAreaLeftRuff()
                        .fill(self.selectedDriveArea == .leftruff ? .yellow : .gray)
                        .landingAreaTapHandler(.leftruff, tapHandler: onTapDriveArea)
                    LandingAreaLeftRuff()
                        .stroke(.black)
                    LandingAreaRightRuff()
                        .fill(self.selectedDriveArea == .rightruff ? .yellow : .gray)
                        .landingAreaTapHandler(.rightruff, tapHandler: onTapDriveArea)
                    LandingAreaRightRuff()
                        .stroke(.black)
                }
                ZStack {
                    ZStack {
                        LandingAreaBack()
                            .fill(self.selectedApproachArea == .back ? .yellow : .gray)
                            .landingAreaTapHandler(.back, tapHandler: onTapApproachArea)
                        LandingAreaBack()
                            .stroke(.black)
                        LandingAreaRight()
                            .fill(self.selectedApproachArea == .right ? .yellow : .gray)
                            .landingAreaTapHandler(.right, tapHandler: onTapApproachArea)
                        LandingAreaRight()
                            .stroke(.black)
                        LandingAreaFront()
                            .fill(self.selectedApproachArea == .front ? .yellow : .gray)
                            .landingAreaTapHandler(.front, tapHandler: onTapApproachArea)
                        LandingAreaFront()
                            .stroke(.black)
                        LandingAreaLeft()
                            .fill(self.selectedApproachArea == .left ? .yellow : .gray)
                            .landingAreaTapHandler(.left, tapHandler: onTapApproachArea)
                        LandingAreaLeft()
                            .stroke(.black)
                    }
                    ZStack {
                        LandingAreaBackLeft()
                            .fill(self.selectedApproachArea == .backleft ? .yellow : Color(.systemGray2))
                            .landingAreaTapHandler(.backleft, tapHandler: onTapApproachArea)
                        LandingAreaBackLeft()
                            .stroke(.black)
                        LandingAreaBackRight()
                            .fill(self.selectedApproachArea == .backright ? .yellow : Color(.systemGray2))
                            .landingAreaTapHandler(.backright, tapHandler: onTapApproachArea)
                        LandingAreaBackRight()
                            .stroke(.black)
                        LandingAreaFrontRight()
                            .fill(self.selectedApproachArea == .frontright ? .yellow : Color(.systemGray2))
                            .landingAreaTapHandler(.frontright, tapHandler: onTapApproachArea)
                        LandingAreaFrontRight()
                            .stroke(.black)
                        LandingAreaFrontLeft()
                            .fill(self.selectedApproachArea == .frontleft ? .yellow : Color(.systemGray2))
                            .landingAreaTapHandler(.frontleft, tapHandler: onTapApproachArea)
                        LandingAreaFrontLeft()
                            .stroke(.black)
                    }
                    ZStack {
                        LandingAreaGreen()
                            .fill(self.selectedApproachArea == .green ? .green : Color(.systemGray3))
                            .landingAreaTapHandler(.green, tapHandler: onTapApproachArea)
                        LandingAreaGreen()
                            .stroke(.black)
                    }
                }
            }
        }
    }
}

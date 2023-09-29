//
//  SandTrapView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/23/23.
//

import SwiftUI

struct SandTrapBottom: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        // BottomSand
        path.addEllipse(in: CGRect(x: 0.0022*width, y: 0.00163*height, width: 0.99737*width, height: 0.99776*height))
        return path
    }
}

struct SandTrapTop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        // TopGreen
        path.addEllipse(in: CGRect(x: 0, y: 0, width: 0.99737*width, height: 0.89063*height))
        return path
    }
}

struct SandTrapTrap: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        // SandTrap
        path.move(to: CGPoint(x: 0.12254*width, y: 0.43352*height))
        path.addCurve(to: CGPoint(x: 0.23332*width, y: 0.29292*height), control1: CGPoint(x: 0.11864*width, y: 0.30713*height), control2: CGPoint(x: 0.17419*width, y: 0.28135*height))
        path.addCurve(to: CGPoint(x: 0.40698*width, y: 0.19504*height), control1: CGPoint(x: 0.47014*width, y: 0.33926*height), control2: CGPoint(x: 0.4669*width, y: 0.27526*height))
        path.addCurve(to: CGPoint(x: 0.50031*width, y: 0.08231*height), control1: CGPoint(x: 0.32461*width, y: 0.08473*height), control2: CGPoint(x: 0.44338*width, y: 0.02426*height))
        path.addCurve(to: CGPoint(x: 0.65187*width, y: 0.14755*height), control1: CGPoint(x: 0.57366*width, y: 0.15712*height), control2: CGPoint(x: 0.57703*width, y: 0.15518*height))
        path.addCurve(to: CGPoint(x: 0.7765*width, y: 0.32147*height), control1: CGPoint(x: 0.87406*width, y: 0.1249*height), control2: CGPoint(x: 0.85621*width, y: 0.32485*height))
        path.addCurve(to: CGPoint(x: 0.69152*width, y: 0.42124*height), control1: CGPoint(x: 0.66639*width, y: 0.31679*height), control2: CGPoint(x: 0.61873*width, y: 0.35423*height))
        path.addCurve(to: CGPoint(x: 0.75228*width, y: 0.67345*height), control1: CGPoint(x: 0.76812*width, y: 0.49176*height), control2: CGPoint(x: 0.83139*width, y: 0.59811*height))
        path.addCurve(to: CGPoint(x: 0.30939*width, y: 0.735*height), control1: CGPoint(x: 0.65971*width, y: 0.76161*height), control2: CGPoint(x: 0.40082*width, y: 0.79759*height))
        path.addCurve(to: CGPoint(x: 0.12254*width, y: 0.43352*height), control1: CGPoint(x: 0.21796*width, y: 0.67241*height), control2: CGPoint(x: 0.12466*width, y: 0.50226*height))
        path.closeSubpath()
        return path
    }
}

struct SandTrapBall: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        // Ball
        path.addEllipse(in: CGRect(x: 0.46219*width, y: 0.44319*height, width: 0.11669*width, height: 0.18105*height))
        return path
    }
}


struct SandTrapTapHandler: ViewModifier {
    var sandTrapTapHandler: () -> Void
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                sandTrapTapHandler()
            }
    }
}

extension View {
    func sandTrapTapHandler(tapHandler: @escaping () -> Void) -> some View {
        modifier(SandTrapTapHandler(sandTrapTapHandler: tapHandler))
    }
}


struct SandTrapView: View {

    var sandTrapTapHandler: () -> Void

    @State var hitSandTrap: Bool = false

    func onTapSandTrap() {
        self.hitSandTrap = !self.hitSandTrap
        sandTrapTapHandler()
    }

    var body: some View {
        Self._printChanges()
        return VStack {
            ZStack {
                SandTrapBottom()
                    .fill(self.hitSandTrap ? .brown : .gray)
                    .sandTrapTapHandler(tapHandler: onTapSandTrap)
                SandTrapTop()
                    .fill(self.hitSandTrap ? .green : Color(.systemGray2))
                    .sandTrapTapHandler(tapHandler: onTapSandTrap)
                SandTrapTrap()
                    .fill(self.hitSandTrap ? .brown : .gray)
                    .sandTrapTapHandler(tapHandler: onTapSandTrap)
                SandTrapBall()
                    .fill(self.hitSandTrap ? .white : Color(.systemGray3))
                    .sandTrapTapHandler(tapHandler: onTapSandTrap)
            }
        }
    }
}

//
//  ShotShape.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/23/23.
//

import SwiftUI


//enum LandingArea {
//    case drivenone
//    case approachnone
//    case green
//    case backleft
//    case back
//    case backright
//    case left
//    case right
//    case frontleft
//    case front
//    case frontright
//    case fairway
//    case leftruff
//    case rightruff
//}

struct DriveTapHandler: ViewModifier {
    var area: Drive
    var landingAreaTapHandler: (Drive) -> Void
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                landingAreaTapHandler(area)
            }
    }
}

struct ApproachTapHandler: ViewModifier {
    var area: Approach
    var landingAreaTapHandler: (Approach) -> Void
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                landingAreaTapHandler(area)
            }
    }
}


extension View {
    func driveTapHandler(_ area: Drive, tapHandler: @escaping (Drive) -> Void) -> some View {
        modifier(DriveTapHandler(area: area, landingAreaTapHandler: tapHandler))
    }
    func approachTapHandler(_ area: Approach, tapHandler: @escaping (Approach) -> Void) -> some View {
        modifier(ApproachTapHandler(area: area, landingAreaTapHandler: tapHandler))
    }
}

struct LandingAreaBack: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        //  Back            Z 2
        path.move(to: CGPoint(x: 0.49588*width, y: 0.3311*height))
        path.addCurve(to: CGPoint(x: 0.32327*width, y: 0.02091*height), control1: CGPoint(x: 0.49588*width, y: 0.3311*height), control2: CGPoint(x: 0.34383*width, y: 0.05885*height))
        path.addCurve(to: CGPoint(x: 0.65719*width, y: 0.01715*height), control1: CGPoint(x: 0.44207*width, y: -0.00698*height), control2: CGPoint(x: 0.56518*width, y: -0.00379*height))
        path.addCurve(to: CGPoint(x: 0.50278*width, y: 0.33111*height), control1: CGPoint(x: 0.63997*width, y: 0.05214*height), control2: CGPoint(x: 0.50278*width, y: 0.33111*height))
        path.addLine(to: CGPoint(x: 0.49588*width, y: 0.3311*height))
        path.closeSubpath()

        return path
    }
}

struct LandingAreaRight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // Right            Z 2
        path.move(to: CGPoint(x: 0.49753*width, y: 0.32659*height))
        path.addCurve(to: CGPoint(x: 0.95049*width, y: 0.18754*height), control1: CGPoint(x: 0.49753*width, y: 0.32659*height), control2: CGPoint(x: 0.89329*width, y: 0.20486*height))
        path.addCurve(to: CGPoint(x: 0.93176*width, y: 0.49652*height), control1: CGPoint(x: 1.01651*width, y: 0.28657*height), control2: CGPoint(x: 1.01956*width, y: 0.38907*height))
        path.addCurve(to: CGPoint(x: 0.49763*width, y: 0.33259*height), control1: CGPoint(x: 0.8576*width, y: 0.46924*height), control2: CGPoint(x: 0.49763*width, y: 0.33259*height))
        path.addLine(to: CGPoint(x: 0.49753*width, y: 0.32659*height))
        path.closeSubpath()

        return path
    }
}

struct LandingAreaFront: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // Front            Z 2
        path.move(to: CGPoint(x: 0.49604*width, y: 0.32896*height))
        path.addCurve(to: CGPoint(x: 0.34264*width, y: 0.64423*height), control1: CGPoint(x: 0.49604*width, y: 0.32896*height), control2: CGPoint(x: 0.36109*width, y: 0.60626*height))
        path.addCurve(to: CGPoint(x: 0.67902*width, y: 0.63839*height), control1: CGPoint(x: 0.45338*width, y: 0.66653*height), control2: CGPoint(x: 0.56051*width, y: 0.66979*height))
        path.addCurve(to: CGPoint(x: 0.50276*width, y: 0.3289*height), control1: CGPoint(x: 0.65695*width, y: 0.59876*height), control2: CGPoint(x: 0.50276*width, y: 0.3289*height))
        path.addLine(to: CGPoint(x: 0.49604*width, y: 0.32896*height))
        path.closeSubpath()

        return path
    }
}

struct LandingAreaLeft: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // Left             Z 2
        path.move(to: CGPoint(x: 0.50119*width, y: 0.32662*height))
        path.addCurve(to: CGPoint(x: 0.06728*width, y: 0.16458*height), control1: CGPoint(x: 0.50119*width, y: 0.32662*height), control2: CGPoint(x: 0.10729*width, y: 0.17911*height))
        path.addCurve(to: CGPoint(x: 0.0458*width, y: 0.46943*height), control1: CGPoint(x: -0.00202*width, y: 0.23336*height), control2: CGPoint(x: -0.03027*width, y: 0.3588*height))
        path.addCurve(to: CGPoint(x: 0.50116*width, y: 0.33252*height), control1: CGPoint(x: 0.12194*width, y: 0.44638*height), control2: CGPoint(x: 0.50116*width, y: 0.33252*height))
        path.addLine(to: CGPoint(x: 0.50119*width, y: 0.32662*height))
        path.closeSubpath()

        return path
    }
}

struct LandingAreaBackLeft: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // Back Left        Z 3
        path.move(to: CGPoint(x: 0.4993*width, y: 0.32984*height))
        path.addCurve(to: CGPoint(x: 0.06436*width, y: 0.1678*height), control1: CGPoint(x: 0.4993*width, y: 0.32984*height), control2: CGPoint(x: 0.15916*width, y: 0.20497*height))
        path.addCurve(to: CGPoint(x: 0.33018*width, y: 0.01927*height), control1: CGPoint(x: 0.1325*width, y: 0.08742*height), control2: CGPoint(x: 0.24637*width, y: 0.03896*height))
        path.addCurve(to: CGPoint(x: 0.4993*width, y: 0.32984*height), control1: CGPoint(x: 0.37616*width, y: 0.1055*height), control2: CGPoint(x: 0.4993*width, y: 0.32984*height))
        path.closeSubpath()

        return path
    }
}

struct LandingAreaBackRight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // BackRight        Z 3
        path.move(to: CGPoint(x: 0.49925*width, y: 0.32981*height))
        path.addCurve(to: CGPoint(x: 0.64912*width, y: 0.01535*height), control1: CGPoint(x: 0.49925*width, y: 0.32981*height), control2: CGPoint(x: 0.61892*width, y: 0.07842*height))
        path.addCurve(to: CGPoint(x: 0.95469*width, y: 0.19376*height), control1: CGPoint(x: 0.81921*width, y: 0.05397*height), control2: CGPoint(x: 0.90388*width, y: 0.12357*height))
        path.addCurve(to: CGPoint(x: 0.49925*width, y: 0.32981*height), control1: CGPoint(x: 0.81722*width, y: 0.23448*height), control2: CGPoint(x: 0.49925*width, y: 0.32981*height))
        path.closeSubpath()

        return path
    }
}

struct LandingAreaFrontRight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // FrontRight       Z 3
        path.move(to: CGPoint(x: 0.49928*width, y: 0.3298*height))
        path.addCurve(to: CGPoint(x: 0.93647*width, y: 0.49081*height), control1: CGPoint(x: 0.49928*width, y: 0.3298*height), control2: CGPoint(x: 0.7906*width, y: 0.43807*height))
        path.addCurve(to: CGPoint(x: 0.67054*width, y: 0.64056*height), control1: CGPoint(x: 0.8964*width, y: 0.53815*height), control2: CGPoint(x: 0.83116*width, y: 0.59758*height))
        path.addCurve(to: CGPoint(x: 0.49928*width, y: 0.3298*height), control1: CGPoint(x: 0.60451*width, y: 0.52289*height), control2: CGPoint(x: 0.49928*width, y: 0.3298*height))
        path.closeSubpath()

        return path
    }
}

struct LandingAreaFrontLeft: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // Front Left       Z 3
        path.move(to: CGPoint(x: 0.49928*width, y: 0.32975*height))
        path.addCurve(to: CGPoint(x: 0.34911*width, y: 0.64553*height), control1: CGPoint(x: 0.49928*width, y: 0.32975*height), control2: CGPoint(x: 0.402*width, y: 0.53546*height))
        path.addCurve(to: CGPoint(x: 0.04247*width, y: 0.46475*height), control1: CGPoint(x: 0.23315*width, y: 0.62247*height), control2: CGPoint(x: 0.09765*width, y: 0.55711*height))
        path.addCurve(to: CGPoint(x: 0.49928*width, y: 0.32975*height), control1: CGPoint(x: 0.18426*width, y: 0.42423*height), control2: CGPoint(x: 0.49928*width, y: 0.32975*height))
        path.closeSubpath()

        return path
    }
}

struct LandingAreaGreen: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // Green            Z 4
        path.move(to: CGPoint(x: 0.4995*width, y: 0.169*height))
        path.addCurve(to: CGPoint(x: 0.73036*width, y: 0.32923*height), control1: CGPoint(x: 0.63433*width, y: 0.169*height), control2: CGPoint(x: 0.73036*width, y: 0.24762*height))
        path.addCurve(to: CGPoint(x: 0.50011*width, y: 0.48971*height), control1: CGPoint(x: 0.73036*width, y: 0.40516*height), control2: CGPoint(x: 0.64334*width, y: 0.48971*height))
        path.addCurve(to: CGPoint(x: 0.26934*width, y: 0.32912*height), control1: CGPoint(x: 0.36797*width, y: 0.48971*height), control2: CGPoint(x: 0.26934*width, y: 0.41541*height))
        path.addCurve(to: CGPoint(x: 0.4995*width, y: 0.169*height), control1: CGPoint(x: 0.26934*width, y: 0.22442*height), control2: CGPoint(x: 0.39724*width, y: 0.169*height))
        path.closeSubpath()

        return path
    }
}

struct LandingAreaFairway: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // Fairway          Z 0
        path.addRect(CGRect(x: 0.28581*width, y: 0.62898*height, width: 0.39891*width, height: 0.37076*height))

        return path
    }
}

struct LandingAreaLeftRuff: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // Left Ruff        Z 1
        path.move(to: CGPoint(x: 0.14376*width, y: 0.55974*height))
        path.addCurve(to: CGPoint(x: 0.29684*width, y: 0.62864*height), control1: CGPoint(x: 0.18397*width, y: 0.58406*height), control2: CGPoint(x: 0.25194*width, y: 0.61937*height))
        path.addCurve(to: CGPoint(x: 0.35898*width, y: 0.74401*height), control1: CGPoint(x: 0.34439*width, y: 0.6293*height), control2: CGPoint(x: 0.36279*width, y: 0.72689*height))
        path.addCurve(to: CGPoint(x: 0.32035*width, y: 0.84756*height), control1: CGPoint(x: 0.35518*width, y: 0.76113*height), control2: CGPoint(x: 0.34329*width, y: 0.81317*height))
        path.addCurve(to: CGPoint(x: 0.30308*width, y: 0.99985*height), control1: CGPoint(x: 0.29741*width, y: 0.88196*height), control2: CGPoint(x: 0.29849*width, y: 0.96342*height))
        path.addCurve(to: CGPoint(x: 0.06688*width, y: 0.99981*height), control1: CGPoint(x: 0.11688*width, y: 0.99992*height), control2: CGPoint(x: 0.22411*width, y: 0.99966*height))
        path.addCurve(to: CGPoint(x: 0.0805*width, y: 0.83316*height), control1: CGPoint(x: 0.09261*width, y: 0.9069*height), control2: CGPoint(x: 0.07807*width, y: 0.91252*height))
        path.addCurve(to: CGPoint(x: 0.14681*width, y: 0.64772*height), control1: CGPoint(x: 0.08195*width, y: 0.78593*height), control2: CGPoint(x: 0.11536*width, y: 0.69384*height))
        path.addCurve(to: CGPoint(x: 0.14376*width, y: 0.55974*height), control1: CGPoint(x: 0.1824*width, y: 0.59554*height), control2: CGPoint(x: 0.14368*width, y: 0.57151*height))
        path.closeSubpath()

        return path
    }
}

struct LandingAreaRightRuff: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // Right Ruff       Z 1
        path.move(to: CGPoint(x: 0.61688*width, y: 0.64575*height))
        path.addCurve(to: CGPoint(x: 0.87056*width, y: 0.54624*height), control1: CGPoint(x: 0.63928*width, y: 0.64067*height), control2: CGPoint(x: 0.7767*width, y: 0.60712*height))
        path.addCurve(to: CGPoint(x: 0.88077*width, y: 0.71108*height), control1: CGPoint(x: 0.85768*width, y: 0.58014*height), control2: CGPoint(x: 0.85893*width, y: 0.6705*height))
        path.addCurve(to: CGPoint(x: 0.92725*width, y: 0.84915*height), control1: CGPoint(x: 0.90026*width, y: 0.74728*height), control2: CGPoint(x: 0.90678*width, y: 0.7862*height))
        path.addCurve(to: CGPoint(x: 0.96162*width, y: 0.99938*height), control1: CGPoint(x: 0.94772*width, y: 0.9121*height), control2: CGPoint(x: 0.96005*width, y: 0.95272*height))
        path.addCurve(to: CGPoint(x: 0.66341*width, y: 0.99938*height), control1: CGPoint(x: 0.83718*width, y: 0.99914*height), control2: CGPoint(x: 0.75374*width, y: 0.99933*height))
        path.addCurve(to: CGPoint(x: 0.64301*width, y: 0.77474*height), control1: CGPoint(x: 0.68159*width, y: 0.97811*height), control2: CGPoint(x: 0.67751*width, y: 0.81651*height))
        path.addCurve(to: CGPoint(x: 0.61688*width, y: 0.64575*height), control1: CGPoint(x: 0.61113*width, y: 0.73614*height), control2: CGPoint(x: 0.59716*width, y: 0.69774*height))
        path.closeSubpath()

        return path
    }
}

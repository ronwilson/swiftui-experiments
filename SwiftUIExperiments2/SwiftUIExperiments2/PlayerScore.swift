//
//  PlayerScore.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/3/23.
//

import SwiftUI

extension Int {
    public static let scoreIsZero: Int = 10000
}

struct PlayerScore : Identifiable{
    let id: UUID
    let name:String
    let hcp: Int
    var strokes: [Int] = [Int](repeating: 0, count: 18)

    // Derived
    var outstrokes : Int {
        strokes[0..<9].reduce(0, {$0 + $1})
    }
    var instrokes : Int {
        strokes[9..<18].reduce(0, {$0 + $1})
    }
    var totalstrokes : Int {
        outstrokes + instrokes
    }
    var frontStrokeValues: [Int] {
        return Array(strokes[0...8])
    }
    var backStrokeValues: [Int] {
        return Array(strokes[9...17])
    }
    func strokes(_ r: ClosedRange<Int>, tee: Tee) -> [String] {
        return r.map { holeStrokes(hole: $0, tee: tee) }
    }
    func scores(_ r: ClosedRange<Int>, tee: Tee) -> [Int] {
        return r.map { holeStrokeScore(hole: $0, tee: tee) }
    }
    func strokeScores(_ r: ClosedRange<Int>, tee: Tee) -> [String] {
        return r.map { strokeHoleScore(hole: $0, tee: tee) }
    }

    func holeStrokes(hole: Int, tee: Tee) -> String {
        let strokes = strokes[hole]
        if strokes > 0 {
            let delta = tee.strokeHandicap(for: hole, handicap: hcp)
            if delta > 1 {
                return ":\(strokes)"
            } else if delta > 0 {
                return ".\(strokes)"
            }
            return "\(strokes)"
        }
        return ""
    }

    func holeStrokeScore(hole: Int, tee: Tee) -> Int {
        let holescore = strokes[hole]
        if holescore > 0 {
            let delta = tee.strokeHandicap(for: hole, handicap: hcp)
            let score = strokes[hole] - delta
            if score > 0 {
                return score
            } else {
                return .scoreIsZero
            }
        }
        return 0
    }

    func strokeHoleScore(hole: Int, tee: Tee) -> String {
        let holescore = strokes[hole]
        if holescore > 0 {
            let delta = tee.strokeHandicap(for: hole, handicap: hcp)
            let score = strokes[hole] - delta
            if delta > 1 {
                return ":\(score)"
            } else if delta > 0 {
                return ".\(score)"
            }
            return "\(score)"
        }
        return ""
    }

    static func randomPlayers(tee: Tee) -> [PlayerScore] {
        let names = ["William", "Jon", "Ronald", "Freddy"]
        var scores = [PlayerScore]()
        let count = Int.random(in: 1...4)
        let holes = Int.random(in: 5...17)
        for i in 0..<count {
            scores.append(PlayerScore.randomPlayer(name: names[i], tee: tee, holes: holes))
        }
        return scores
    }

    static func randomPlayer(name: String, tee: Tee, holes: Int) -> PlayerScore {
        let hcp = Int.random(in: 18...30)
        var playerscore = PlayerScore(id: UUID(), name: name, hcp: hcp)
        for box in 0...holes {
//        for box in tee.teeboxes {
//            for n in 0..<100 {
//                print("\(n), \(randomStrokes())")
//            }
            let strokes = PlayerScore.randomStrokes()
            playerscore.strokes[box] = tee.teeboxes[box].par + strokes
        }
        return playerscore
    }

    static func strokes(x: Int) -> Int {
        let strokecoeff: [Double] = [ 7.22149077e-12, 2.79215008e-09, 2.08172955e-07, -3.51920153e-04, 6.05411443e-03, 2.44239287e+00]
        let dx = Double(x)
        let y5 = strokecoeff[0] * pow(dx, 5)
        let y4 = strokecoeff[1] * pow(dx, 4)
        let y3 = strokecoeff[2] * pow(dx, 3)
        let y2 = strokecoeff[3] * pow(dx, 2)
        let y1 = strokecoeff[4] * dx
        let y0 = strokecoeff[5]
        let strokes = Int(round((y5 + y4 + y3 + y2 + y1 + y0)/100.0))
        if strokes < -2 {
            return -2
        } else if strokes > 18 {
            return 18
        }
        return strokes
    }

    static func randomStrokes() -> Int {
        let x = Int.random(in: -523...645)
        return PlayerScore.strokes(x: x)
    }


}


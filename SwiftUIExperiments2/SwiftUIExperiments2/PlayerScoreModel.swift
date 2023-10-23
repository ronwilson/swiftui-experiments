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

enum Approach : String, Codable {
    case other = "Other"
    case green = "GIR"
    case backleft = "Back Left"
    case back = "Back"
    case backright = "Back Right"
    case left = "Left"
    case right = "Right"
    case frontleft = "Front Left"
    case front = "Front"
    case frontright = "Front Right"
}

enum Drive : String, Codable {
    case other = "Other"
    case fairway = "Fairway"
    case leftruff = "Left Rough"
    case rightruff = "Right Rough"
}

final class HoleScore : Identifiable, Equatable, ObservableObject {
    var id: UUID = UUID()
    //TODO: Make default strokes and putts a user setting
    @Published var strokes = 4
    @Published var putts = 2
    @Published var penalties = 0
    @Published var goodshots = 0
    @Published var drive: Drive = .other
    @Published var approach: Approach = .other
    @Published var sand = false

//    init() {}

    static func == (lhs: HoleScore, rhs: HoleScore) -> Bool {
        return lhs.strokes == rhs.strokes
        && lhs.putts == rhs.putts
        && lhs.penalties == rhs.penalties
        && lhs.goodshots == rhs.goodshots
        && lhs.drive == rhs.drive
        && lhs.approach == rhs.approach
        && lhs.sand == rhs.sand
    }

    func isSandDisabled() -> Bool {
        return approach == .other || approach == .green
    }

//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
}

final class PlayerScore : Identifiable, Equatable, ObservableObject {
    var id: UUID = UUID()
    @Published var name: String = ""
    @Published var hcpIndex: Double = .nan
    @Published var courseHcp: Int = 0

    init() {}

#if HOLE_SCORE_BUG
    var holescores: [HoleScore] = Array(repeating: HoleScore(), count: 18)
#else
    @Published var holescores: [HoleScore] = [HoleScore]()

    convenience init(holecount: Int) {
        self.init()
        var hs = [HoleScore]()
        for _ in 0..<holecount {
            hs.append(HoleScore())
        }
        self.holescores = hs
    }
#endif

    // Derived
    var outstrokes : Int {
        holescores[0..<9].reduce(0, {$0 + $1.strokes})
    }
    var instrokes : Int {
        holescores[9..<18].reduce(0, {$0 + $1.strokes})
    }
    var totalstrokes : Int {
        outstrokes + instrokes
    }
    var frontStrokeValues: [Int] {
        return holescores[0...8].map({$0.strokes})
    }
    var backStrokeValues: [Int] {
        return holescores[9...17].map({$0.strokes})
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
        let strokes = holescores[hole].strokes
        if strokes > 0 {
            let delta = tee.strokeHandicap(for: hole, handicap: courseHcp)
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
        let holescore = holescores[hole].strokes
        if holescore > 0 {
            let delta = tee.strokeHandicap(for: hole, handicap: courseHcp)
            let score = holescore - delta
            if score > 0 {
                return score
            } else {
                return .scoreIsZero
            }
        }
        return 0
    }

    func strokeHoleScore(hole: Int, tee: Tee) -> String {
        let holescore = holescores[hole].strokes
        if holescore > 0 {
            let delta = tee.strokeHandicap(for: hole, handicap: courseHcp)
            let score = holescore - delta
            if delta > 1 {
                return ":\(score)"
            } else if delta > 0 {
                return ".\(score)"
            }
            return "\(score)"
        }
        return ""
    }

    static func == (lhs: PlayerScore, rhs: PlayerScore) -> Bool {
        return lhs.name == rhs.name &&
        lhs.hcpIndex == rhs.hcpIndex &&
        lhs.courseHcp == rhs.courseHcp &&
        lhs.holescores == rhs.holescores
    }

}

extension HoleScore : Codable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case strokes = "Name"
        case putts
        case penalties
        case goodshots
        case drive
        case approach
        case sand
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(strokes, forKey: .strokes)
        try container.encode(putts, forKey: .putts)
        try container.encode(penalties, forKey: .penalties)
        try container.encode(goodshots, forKey: .goodshots)
        try container.encode(drive, forKey: .drive)
        try container.encode(approach, forKey: .approach)
        try container.encode(sand, forKey: .sand)
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        strokes = try values.decodeIfPresent(Int.self, forKey: .strokes) ?? 4
        putts = try values.decodeIfPresent(Int.self, forKey: .putts) ?? 2
        penalties = try values.decodeIfPresent(Int.self, forKey: .penalties) ?? 0
        goodshots = try values.decodeIfPresent(Int.self, forKey: .goodshots) ?? 0
        drive = try values.decodeIfPresent(Drive.self, forKey: .drive) ?? .other
        approach = try values.decodeIfPresent(Approach.self, forKey: .approach) ?? .other
        sand = try values.decodeIfPresent(Bool.self, forKey: .sand) ?? false
    }

}

extension HoleScore : CustomStringConvertible {
    var description: String {
        "Holescore id:\(id), st:\(strokes), pu:\(putts), pe:\(penalties), g:\(goodshots), d:\(drive.rawValue), a:\(approach.rawValue), sa:\(sand)"
    }
}

extension PlayerScore : Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case hcpIndex
        case courseHcp
        case holescores
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(hcpIndex, forKey: .hcpIndex)
        try container.encode(courseHcp, forKey: .courseHcp)
        try container.encode(holescores, forKey: .holescores)
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        hcpIndex = try values.decodeIfPresent(Double.self, forKey: .hcpIndex) ?? .nan
        courseHcp = try values.decodeIfPresent(Int.self, forKey: .courseHcp) ?? 0
        holescores = try values.decodeIfPresent([HoleScore].self, forKey: .holescores) ?? [HoleScore]()
    }
}

#if TEST_PLAYER_SCORE
// For testing purposes
extension PlayerScore {
    static func randomPlayers(tee: Tee) -> [PlayerScore] {
//        let names = ["a", "b", "cc", "d"]
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
        let playerscore = PlayerScore(holecount: 18)
//        let playerscore = PlayerScore(id: UUID(), name: name, hcp: hcp)
        playerscore.name = name
        playerscore.courseHcp = hcp
        assert(holes < 18)
        for box in 0...holes {
            let strokes = PlayerScore.randomStrokes()
            playerscore.holescores[box].strokes = tee.teeboxes[box].par + strokes
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
#endif

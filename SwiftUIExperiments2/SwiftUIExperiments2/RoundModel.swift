//
//  RoundModel.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/5/23.
//

import Foundation

enum RoundStatus: String, Codable {
    case new = "New"
    case incomplete = "Incomplete"
    case complete = "Complete"
    case submitted = "Submitted"
}

enum ScoringSystem: String, Codable {
    case stroke = "Stroke"
    case stableford = "Stableford"
    case par = "Par"
}

// See the DevNotes markdown file for thoughts on persistence

// Storing the data as a string could have issues. Users could have date presentation
// preferences. The reason that the Date struct is not inherently codable
// is that there are too many representations of a Date, and dates generally
// require a Calendar to be fully specified. Assuming a particular calendar, or date
// format is frowned on in the HIG.
//
// For simplicity, I'm choosing to ignore these issues and storing the date as
// a string. It can always be turned back into a date object.

// The date can be changed. What else can be changed after creating a round
// for scoring?
// Once the players are set, it's hard to imaging changing the players.
// It's possible someone could want to change the start hole or hole count
// before starting the actual scoring.
final class Round : Identifiable, Hashable, ObservableObject {

    var id: UUID
    var courseId: UUID
    var teeId: UUID
    var lastHoleIndexEdited: Int
    @Published var date: String
    @Published var players: [PlayerScore]
    @Published var startHole: Int          // one-based
    @Published var holeCount: Int
    @Published var scoringSystem: ScoringSystem
    @Published var status: RoundStatus

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    init() {
        self.id = UUID()
        self.lastHoleIndexEdited = 0
        self.date = Self.dateFormatter.string(from: Date.now)
        self.courseId = UUID()
        self.teeId = UUID()
        self.players = [PlayerScore]()
        self.startHole = 1
        self.holeCount = 18
        self.scoringSystem = .stroke
        self.status = .new
    }

    init(name: String, hcpIndex: Double, course: Course, tee: Tee) {
        self.id = UUID()
        self.lastHoleIndexEdited = 0
        self.date = Self.dateFormatter.string(from: Date.now)
        self.courseId = course.id
        self.teeId = tee.id
        self.players = [PlayerScore(holecount: course.holes)]
        self.startHole = 1
        self.holeCount = course.holes
        self.scoringSystem = .stroke
        self.status = .incomplete
        players[0].name = name
        players[0].hcpIndex = hcpIndex
        players[0].courseHcp = tee.playerCourseHandicap(hcpIndex: hcpIndex)
    }

    func adjustPlayers(count: Int) {
        if count > 0 && count < 5 {
            if count > players.count {
//                var playersA = players
                for _ in players.count ..< count {
                    self.players.append(PlayerScore(holecount: self.holeCount))
                }
//                self.players = playersA
            } else if count < players.count {
                self.players.removeLast(players.count - count)
            }
        }
    }

    static func == (lhs: Round, rhs: Round) -> Bool {
        return lhs.date == rhs.date &&
        lhs.courseId == rhs.courseId &&
//        lhs.lastHoleIndexEdited == rhs.lastHoleIndexEdited &&
        lhs.teeId == rhs.teeId &&
        lhs.players == rhs.players &&
        lhs.startHole == rhs.startHole &&
        lhs.holeCount == rhs.holeCount &&
        lhs.scoringSystem == rhs.scoringSystem &&
        lhs.status == rhs.status
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Round : Codable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case lastHoleIndexEdited = "editIndex"
        case courseId = "courseId"
        case teeId = "teeId"
        case date = "date"
        case players = "players"
        case startHole = "startHole"
        case holeCount = "holeCount"
        case scoringSystem = "scoringSystem"
        case status = "status"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(lastHoleIndexEdited, forKey: .lastHoleIndexEdited)
        try container.encode(courseId, forKey: .courseId)
        try container.encode(teeId, forKey: .teeId)
        try container.encode(date, forKey: .date)
        try container.encode(players, forKey: .players)
        try container.encode(startHole, forKey: .startHole)
        try container.encode(holeCount, forKey: .holeCount)
        try container.encode(scoringSystem, forKey: .scoringSystem)
        try container.encode(status, forKey: .status)
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.lastHoleIndexEdited = try values.decodeIfPresent(Int.self, forKey: .lastHoleIndexEdited) ?? 0
        self.date = try values.decodeIfPresent(String.self, forKey: .date) ?? Self.dateFormatter.string(from: Date.now)
        self.courseId = try values.decodeIfPresent(UUID.self, forKey: .courseId) ?? UUID()
        self.teeId = try values.decodeIfPresent(UUID.self, forKey: .teeId) ?? UUID()
        self.players = try values.decodeIfPresent([PlayerScore].self, forKey: .players) ?? [PlayerScore]()
        self.startHole = try values.decodeIfPresent(Int.self, forKey: .startHole) ?? 1
        self.holeCount = try values.decodeIfPresent(Int.self, forKey: .holeCount) ?? 18
        self.scoringSystem = try values.decodeIfPresent(ScoringSystem.self, forKey: .scoringSystem) ?? .stroke
        self.status = try values.decodeIfPresent(RoundStatus.self, forKey: .status) ?? .incomplete
    }
}


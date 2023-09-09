//
//  CourseModel.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import Foundation

// DO NOT create id in the constructor.
// Structs use copy semantics and all copies must have the same id value.
struct Teebox: Identifiable, Hashable, Codable {
    let id: UUID
    let hole: Int
    var par: Int
    var hcp: Int

    init(id: UUID, hole: Int, par: Int, hcp: Int) {
        self.id = id
        self.hole = hole
        self.par = par
        self.hcp = hcp
    }
}

struct Tee: Identifiable, Hashable, Codable {
    let id: UUID
    var color: String
    var rating: Double
    var slope: Int
    var yardage: Int
    var teeboxes: [Teebox]

    init(id: UUID, holes: Int) {
        self.id = id
        self.color = ""
        self.teeboxes = [Teebox]()
        self.rating = 0
        self.slope = 0
        self.yardage = 0
        for index in 0..<holes {
            teeboxes.append(Teebox(id: UUID(), hole: index+1, par: 4, hcp: index))
        }
    }
}

final class Course: Identifiable, Hashable, Codable, ObservableObject {
    var id: UUID = UUID()
    @Published var name: String = ""
    @Published var holes: Int = 18
    @Published var tees: [Tee] = [Tee]()

    init(name: String, holes: Int) {
        self.name = name
        self.holes = holes
        tees = [Tee]()
    }

    func addTee() {
        tees.append(Tee(id: UUID(), holes: self.holes))
        tees.forEach({print("tee id \($0.id)")})
    }

    func updateTee(tee: Tee) {
        // arrays and tees have value semantics, must use an index into the array
        if let index = tees.firstIndex(where:{$0.id == tee.id}) {
            tees[index] = tee
        } else {
            // this should not happen since setTeeColor is sent from the Tee detail view where there is a Tee value
            // but be defensive
            print("Error, attempting to update Tee data in course \(self.name) for non-existing Tee with id \(tee.id)")
        }
    }

    func deleteTee(teeid: UUID) {
        // find the tee
        if let index = tees.firstIndex(where:{$0.id == teeid}) {
            tees.remove(at: index)
        } else {
            // this should not happen since setTeeColor is sent from the Tee detail view where there is a Tee value
            // but be defensive
            print("Error, attempting to remove a Tee in course \(self.name) for non-existing Tee with id \(teeid)")
        }
    }

    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.name.caseInsensitiveCompare(rhs.name) == .orderedSame &&
        lhs.holes == rhs.holes &&
        lhs.tees.elementsEqual(rhs.tees)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(holes)
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
        case holes
        case tees
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(holes, forKey: .holes)
        try container.encode(tees, forKey: .tees)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(UUID.self, forKey: .id)!
        self.name = try values.decodeIfPresent(String.self, forKey: .name)!
        self.holes = try values.decodeIfPresent(Int.self, forKey: .holes)!
        self.tees = try values.decodeIfPresent([Tee].self, forKey: .tees)!
    }
}

class CourseModel: ObservableObject {
    @Published var courses: [Course] = []

    func addCourse(_ course: Course) {
        print("Adding course \(course.name)")
        courses.append(course)
    }

    func deleteCourse(_ course: Course) {
        print("Deleting course \(course.name)")
        courses.removeAll(where: { $0.id == course.id })
    }

    func refresh() {
        objectWillChange.send()
    }
}

//
//  CourseModel.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import Foundation

struct Tee: Identifiable, Hashable, Codable {
    let id: UUID
    var color: String
    var pars: [Int]
    var holeHcp: [Int]
    var rating: Double
    var slope: Int
    var yardage: Int

    init(holes: Int) {
        self.id = UUID()
        self.color = "White"
        self.pars = Array(repeating: 4, count: holes)
        self.holeHcp = Array(1...holes)
        self.rating = 0
        self.slope = 0
        self.yardage = 0
    }
}

let defaultHcp9 = [1,2,3,4,5,6,7,8,9]
let defaultHcp18 = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]

final class Course: Identifiable, Hashable, Codable {
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
        tees.append(Tee(holes: self.holes))
    }

    func setTeeColor(teeid: UUID, color: String) {
        // arrays and tees have value semantics, must use an index into the array
        if let index = tees.firstIndex(where:{$0.id == teeid}) {
            tees[index].color = color
        } else {
            // this should not happen since setTeeColor is sent from the Tee detail view where there is a Tee value
            // but be defensive
            print("Error, attempting to set tee color for non-existing Tee with id \(teeid)")
        }
    }

    func deleteTee(color: String) {

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

class CourseModel {
    @Published var courses: [Course] = []

    func addCourse(_ course: Course) {
        print("Adding course \(course.name)")
        courses.append(course)
    }

    func deleteCourse(_ course: Course) {
        print("Deleting course \(course.name)")
        courses.removeAll(where: { $0.id == course.id })
    }
}

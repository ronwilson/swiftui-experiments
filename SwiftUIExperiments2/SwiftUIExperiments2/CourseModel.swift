//
//  CourseModel.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import Foundation

// For these two Struct objects, DO NOT create id in the initializer.
// I.e., don't do this: let id: UUID = UUID()
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

// If Tees had a variable number of Teebox's in the teeboxes array,
// then this object should arguably be an ObservableObject like the Course.
// (So that changes to the teeboxes array would be propagated to Views that
// are observing a Tee.)
struct Tee: Identifiable, Hashable, Codable {
    let id: UUID
    var color: String
    var rating: Double
    var slope: Int
    var teeboxes: [Teebox]
    var par: Int {
        return teeboxes.reduce(0, {$0 + $1.par})
    }
    static private let hcp18odd: [Int] = [1,3,5,7,9,11,13,15,17,2,4,6,8,10,12,14,16,18]
    static private let hcp18even: [Int] = [2,4,6,8,10,12,14,16,18,1,3,5,7,9,11,13,15,17]
    static private let hcp9: [Int] = [1,2,3,4,5,6,7,8,9]

    init(id: UUID, holes: Int, oddHcp: Bool) {
        self.id = id
        self.color = "Color"
        self.teeboxes = [Teebox]()
        self.rating = 0
        self.slope = 0
        for index in 0..<holes {
            teeboxes.append(Teebox(id: UUID(), hole: index+1, par: 4, hcp: holes > 9 ? oddHcp ? Tee.hcp18odd[index] : Tee.hcp18even[index] : Tee.hcp9[index]))
        }
    }

    mutating func holesChanged(holes: Int) {
        self.teeboxes = [Teebox]()
        for index in 0..<holes {
            teeboxes.append(Teebox(id: UUID(), hole: index+1, par: 4, hcp: index))
        }
    }
}

// Make the Course a class so it can be observable. This makes it easier and more
// natural to pass a course to a multiple views.
final class Course: Identifiable, Hashable, Codable /*, NSCopying*/, ObservableObject {
    // id doesn't need to be published because it won't ever be changed. It is not private, so it can be displayed.
    var id: UUID = UUID()
    // publish the attributes that can be changed
    @Published var name: String = ""
    @Published var holes: Int = 18
    @Published var front9OddHcp: Bool = true
    @Published var tees: [Tee] = [Tee]()
    @Published var teesEdited: Bool = false

    init(name: String, holes: Int) {
        self.name = name
        self.holes = holes
        tees = [Tee]()
    }

    // Called from the Course Detail View when the user taps the '+' add tee button.
    // The Course Detail View is 'observing' the courses which are Observalble objects.
    // When this function appends a new Tee to the tees array, the Course Detail View will
    // receive notification through the Combine Publish-Subscribe mechanism that is automatically
    // set up in the Course Detail View object. The result is that the list of Tees
    // in the Course Detail View will be updated and re-drawn.
    func addTee() {
        tees.append(Tee(id: UUID(), holes: self.holes, oddHcp: self.front9OddHcp))
        //tees.forEach({print("tee id \($0.id)")})
    }

    // Called from the Tee List View. That view has a reference to the Course so that it can call
    // this function to delete a Tee (by Tee.id).
    // Like the addTee function, the modification of the tees array here will automatically trigger
    // a notification and the re-drawing of the Tees list in the Course Detail View.
    func deleteTee(teeid: UUID) {
        // find the tee
        if let index = tees.firstIndex(where:{$0.id == teeid}) {
            tees.remove(at: index)
            if tees.isEmpty {
                teesEdited = false
            }
        } else {
            // this should not happen since setTeeColor is sent from the Tee detail view where there is a Tee value
            // but be defensive because other programming errors could cause the Tee.id to change.
            print("Error, attempting to remove a Tee in course \(self.name) for non-existing Tee with id \(teeid)")
        }
    }

    // Called from multiple locations in views that edit Tee data. Since Tees are Structs, any change
    // to data in a Tee must be forwarded to the Course in a way that the Course can replace it's
    // copy of the Tee with that id value with the incoming edited Tee data.
    func updateTee(tee: Tee) {
        // arrays and tees have value semantics, must use an index into the array
        if let index = tees.firstIndex(where:{$0.id == tee.id}) {
            tees[index] = tee
            teesEdited = true
//            print("Tee updated in course, index:\(index), tee:\(tee)")
        } else {
            // this should not happen since updateTee is sent from the Tee detail view where it's guaranteed
            // that there is a Tee. However, it did happen. The reason was that a Tee's id value changed
            // because originally, the id value was assigned automatically in the initializer. This is
            // why I changed the Tee Struct to take an external ID value in the initializer.
            print("Error, attempting to update Tee data in course \(self.name) for non-existing Tee with id \(tee.id)")
        }
    }

    func recreateTees() {
        let teecount = tees.count
        tees.removeAll()
        for _ in 0..<teecount {
            addTee()
        }
    }

    // required functions to satisfy the protocol requirements for this class

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
        case teesEdited
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(holes, forKey: .holes)
        try container.encode(tees, forKey: .tees)
        try container.encode(teesEdited, forKey: .teesEdited)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? "Course"
        self.holes = try values.decodeIfPresent(Int.self, forKey: .holes) ?? 18
        self.tees = try values.decodeIfPresent([Tee].self, forKey: .tees) ?? [Tee]()
        self.teesEdited = try values.decodeIfPresent(Bool.self, forKey: .teesEdited) ?? false
    }
}

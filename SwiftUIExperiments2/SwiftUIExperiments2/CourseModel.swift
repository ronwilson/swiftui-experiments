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

    init(id: UUID, holes: Int) {
        self.id = id
        self.color = ""
        self.teeboxes = [Teebox]()
        self.rating = 0
        self.slope = 0
        for index in 0..<holes {
            teeboxes.append(Teebox(id: UUID(), hole: index+1, par: 4, hcp: index))
        }
    }
}

// Make the Course a class so it can be observable. This makes it easier and more
// natural to pass a course to a multiple views.
final class Course: Identifiable, Hashable, Codable, ObservableObject {
    // id doesn't need to be published because it won't ever be changed. It is not private, so it can be displayed.
    var id: UUID = UUID()
    // publish the attributes that can be changed
    @Published var name: String = ""
    @Published var holes: Int = 18
    @Published var tees: [Tee] = [Tee]()

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
        tees.append(Tee(id: UUID(), holes: self.holes))
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
        } else {
            // this should not happen since updateTee is sent from the Tee detail view where it's guaranteed
            // that there is a Tee. However, it did happen. The reason was that a Tee's id value changed
            // because originally, the id value was assigned automatically in the initializer. This is
            // why I changed the Tee Struct to take an external ID value in the initializer.
            print("Error, attempting to update Tee data in course \(self.name) for non-existing Tee with id \(tee.id)")
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

// this top-levl model class is required only so that there is a convenient way
// to Observe changes in the courses array.
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

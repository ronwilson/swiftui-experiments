//
//  CourseViewModel.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import Foundation
import UIKit


class CourseViewModel: ObservableObject {

    @Published var courseModel =  CourseModel()

    var courses: [Course] {
        return courseModel.courses
    }

    init(courseModel: CourseModel = CourseModel()) {
        NSLog("CourseViewModel init");
        self.courseModel = courseModel
    }

    func addCourse(_ course: Course){
        courseModel.addCourse(course)
    }

    func setCourseName(_ id: UUID, name: String) {
        courseModel.setCourseName(id: id, name:name)
        objectWillChange.send()
    }

    func deleteCourse(course: Course) {
        courseModel.deleteCourse(course)
        objectWillChange.send()
    }

//    func deleteTee(course: Course, ) {
//        courseModel.deleteCourse(course)
//        objectWillChange.send()
//    }

}

//
//  CourseDetailView.swift
//  SwiftUIExperiments
//
//  Created by Ron on 9/6/23.
//

import SwiftUI

struct CourseDetailView: View {
    // model does not need to be an @ObservedObject because there's nothing on
    // this view that depends on changes in the courseModel. The only reason to have
    // courseModel here is so that when a course name is changed, we can trigger an
    // update in the CourseView.
    let model: ContentViewModel
    // course needs to be observed so that changes in the list of Tees for the course
    // will cause automatic updates for the List(course.tees) below.
    @ObservedObject var course: Course
    @State private var holestag = 0
    @State private var showingPopover = false

    init(model: ContentViewModel, course: Course, holestag: Int = 0) {
        self.model = model
        self.course = course
        _holestag = State(initialValue: course.holes == 18 ? 0 : 1)
    }

    var body: some View {
        Self._printChanges()
        return VStack {
            // This can be commented out. There's no functional reason to display the id value
//            HStack {
//                Text("Course Id:")
//                Text("\(course.id)")
//            }
            //Section(header: Text("Course Data")) {
            Section() {
                HStack {
                    Text("Course Name:")
                    TextField("Course name:", text: $course.name)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            print("Course name is now \(course.name)")
                            // This will trigger an update of the CourseModel to refresh the course names in the CourseView.
                            //model.courseUpdated()
                        }
                }
                HStack {
                    VStack {
                        HStack {
                            Text("Number of Holes:")
                            Picker("Holes", selection: $holestag) {
                                Text("18").tag(0)
                                Text("9").tag(1)
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: holestag) { value in
                                if value == 0 {
                                    course.holes = 18
                                } else {
                                    course.holes = 9
                                }
                                refreshTees()
                            }
                        }
                        .disabled(course.teesEdited)
                        HStack {
                            Toggle(isOn: $course.front9OddHcp) {
                                Text("Front Nine has Odd Handicaps")
                            }
                            .onChange(of: course.front9OddHcp) { _ in
                                refreshTees()
                            }
                        }
                        .disabled(course.teesEdited)
                    }
                    .popover(isPresented: $showingPopover) {
                        Text("The number of holes and handicap order cannot be changed because one or more Tee has non-default values. To change the hole count or handicap ordering, delete then re-add the Tees.")
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(minWidth: 300, minHeight: 150)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                    }
                    if course.teesEdited {
                        Button {
                            showingPopover = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
            Section(header: Text("Tees")) {
                // The list of Tees for the Course. This list and the delete swipe action work the
                // same as in the CourseView.
                List(course.tees) { tee in
                    NavigationLink(value: tee) {
                        Text("\(tee.color)")
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive, action: { course.deleteTee(teeid: tee.id) } ) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .listStyle(.plain)
                .navigationDestination(for: Tee.self) { tee in
                    // Navigate to the TeeView
                    TeeView(course: course, tee: tee)
                }
            }
        }
        .padding()
        .navigationTitle("Course")
        .navigationBarTitleDisplayMode(.inline)
        // Put a "Add Tee" button on the toolbar
        .toolbar {
            Button(action: {
                course.addTee()
            }) {
                Image(systemName: "plus")
                Text("Tee")
            }
        }
    }

    // The purpose of this function is to refresh the teebox list for any Tees that do not have the same
    // number of teeboxes as the course has holes. This is called whenever the user changes the number of
    // holes for the course.
    private func refreshTees() {
        course.recreateTees()
    }
}

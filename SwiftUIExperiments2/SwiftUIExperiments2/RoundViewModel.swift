//
//  RoundsViewModel.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/6/23.
//

import SwiftUI

class LoadableRounds: LoadableObject {
    @Published var state: LoadingValueState<[Round]> = LoadingValueState<[Round]>.idle
    typealias Output = [Round]
    @Published var rounds: [Round] = [Round]()
    func load() {
        PersistenceManager.shared.loadRounds(self)
    }
    func loaded(value: [Round]?, error: Error?) {
        // rounds must now be resolved to get the course and tee
        Task {
            await loadingComplete(value, error:error)
        }
    }
    @MainActor func loadingComplete(_ rounds: [Round]?, error: Error?) {
        if let roundsA = rounds {
            print("Rounds loaded, count = \(roundsA.count)")
            self.state = .loaded(roundsA)
        } else if let err = error {
            print("Rounds loading failed: \(err.localizedDescription)")
            self.state = .failed(err, [Round]())
        } else {
            fatalError("Rounds Loading error: rounds array is nil and error is nil")
        }
    }
}

// Required to create
// 1. Loaded Rounds
//      The stored Rounds contain the courses and tee Ids only
// 2. Loaded Coursess
//      The course model and tee model must be found from
//      the respective Ids in the Round model
//      The full Course and Tee definition are needed to populate the controls
//      in the Rounds View
struct RoundViewModel: Identifiable, Hashable {
    let id: UUID
    var round: Round        // need this to be a var so that bindings to change the round data will work
    let course: Course
    let tee: Tee

    func hash(into hasher: inout Hasher) {
        hasher.combine(round.id)
        hasher.combine(course.id)
        hasher.combine(tee.id)
    }
}

final class RoundsViewModel: ObservableObject {

    @Published var rounds: LoadableRounds = LoadableRounds()
    var changesPending: Bool = false

    func addRound(_ round: RoundViewModel) {
        //var changeState = false
        var updatedRounds : [Round]? = nil

        switch rounds.state {
        case .idle, .loading:
            print("addRound called when state is \(rounds.state)")
        case .failed(_,let roundsA):
            print("Adding round \(round.round.id)")
//            roundsA.append(round.round)
            //changeState = true
            updatedRounds = roundsA
//            rounds.state = .loaded(roundsA)
        case .loaded(let roundsA):
            print("Adding round \(round.round.id)")
            //roundsA.append(round.round)
            updatedRounds = roundsA
//            changeState = true
//            rounds.state = .loaded(roundsA)
        }
        if var roundsAA = updatedRounds  {
            roundsAA.append(round.round)
            rounds.state = .loaded(roundsAA)
        }
        // always save the model
        changesPending = true
    }

    func deleteRound(_ id: UUID) {
        if case var .loaded(roundsA) = rounds.state {
            print("Deleting round id \(id)")
            roundsA.removeAll(where: { $0.id == id })
            rounds.state = .loaded(roundsA)
        } else {
            print("deleteRound called when state is \(rounds.state)")
        }
        // always save the model
        changesPending = true
    }
}

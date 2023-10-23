//
//  RoundsViewModel.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/6/23.
//

import SwiftUI

// A "loadable" object wrapping the Rounds data
class LoadableRounds: LoadableObject {
    @Published var state: LoadingValueState<[Round]> = LoadingValueState<[Round]>.idle
    typealias Output = [Round]

    func load() {
        PersistenceManager.shared.loadRounds(self)
    }

    func loaded(value: [Round]?, error: Error?) {
        // rounds must now be resolved to get the course and tee
        Task {
            await loadingComplete(value, error:error)
        }
    }

    // this needs to run on the main thread because it updates the state that is
    // bound to Views
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

// The top-level data model for Rounds
// This is a view model to provide functions useful to views.
// It encapsulates the rounds data as a LoadableRounds object.
final class RoundsViewModel: ObservableObject {

    @Published var rounds: LoadableRounds = LoadableRounds()
    var changesPending: Bool = false

    func addRound(_ round: Round) {
        switch rounds.state {
        case .idle, .loading:
            print("addRound called when state is \(rounds.state)")
        case .failed(_,var roundsA):
            print("Adding round \(round.id)")
            roundsA.append(round)
            rounds.state = .loaded(roundsA)
        case .loaded(var roundsA):
            print("Adding round \(round.id)")
            roundsA.append(round)
            rounds.state = .loaded(roundsA)
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

    func round(withId id: UUID) -> Round? {
        if case let .loaded(roundA) = rounds.state {
            return roundA.first(where: { $0.id == id })
        }
        return nil
    }

}

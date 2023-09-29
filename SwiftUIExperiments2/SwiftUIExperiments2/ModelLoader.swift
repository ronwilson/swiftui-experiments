//
//  ModelLoader.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/26/23.
//

import Foundation

enum LoadingState {
    case idle
    case loading
    case failed(Error)
    case loaded
}

enum LoadingValueState<Value> {
    case idle
    case loading
    case failed(Error, Value)
    case loaded(Value)

    var stateString: String {
        switch self {
        case .idle:
            return "idle"
        case .loading:
            return "loading"
        case .failed(_,_):
            return "failed"
        case .loaded(_):
            return "loaded"
        }
    }
    var stateValue: Int {
        switch self {
        case .idle:
            return 0
        case .loading:
            return 1
        case .failed(_,_):
            return 2
        case .loaded(_):
            return 3
        }
    }
}

protocol LoadableObject: ObservableObject {
    associatedtype Output
    var state: LoadingValueState<Output> { get }
    func load()
}




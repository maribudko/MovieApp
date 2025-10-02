//
//  MoviesErrors.swift
//  MovieApp
//
//  Created by Mari Budko on 30.09.2025.
//

import Foundation

enum MoviesErrors: Error {
    case offline
    case http(Int)
    case decoding
    case unknown(Error)
    
    var userMessage: String {
        switch self {
        case .offline:
            return L10n.Error.offline
        case .http(let code):
            return L10n.Error.http(code)
        case .decoding:
            return L10n.Error.decoding
        case .unknown:
            return L10n.Error.unknown
        }
    }
    
    var isOffline: Bool { if case .offline = self { return true } else { return false } }
}

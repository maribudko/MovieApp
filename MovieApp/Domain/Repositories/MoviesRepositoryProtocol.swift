//
//  MoviewRepositoryProtocol.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Foundation

protocol MoviesRepositoryProtocol {
    func fetchMovies(page: Int, query: String?, sort: SortOption?, genres: [Int]?) async throws -> MoviesPage
    func fetchDetails(id: Int) async throws -> Movie
}

enum SortOption: String, Codable {
    case popularityDesc
    case ratingDesc
    case releaseDateDesc
    
    var apiValue: String {
        switch self {
        case .popularityDesc: return "popularity.desc"
        case .ratingDesc: return "vote_average.desc"
        case .releaseDateDesc: return "primary_release_date.desc"
        }
    }
}

//
//  MoviewRepositoryProtocol.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Foundation

protocol MovieRepositoryProtocol {
    func fetchMovies(page: Int, query: String?, sort: SortOption?, genres: [Int]?) async throws -> MoviesPage
    func fetchDetails(id: Int) async throws -> Movie
}

enum SortOption: String, Codable {
    case popularityDesc
    case ratingDesc
    case releaseDateDesc
}

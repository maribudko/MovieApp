//
//  Movie.swift
//  MovieApp
//
//  Created by Mari Budko on 30.09.2025.
//

import Foundation

struct Movie: Equatable, Hashable {
    let id: Int
    let title: String
    let overview: String?
    let releaseDate: Date?
    let rating: Double?
    let posterPath: String?
}

struct MoviesPage {
    let page: Int
    let totalPages: Int
    let items: [Movie]
}

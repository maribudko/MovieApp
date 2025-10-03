//
//  MovieCardViewItem.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Foundation

struct MovieViewItem: Hashable, Sendable {
    let id: Int
    let title: String
    let genres: String
    let ratingText: String
    let yearText: String
    let posterPath: String?
    let backdropPath: String?
}

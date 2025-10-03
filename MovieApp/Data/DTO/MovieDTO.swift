//
//  MovieDTO.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Foundation

struct MovieDTO: Codable {
    let id: Int
    let title: String
    let overview: String?
    let poster_path: String?
    let backdrop_path: String?
    let release_date: String?
    let vote_average: Double?
}

struct PagedResponse<T: Codable>: Codable {
    let page: Int
    let total_pages: Int
    let results: [T]
}

//
//  MovieMapping.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Foundation

enum MovieMapper {
    static func map(_ dto: MovieDTO) -> Movie {
        Movie(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            releaseDate: date(from: dto.release_date),
            rating: dto.vote_average,
            posterPath: dto.poster_path,
            backdropPath: dto.backdrop_path
        )
    }
    
    static func mapPage(_ dto: PagedResponse<MovieDTO>) -> MoviesPage {
        MoviesPage(
            page: dto.page,
            totalPages: dto.total_pages,
            items: dto.results.map { map($0) }
        )
    }
    
    static func date(from s: String?) -> Date? {
        guard let s else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = .init(identifier: "en_US_POSIX")
        return formatter.date(from: s)
    }
}


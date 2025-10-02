//
//  MovieRepository.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Foundation

final class MoviesRepository: MoviesRepositoryProtocol {
    private let api: MoviesAPIProtocol
    
    init(api: MoviesAPIProtocol) {
        self.api = api
    }
    
    func fetchMovies(page: Int, query: String?, sort: SortOption?, genres: [Int]?) async throws -> MoviesPage {
        if let query = query?.trimmingCharacters(in: .whitespacesAndNewlines), query.isEmpty == false {
            let dto: PagedResponse<MovieDTO> = try await api.get(.search(query: query, page: page))
            return MovieMapper.mapPage(dto)
        }
        
        let dto: PagedResponse<MovieDTO> = try await api.get(.discover(page: page, sort: sort, genres: genres))
        return MovieMapper.mapPage(dto)
    }
    
    func fetchDetails(id: Int) async throws -> Movie {
        let dto: MovieDTO = try await api.get(.details(id: id))
        return MovieMapper.map(dto)
    }
}

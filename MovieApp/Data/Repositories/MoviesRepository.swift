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
    
    func fetchMovies(
        page: Int,
        query: String?,
        sort: SortOption?,
        genres: [Int]?,
        completion: @escaping (Result<MoviesPage, MoviesErrors>) -> Void
    ) {
        if let query = query?.trimmingCharacters(in: .whitespacesAndNewlines), query.isEmpty == false {
            api.get(.search(query: query, page: page)) { (result: Result<PagedResponse<MovieDTO>, MoviesErrors>) in
                switch result {
                case .success(let dto):
                    completion(.success(MovieMapper.mapPage(dto)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            api.get(.discover(page: page, sort: sort, genres: genres)) { (result: Result<PagedResponse<MovieDTO>, MoviesErrors>) in
                switch result {
                case .success(let dto):
                    completion(.success(MovieMapper.mapPage(dto)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchDetails(id: Int, completion: @escaping (Result<Movie, MoviesErrors>) -> Void) {
        api.get(.details(id: id)) { (result: Result<MovieDTO, MoviesErrors>) in
            switch result {
            case .success(let dto):
                completion(.success(MovieMapper.map(dto)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

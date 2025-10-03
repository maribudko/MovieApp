//
//  MovieAPIProtocol.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Foundation

protocol MoviesAPIProtocol {
    func get<T: Codable>(_ endpoint: MovieEndpoint, completion: @escaping (Result<T, MoviesErrors>) -> Void)
}

enum MovieEndpoint {
    case discover(page: Int, sort: SortOption?, genres: [Int]?)
    case search(query: String, page: Int)
    case details(id: Int)
    
    var path: String {
        switch self {
        case .discover: return "/discover/movie"
        case .search:   return "/search/movie"
        case .details(let id): return "/movie/\(id)"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .discover(let page, let sort, let genres):
            var items = [URLQueryItem(name: "page", value: "\(page)")]
            if let sort = sort {
                items.append(.init(name: "sort_by", value: sort.apiValue))
            }
            if let genres, !genres.isEmpty {
                items.append(.init(name: "with_genres", value: genres.map(String.init).joined(separator: ",")))
            }
            return items
            
        case .search(let query, let page):
            return [
                .init(name: "query", value: query),
                .init(name: "page", value: "\(page)")
            ]
            
        case .details:
            return []
        }
    }
}

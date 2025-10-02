//
//  TMDbAPIClient.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Foundation
import Alamofire

final class TMDbAPIClient: MoviesAPIProtocol {
    private let session: Session
    private let baseURL = "https://api.themoviedb.org/3"
    private let decoder: JSONDecoder
    
    init(apiKey: String) {
        let interceptor = TMDbRequestInterceptor(apiKey: apiKey)
        self.session = Session(interceptor: interceptor)
        let decoder = JSONDecoder()
        // d.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }
    
    func get<T: Codable>(_ endpoint: MovieEndpoint) async throws -> T {
        let url = baseURL + endpoint.path
        let params = Dictionary(uniqueKeysWithValues: endpoint.queryItems.map { ($0.name, $0.value ?? "") })
        
        do {
            let value: T = try await session.request(
                url,
                method: .get,
                parameters: params,
                encoding: URLEncoding.default
            )
                .validate(statusCode: 200..<300)
                .serializingDecodable(T.self, decoder: decoder)
                .value
            
            return value
            
        } catch let afError as AFError {
            if afError.isSessionTaskError,
               let urlError = afError.underlyingError as? URLError,
               urlError.code == .notConnectedToInternet {
                throw MoviesErrors.offline
            }
            if case let .responseValidationFailed(reason) = afError,
               case let .unacceptableStatusCode(code) = reason {
                throw MoviesErrors.http(code)
            }
            if case .responseSerializationFailed = afError {
                throw MoviesErrors.decoding
            }
            throw MoviesErrors.unknown(afError)
        } catch {
            throw MoviesErrors.unknown(error)
        }
    }
}

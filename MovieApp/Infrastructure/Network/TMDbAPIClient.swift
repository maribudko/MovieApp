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
        self.decoder = decoder
    }
    
    func get<T: Codable>(_ endpoint: MovieEndpoint, completion: @escaping (Result<T, MoviesErrors>) -> Void) {
        let url = baseURL + endpoint.path
        let params = Dictionary(uniqueKeysWithValues: endpoint.queryItems.map { ($0.name, $0.value ?? "") })
        
        session.request(url, method: .get, parameters: params, encoding: URLEncoding.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self, decoder: decoder) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    if error.isSessionTaskError,
                       let urlError = error.underlyingError as? URLError,
                       urlError.code == .notConnectedToInternet {
                        completion(.failure(.offline))
                        return
                    }
                    if case let .responseValidationFailed(reason) = error,
                       case let .unacceptableStatusCode(code) = reason {
                        completion(.failure(.http(code)))
                        return
                    }
                    if case .responseSerializationFailed = error {
                        completion(.failure(.decoding))
                        return
                    }
                    completion(.failure(.unknown(error)))
                    
                }
            }
    }
}

//
//  TMDbRequestInterceptor.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Foundation
import Alamofire

final class TMDbRequestInterceptor: RequestInterceptor {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        guard let url = urlRequest.url,
              var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return completion(.success(urlRequest))
        }
        var items = comps.queryItems ?? []
        items.append(URLQueryItem(name: "api_key", value: apiKey))
        items.append(URLQueryItem(name: "language", value: "en-US"))
        items.append(URLQueryItem(name: "include_adult", value: "false"))
        comps.queryItems = items
        
        var req = urlRequest
        req.url = comps.url
        completion(.success(req))
    }
    
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        if let status = request.response?.statusCode,
           (500...599).contains(status),
           request.retryCount < 2 {
            let delay = pow(2.0, Double(request.retryCount)) * 0.5 // 0.5s, 1s
            completion(.retryWithDelay(delay))
        } else {
            completion(.doNotRetry)
        }
    }
    
}

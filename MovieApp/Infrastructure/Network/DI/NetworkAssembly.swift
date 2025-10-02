//
//  NetworkAssembly.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Swinject

final class NetworkAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MoviesAPIProtocol.self) { _ in
            let key = Secrets.tmdbApiKey
            return TMDbAPIClient(apiKey: key)
        }
        .inObjectScope(.container)
    }
}

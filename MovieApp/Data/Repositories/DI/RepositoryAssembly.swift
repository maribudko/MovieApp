//
//  RepositoryAssembly.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Swinject

final class RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MoviesRepositoryProtocol.self) { resolver in
            guard let api = resolver.resolve(MoviesAPIProtocol.self) else {
                fatalError("MoviesAPIProtocol is not registered")
            }
            return MoviesRepository(api: api)
        }
    }

}

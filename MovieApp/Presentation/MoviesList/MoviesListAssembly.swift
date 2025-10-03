//
//  MoviesListAssembly.swift
//  MovieApp
//
//  Created by Mari Budko on 03.10.2025.
//

import Swinject
final class MoviesListAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MoviesListPresenting.self) { resolver in
            MoviesListPresenter(
                repo: resolver.resolve(MoviesRepositoryProtocol.self)!,
                reachability: resolver.resolve(ReachabilityServiceProtocol.self)!
            )
        }

        container.register(MovieListViewController.self) { resolver in
            let presenter = resolver.resolve(MoviesListPresenting.self)!
            let vc = MovieListViewController()
            vc.presenter = presenter
            presenter.attach(view: vc)
            return vc
        }
    }
}

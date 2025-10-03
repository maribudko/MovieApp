//
//  MoviesListPresenting.swift
//  MovieApp
//
//  Created by Mari Budko on 03.10.2025.
//

import Foundation

protocol MoviesListPresenting: AnyObject {
    func attach(view: MoviesListView)
    func viewDidLoad()
    func didPullToRefresh()
    func search(query: String)
    func availableSortOptions() -> [SortDisplayOption]
    func isCurrentSort(_ opt: SortDisplayOption) -> Bool
    func didSelectSort(_ opt: SortDisplayOption)
    func loadNextPageIfNeeded(visibleIndex: Int)
    func didSelectItem(at index: Int)
}

struct SortDisplayOption: Equatable {
    let title: String
    let sort: SortOption

    static let popularityDesc  = SortDisplayOption(title: "Popularity ↓",   sort: .popularityDesc)
    static let voteAverageDesc = SortDisplayOption(title: "Rating ↓",       sort: .ratingDesc)
    static let releaseDateDesc = SortDisplayOption(title: "Release date ↓", sort: .releaseDateDesc)
}

final class MoviesListPresenter: MoviesListPresenting {

    private weak var view: MoviesListView?
    private let repo: MoviesRepositoryProtocol
    private let reachability: ReachabilityServiceProtocol

    private var page = 0
    private var totalPages = 1
    private var movies: [Movie] = []
    private var query: String?
    private var sort: SortOption = .popularityDesc

    init(repo: MoviesRepositoryProtocol,
         reachability: ReachabilityServiceProtocol) {
        self.repo = repo
        self.reachability = reachability
    }

    // MARK: Lifecycle

    func attach(view: MoviesListView) {
        self.view = view
    }

    func viewDidLoad() {
        loadFirstPage()
    }

    func didPullToRefresh() {
        loadFirstPage()
    }

    // MARK: User actions

    func search(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        self.query = trimmed.isEmpty ? nil : trimmed
        loadFirstPage()
    }

    func availableSortOptions() -> [SortDisplayOption] {
        [.popularityDesc, .voteAverageDesc, .releaseDateDesc]
    }

    func isCurrentSort(_ opt: SortDisplayOption) -> Bool {
        opt.sort == sort
    }

    func didSelectSort(_ opt: SortDisplayOption) {
        guard sort != opt.sort else { return }
        sort = opt.sort
        loadFirstPage()
    }

    func loadNextPageIfNeeded(visibleIndex: Int) {
        guard visibleIndex >= movies.count - 5, page < totalPages else { return }
        load(page: page + 1, reset: false)
    }

    func didSelectItem(at index: Int) {
        guard movies.indices.contains(index) else { return }
        let id = movies[index].id
        // TODO: Router get details
    }

    // MARK: Private

    private func loadFirstPage() {
        page = 0
        totalPages = 1
        movies = []

        view?.showLoading(true)
        load(page: 1, reset: true)
    }

    private func load(page p: Int, reset: Bool) {
        // офлайн-алерт по ТЗ
        guard reachability.isOnline else {
            DispatchQueue.main.async { [weak self] in
                self?.view?.showLoading(false)
                //TODO: move to Errors
                self?.view?.showError("You are offline. Please, enable your Wi-Fi or connect using cellular data.")
            }
            return
        }

        repo.fetchMovies(page: p, query: query, sort: sort, genres: nil) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let res):
                self.page = res.page
                self.totalPages = res.totalPages
                if reset { self.movies = res.items } else { self.movies += res.items }

                let items = self.movies.map(Self.mapToViewItem)

                DispatchQueue.main.async {
                    self.view?.showLoading(false)
                    if items.isEmpty {
                        self.view?.showEmptyState(message: "No results")
                    } else {
                        self.view?.showMovies(items)
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.showLoading(false)
                    self.view?.showError((error as MoviesErrors).userMessage)
                }
            }
        }
    }

    // MARK: Mapping

    private static func mapToViewItem(_ movie: Movie) -> MovieViewItem {
        let year = movie.releaseDate.map { Calendar.current.component(.year, from: $0) }
            .map(String.init) ?? ""
        let rating = movie.rating.map { String(format: "%.1f", $0) } ?? ""
        
        return MovieViewItem(
            id: movie.id,
            title: movie.title,
            genres: "",
            ratingText: rating,
            yearText: year,
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath
        )
    }
}

//
//  ViewController.swift
//  MovieApp
//
//  Created by Mari Budko on 30.09.2025.
//

import UIKit
import SnapKit
import Combine

protocol MoviesListView: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showMovies(_ items: [MovieViewItem])
    func showEmptyState(message: String)
    func showError(_ message: String)
}

enum Section: Int, CaseIterable, Hashable, Sendable {
    case main
}

class MovieListViewController: UICollectionViewController, MoviesListView {
    typealias ItemID = Int
    
    var presenter: MoviesListPresenting!
    
    private let spinner = UIActivityIndicatorView(style: .large)
    private let emptyState = EmptyStateView(message: "No results")
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemID>!
    private var itemsByID: [ItemID: MovieViewItem] = [:]
    
    private var pendingSearch: DispatchWorkItem?
    
    init() {
        super.init(collectionViewLayout: Self.makeLayout())
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNav()
        configureCollectionView()
        configureOverlays()
        configureDataSource()
        
        presenter.attach(view: self)
        presenter.viewDidLoad()
    }
    
    static func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(140))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(140))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureNav() {
        title = "Popular Movies"
        
        //SearchBar
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by title"
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        // Filter button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(tapSort)
        )
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseID)
        collectionView.alwaysBounceVertical = true
        
        // Pull-to-refresh
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        collectionView.refreshControl = rc
    }
    
    private func configureOverlays() {
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Empty state
        emptyState.isHidden = true
        view.addSubview(emptyState)
        emptyState.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemID>(
            collectionView: collectionView
        ) { [weak self] (cv, indexPath, itemID) -> UICollectionViewCell? in
            guard
                let self,
                let item = self.itemsByID[itemID],
                let cell = cv.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseID, for: indexPath) as? MovieCell
            else { return UICollectionViewCell() }
            
            cell.configure(item)
            return cell
        }
    }
    
    private func applySnapshot(_ items: [MovieViewItem], animating: Bool = true) {
        var dict: [ItemID: MovieViewItem] = [:]
        var orderedIDs: [ItemID] = []
        var seen = Set<ItemID>()
        
        for item in items {
            if seen.insert(item.id).inserted {
                orderedIDs.append(item.id)
            }
            dict[item.id] = item
        }
        
        self.itemsByID = dict
        
        var snap = NSDiffableDataSourceSnapshot<Section, ItemID>()
        snap.appendSections([.main])
        snap.appendItems(orderedIDs, toSection: .main)
        dataSource.apply(snap, animatingDifferences: animating)
    }
    
    @objc private func onRefresh() {
        presenter.didPullToRefresh()
    }
    
    @objc private func tapSort() {
        let sheet = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        for opt in presenter.availableSortOptions() {
            let action = UIAlertAction(title: opt.title, style: .default) { [weak self] _ in
                self?.presenter.didSelectSort(opt)
            }
            if presenter.isCurrentSort(opt) {
                action.setValue(true, forKey: "checked")
            }
            sheet.addAction(action)
        }
        sheet.addAction(.init(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
    
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            if collectionView.refreshControl?.isRefreshing == false {
                spinner.startAnimating()
            }
        } else {
            spinner.stopAnimating()
            collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func showMovies(_ items: [MovieViewItem]) {
        emptyState.isHidden = !items.isEmpty
        applySnapshot(items)
    }
    
    func showEmptyState(message: String) {
        emptyState.setMessage(message)
        emptyState.isHidden = false
        applySnapshot([])
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleMax = collectionView.indexPathsForVisibleItems.map(\.item).max() ?? 0
        presenter.loadNextPageIfNeeded(visibleIndex: visibleMax)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath.item)
    }
}

extension MovieListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange text: String) {
        pendingSearch?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.presenter.search(query: text)
        }
        pendingSearch = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.search(query: searchBar.text ?? "")
    }
}

#if DEBUG
import SwiftUI

struct MovieListViewController_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewWrapper()
                .previewDisplayName("iPhone 15 • Light")
                .preferredColorScheme(.light)
                .previewDevice("iPhone 15")

            PreviewWrapper()
                .previewDisplayName("iPhone 15 • Dark")
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 15")
        }
    }

    struct PreviewWrapper: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UINavigationController {
            let vc = MovieListViewController()
            vc.presenter = MockPreviewPresenter()
            return UINavigationController(rootViewController: vc)
        }
        func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    }

    // TODO: move to tests mock
    private final class MockPreviewPresenter: MoviesListPresenting {
        private weak var view: MoviesListView?

        func attach(view: MoviesListView) {
            self.view = view
        }

        func viewDidLoad() {
            let items: [MovieViewItem] = [
                .init(id: 1, title: "Dune: Part Two", genres: "Sci-Fi • Adventure", ratingText: "8.4", yearText: "2024", posterPath: nil, backdropPath: nil),
                .init(id: 1, title: "Dune: Part Two", genres: "Sci-Fi • Adventure", ratingText: "8.4", yearText: "2024", posterPath: nil, backdropPath: nil),
                .init(id: 1, title: "Dune: Part Two", genres: "Sci-Fi • Adventure", ratingText: "8.4", yearText: "2024", posterPath: nil, backdropPath: nil),
                .init(id: 1, title: "Dune: Part Two", genres: "Sci-Fi • Adventure", ratingText: "8.4", yearText: "2024", posterPath: nil, backdropPath: nil)
            ]
            view?.showLoading(false)
            view?.showMovies(items)
        }

        func didPullToRefresh() {}
        func search(query: String) {}
        func availableSortOptions() -> [SortDisplayOption] { [.popularityDesc, .voteAverageDesc, .releaseDateDesc] }
        func isCurrentSort(_ opt: SortDisplayOption) -> Bool { opt == .popularityDesc }
        func didSelectSort(_ opt: SortDisplayOption) {}
        func loadNextPageIfNeeded(visibleIndex: Int) {}
        func didSelectItem(at index: Int) {}
    }
}
#endif


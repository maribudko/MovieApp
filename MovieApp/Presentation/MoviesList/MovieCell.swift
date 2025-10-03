//
//  MovieCell.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import UIKit
import SnapKit
import SDWebImage

final class MovieCell: UICollectionViewCell {
    static let reuseID = "MovieCell"
    private let card = UIView()
    private let poster = UIImageView()
    private let titleLabel = UILabel()
    private let genresLabel = UILabel()
    private let ratingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        layer.masksToBounds = false
        contentView.layer.masksToBounds = false
        
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.15
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = .init(width: 0, height: 4)
        
        poster.contentMode = .scaleAspectFill
        poster.clipsToBounds = true
        poster.layer.cornerRadius = 12
        poster.sd_imageIndicator = SDWebImageActivityIndicator.medium
        
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2
        
        genresLabel.font = .preferredFont(forTextStyle: .subheadline)
        genresLabel.textColor = .secondaryLabel
        genresLabel.numberOfLines = 0
        
        ratingLabel.font = .preferredFont(forTextStyle: .subheadline)
        ratingLabel.textColor = .tertiaryLabel
        
        contentView.addSubview(card)
        card.addSubview(poster)
        card.addSubview(titleLabel)
        card.addSubview(genresLabel)
        card.addSubview(ratingLabel)
        
        card.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        poster.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(8)
            make.height.equalTo(card.snp.height).multipliedBy(2.0/3.0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(poster.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(8)
        }
        
        genresLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        poster.image = nil
    }
    
    func configure(_ item: MovieViewItem) {
        titleLabel.text = "\(item.title), \(item.yearText)"
        genresLabel.text  = item.genres
        ratingLabel.text = item.ratingText.isEmpty ? "" : "⭐️ \(item.ratingText)"
        let placeholder = UIImage(systemName: "film")
        poster.tintColor = .systemGray3
        poster.backgroundColor = .tertiarySystemFill
        
        //TODO: move to service
        if let path = item.backdropPath,
           let url = URL(string: "https://image.tmdb.org/t/p/w300\(path)") {
            poster.sd_setImage(with: url,
                               placeholderImage: placeholder,
                               options: [.retryFailed, .refreshCached])
        } else {
            poster.image = placeholder
        }
    }
}

import SwiftUI

struct MovieCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MovieCellContainer()
                .frame(width: .infinity, height: 260)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}

struct MovieCellContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let cell = MovieCell()
        cell.configure(
            MovieViewItem(id: 0, title: "Some Title",
                          genres: "Action • Sci-Fi • Horror • Thriller",
                          ratingText: "7.5", yearText: "1999",
                          posterPath: nil, backdropPath: nil)
        )
        
        let container = UIView()
        container.backgroundColor = .clear
        
        container.addSubview(cell.contentView)
        cell.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
}

//
//  NewsCell.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//

import UIKit

final class NewsCell: UICollectionViewCell {
    static let reuseIdentifier = "NewsCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = Constants.imageCornerRadius
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()

    private var imageTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupShadow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        imageView.image = nil
    }

    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: Constants.imageHeightMultiplier),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.titleTopSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.dateTopSpacing),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.dateBottomSpacing)
        ])
    }

    private func setupShadow() {
        contentView.layer.cornerRadius = Constants.contentCornerRadius
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = Constants.shadowOffset
        layer.shadowRadius = Constants.shadowRadius
        layer.shadowOpacity = Constants.shadowOpacity
        layer.masksToBounds = false
    }

    func configure(with item: NewsItem) {
        titleLabel.text = item.title
        dateLabel.text = item.publishedDate.formattedDate()

        guard let imageUrl = item.titleImageUrl else {
            imageView.image = UIImage(systemName: "photo")?
                .withTintColor(.systemGray, renderingMode: .alwaysOriginal)
            return
        }

        imageTask = Task {
            do {
                let image = try await ImageLoader.shared.loadImage(from: imageUrl)
                if !Task.isCancelled {
                    imageView.image = image
                }
            } catch {
                imageView.image = UIImage(systemName: "photo.on.rectangle")?
                    .withTintColor(.systemGray, renderingMode: .alwaysOriginal)
            }
        }
    }
}

// MARK: - Constants

private extension NewsCell {
    enum Constants {
        static let imageCornerRadius: CGFloat = 8
        static let contentCornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.1
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let imageHeightMultiplier: CGFloat = 0.6
        static let titleTopSpacing: CGFloat = 8
        static let dateTopSpacing: CGFloat = 4
        static let dateBottomSpacing: CGFloat = -8
    }
}

//
//  ViewController.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//
import UIKit
import Combine

final class NewsViewController: UIViewController {
    private enum Section { case main }
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.register(NewsCell.self, forCellWithReuseIdentifier: NewsCell.reuseIdentifier)
        return cv
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, NewsItem>!
    private let viewModel: NewsViewModelProtocol = NewsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionViewConstraints()
        setupDataSource()
        bindViewModel()
        loadInitialData()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = Constants.title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupCollectionViewConstraints() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Layout
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let isRegular = layoutEnvironment.traitCollection.horizontalSizeClass == .regular
            let fractionalWidth: CGFloat = isRegular ? Constants.regularFractionalWidth : Constants.compactFractionalWidth
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(fractionalWidth),
                heightDimension: .estimated(Constants.estimatedCellHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(Constants.estimatedCellHeight)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: isRegular ? 2 : 1)
            group.interItemSpacing = .fixed(Constants.interItemSpacing)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Constants.interGroupSpacing
            section.contentInsets = Constants.sectionInsets
            
            return section
        }
    }
    
    // MARK: - Data Source Setup
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, NewsItem>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, item in
                guard let self else { return nil }
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NewsCell.reuseIdentifier,
                    for: indexPath) as! NewsCell
                cell.configure(with: item)
                return cell
            })
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NewsItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.newsItems)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Bind ViewModel
    
    private func bindViewModel() {
        viewModel.newsItemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateSnapshot()
            }
            .store(in: &cancellables)
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error = error else { return }
                self?.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    private func loadInitialData() {
        Task {
            await viewModel.loadNews()
        }
    }
    
    // MARK: - Helpers
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: Constants.errorTitle,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: Constants.okTitle, style: .default))
        alert.addAction(UIAlertAction(title: Constants.retryTitle, style: .default) { [weak self] _ in
            self?.loadInitialData()
        })
        
        present(alert, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - UICollectionViewDelegate

extension NewsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let webVC = WebViewController(urlString: item.fullUrl)
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - Constants.scrollThreshold, !viewModel.isLoading {
            Task {
                await viewModel.loadNews()
            }
        }
    }
}

// MARK: - Constants

private extension NewsViewController {
    enum Constants {
        static let title = "Автодок Новости"
        static let estimatedCellHeight: CGFloat = 300
        static let regularFractionalWidth: CGFloat = 0.5
        static let compactFractionalWidth: CGFloat = 1.0
        static let interItemSpacing: CGFloat = 16
        static let interGroupSpacing: CGFloat = 16
        static let sectionInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        static let scrollThreshold: CGFloat = 100
        
        static let errorTitle = "Ошибка"
        static let okTitle = "OK"
        static let retryTitle = "Повторить"
    }
}

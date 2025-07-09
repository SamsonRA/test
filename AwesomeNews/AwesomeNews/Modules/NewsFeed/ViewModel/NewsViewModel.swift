//
//  NewsViewModel.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//

import Foundation
import Combine

final class NewsViewModel: NewsViewModelProtocol {
    var newsItemsPublisher: AnyPublisher<[NewsItem], Never> {
        $newsItems.eraseToAnyPublisher()
    }
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    var errorPublisher: AnyPublisher<(any Error)?, Never> {
        $error.eraseToAnyPublisher()
    }
    
    @Published private(set) var newsItems: [NewsItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let apiService: APIServiceProtocol
    private var currentPage = 1
    private let itemsPerPage = 15
    private var hasMoreData = true
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: APIServiceProtocol = NewsAPIService()) {
        self.apiService = apiService
    }
    
    func loadNews() async {
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        error = nil
        
        do {
            let response = try await apiService.fetchNews(page: currentPage, count: itemsPerPage)
            let mappedItems = response.news.map {
                            NewsItem(
                                id: UUID(),
                                title: $0.title,
                                description: $0.description,
                                fullUrl: $0.fullUrl,
                                titleImageUrl: $0.titleImageUrl,
                                publishedDate: $0.publishedDate
                            )
                        }
                        
                        newsItems.append(contentsOf: mappedItems)
            hasMoreData = newsItems.count < response.totalCount
            currentPage += 1
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func refreshNews() async {
        currentPage = 1
        hasMoreData = true
        newsItems.removeAll()
        await loadNews()
    }
}

//
//  NewsAPIService.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//

import Foundation

final class NewsAPIService: APIServiceProtocol {
    private let baseURL = "https://webapi.autodoc.ru/api/news"
    
    func fetchNews(page: Int, count: Int) async throws -> NewsResponse {
        let urlString = "\(baseURL)/\(page)/\(count)"
        
        guard let url = URL(string: urlString) else {
           throw  URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(NewsResponse.self, from: data)
    }
    
    
}

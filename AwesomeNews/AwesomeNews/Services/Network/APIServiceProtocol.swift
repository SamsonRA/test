//
//  APIServiceProtocol.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//

import Foundation

protocol APIServiceProtocol {
    func fetchNews(page: Int, count: Int) async throws -> NewsResponse
}

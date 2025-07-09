//
//  NewsItem.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//

import Foundation
struct RawNewsItem:  Decodable, Hashable {
    let title: String
    let description: String
    let fullUrl: String
    let titleImageUrl: String?
    let publishedDate: String
}

struct NewsItem:  Decodable, Hashable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let fullUrl: String
    let titleImageUrl: String?
    let publishedDate: String
}

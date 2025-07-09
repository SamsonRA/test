//
//  NewsResponse.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//

import Foundation

struct NewsResponse: Decodable {
    let news: [RawNewsItem]
    let totalCount: Int
}

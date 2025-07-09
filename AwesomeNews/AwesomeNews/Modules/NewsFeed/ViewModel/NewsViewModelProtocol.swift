//
//  NewsViewModelProtocol.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//

import Foundation
import Combine

protocol NewsViewModelProtocol {
    var newsItems: [NewsItem] { get }
    var isLoading: Bool { get }
    var error: Error? { get }
    
    var newsItemsPublisher: AnyPublisher<[NewsItem], Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    
    func loadNews() async
    func refreshNews() async
}

protocol NewsViewProtocol: AnyObject {
    func displayNews()
    func showError(_ error: Error)
    func showLoading(_ isLoading: Bool)
}

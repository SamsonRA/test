//
//  ImageLoader.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//

import UIKit

///класс, реализующий кэширование изображений в памяти
final class ImageLoader: ImageLoaderProtocol {
    static let shared = ImageLoader()
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100 
    }
    
    func loadImage(from urlString: String) async throws -> UIImage {
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            return cachedImage
        }
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        cache.setObject(image, forKey: urlString as NSString)
        return image
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

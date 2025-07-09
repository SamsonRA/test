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
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let diskCacheURL: URL
    
    private var ongoingTasks = [NSString: Task<UIImage, Error>]()
    private let lock = NSLock()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        
        // Путь к директории кэша в Caches/AppName/
        if let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            diskCacheURL = caches.appendingPathComponent("ImageCache", isDirectory: true)
        } else {
            diskCacheURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("ImageCache", isDirectory: true)
        }
        
        // Создаем папку, если ее нет
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    
    func loadImage(from urlString: String) async throws -> UIImage {
        let key = urlString as NSString
        
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // Попытка загрузить с диска
        if let diskImage = loadImageFromDisk(forKey: urlString) {
            cache.setObject(diskImage, forKey: key)
            return diskImage
        }
        
        lock.lock()
        if let existingTask = ongoingTasks[key] {
            lock.unlock()
            return try await existingTask.value
        }
        
        let task = Task<UIImage, Error> {
            defer {
                lock.lock()
                ongoingTasks.removeValue(forKey: key)
                lock.unlock()
            }
            
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let decodedImage = decodeImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            
            cache.setObject(decodedImage, forKey: key, cost: data.count)
            
            // Сохраняем изображение на диск
            saveImageToDisk(data: data, forKey: urlString)
            
            return decodedImage
        }
        
        ongoingTasks[key] = task
        lock.unlock()
        
        return try await task.value
    }
    
    private func loadImageFromDisk(forKey key: String) -> UIImage? {
        let fileURL = diskCacheURL.appendingPathComponent(safeFileName(for: key))
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    private func saveImageToDisk(data: Data, forKey key: String) {
        let fileURL = diskCacheURL.appendingPathComponent(safeFileName(for: key))
        try? data.write(to: fileURL)
    }
    
    private func safeFileName(for key: String) -> String {
        // Чтобы ключ был валидным именем файла
        return String(key.hashValue)
    }
    
    private func decodeImage(data: Data) -> UIImage? {
        guard let image = UIImage(data: data) else { return nil }
        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
        image.draw(at: .zero)
        let decodedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return decodedImage
    }
    
    func clearCache() {
        cache.removeAllObjects()
        
        // Удаляем все файлы из папки кэша
        if let files = try? fileManager.contentsOfDirectory(atPath: diskCacheURL.path) {
            for file in files {
                let fileURL = diskCacheURL.appendingPathComponent(file)
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
}

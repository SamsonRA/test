//
//  StatePreservationManager.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//

import Foundation

/// Класс для сохранения состояния приложения (списка новостей) при переходе в фоновый режим или закрытии и восстановления этого состояния при повторном открытии

final class StatePreservationManager {
    static func save<T: Encodable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    static func load<T: Decodable>(forKey key: String, type: T.Type) throws -> T {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            throw NSError(domain: "StatePreservation", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data found for key: \(key)"])
        }
        return try JSONDecoder().decode(type, from: data)
    }
}

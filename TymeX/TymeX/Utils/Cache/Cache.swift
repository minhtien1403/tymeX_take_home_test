//
//  Cache.swift
//  TymeX
//
//  Created by Trần Tiến on 20/3/25.
//

import Foundation

protocol CacheManagerProtocol {
    
    func saveResponse<T: Codable>(_ response: T, forKey key: String, expiryTime: TimeInterval)
    func loadResponse<T: Codable>(forKey key: String, type: T.Type) -> T?
    func removeCache(forKey key: String)
    func cleanExpiredCache()
}


class CacheManager: CacheManagerProtocol {
    
    static let shared = CacheManager()
    private let cacheDirectory: URL
    
    private init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("APICache")
        
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // Save response with expiration time
    func saveResponse<T: Codable>(_ response: T, forKey key: String, expiryTime: TimeInterval) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        let timestamp = Date().timeIntervalSince1970
        let cacheObject = CachedResponse(data: response, timestamp: timestamp, expiryTime: expiryTime)
        
        do {
            let data = try JSONEncoder().encode(cacheObject)
            try data.write(to: fileURL)
            print("[Cache] Cached data successfully for key: \(key)")
        } catch {
            print("[Cache] Failed to cache data: \(error)")
        }
    }
    
    func loadResponse<T: Codable>(forKey key: String, type: T.Type) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let cachedObject = try JSONDecoder().decode(CachedResponse<T>.self, from: data)
            
            // check to delete if cached object expired
            if Date().timeIntervalSince1970 - cachedObject.timestamp > cachedObject.expiryTime {
                removeCache(forKey: key)
                print("[Cache] Cache expired for key: \(key)")
                return nil
            }
            
            print("[Cache] Loaded cached data for key: \(key)")
            return cachedObject.data
        } catch let DecodingError.typeMismatch(type, context) {
            print("[Cache] Decoding error: Type mismatch for \(type). Debug: \(context.debugDescription)")
            removeCache(forKey: key) // Xóa cache lỗi
            return nil
        } catch {
            print("[Cache] Failed to load cached data: \(error)")
            return nil
        }
    }
    
    
    // Remove specific cache file
    func removeCache(forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    // Remove all expired cache files
    func cleanExpiredCache() {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else { return }

        for file in files {
            do {
                let data = try Data(contentsOf: file)
                let cachedObject = try JSONDecoder().decode(CachedResponse<AnyCodable>.self, from: data)

                if Date().timeIntervalSince1970 - cachedObject.timestamp > cachedObject.expiryTime {
                    try fileManager.removeItem(at: file)
                    print("[Cache] Removed expired cache: \(file.lastPathComponent)")
                }
            } catch let DecodingError.typeMismatch(type, context) {
                print("[Cache] Type mismatch: Expected \(type). Debug: \(context.debugDescription)")
                try? fileManager.removeItem(at: file) // Tự động xóa cache lỗi
            } catch {
                print("[Cache] Error checking cache file: \(error)")
            }
        }
    }

}

struct CachedResponse<T: Codable>: Codable {
    
    let data: T // data to cache
    let timestamp: TimeInterval // time when cache object saved
    let expiryTime: TimeInterval // lifetime of cache object
}

struct AnyCodable: Codable {
    let value: Any

    init<T>(_ value: T) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            self.value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            self.value = dictValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            self.value = arrayValue
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported data type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        if let value = value as? String {
            try container.encode(value)
        } else if let value = value as? Int {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? [String: AnyCodable] {
            try container.encode(value)
        } else if let value = value as? [AnyCodable] {
            try container.encode(value)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported data type"))
        }
    }
}

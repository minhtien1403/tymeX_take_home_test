//
//  NetworkServices.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Foundation
import Combine

/// A singleton service responsible for making network requests and caching responses.
struct NetworkServices {
    
    /// URLSession instance for handling network requests.
    private let urlSession: URLSession
    
    /// Cache manager responsible for storing and retrieving cached responses.
    private let cacheManager: CacheManagerProtocol
    
    /// Shared instance of `NetworkServices` (Singleton Pattern).
    static let shared = NetworkServices()
    
    /// Private initializer to enforce singleton usage.
    private init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = 10  // Sets resource timeout
        sessionConfig.timeoutIntervalForRequest = 10   // Sets request timeout
        urlSession = URLSession(configuration: sessionConfig)
        cacheManager = CacheManager.shared  // Uses a shared cache manager
    }
    
    /// Performs a network request and retrieves the cached data if available.
    ///
    /// - Parameters:
    ///   - request: The `HTTPRequest` to be executed.
    ///   - cacheExpiryTime: The time interval (in seconds) before the cache expires.
    /// - Returns: A publisher emitting a `Result` containing the decoded response or an error.
    func request<T: Codable>(request: HTTPRequest, cacheExpiryTime: TimeInterval = 3600) -> AnyPublisher<Result<T, NetworkRequestError>, Never> {
        // Attempt to build a valid URLRequest from the HTTPRequest object.
        guard let request = request.buildRequest() else {
            return Just(.failure(.invalidRequest)).eraseToAnyPublisher()
        }
        
        // Generate a cache key using the URL hash.
        let cacheKey = request.url?.absoluteString.sha256() ?? ""
        
        // Check if the response is available in the cache.
        if let cachedData = cacheManager.loadResponse(forKey: cacheKey, type: T.self) {
            return Just(.success(cachedData)).eraseToAnyPublisher()
        }
        
        // If no cache is found, proceed with the network request.
        return makeRequest(request: request, cacheExpiryTime: cacheExpiryTime)
    }
    
    /// Executes a network request and caches the response if successful.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to be executed.
    ///   - cacheExpiryTime: The cache expiry duration in seconds.
    /// - Returns: A publisher emitting a `Result` containing the decoded response or an error.
    private func makeRequest<ReturnType: Codable>(request: URLRequest, cacheExpiryTime: TimeInterval = 3600) -> AnyPublisher<Result<ReturnType, NetworkRequestError>, Never> {
        print("[\(request.httpMethod?.uppercased() ?? "")] '\(request.url!)'") // Logs request method and URL
        
        let cacheKey = request.url?.absoluteString.sha256() ?? ""
        
        return urlSession
            .dataTaskPublisher(for: request)  // Executes the request
            .subscribe(on: DispatchQueue.global(qos: .default))  // Runs on a background thread
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse else {
                    throw httpError(0) // Invalid response error
                }
                
                // Log response status code
                print("[\(response.statusCode)] '\(request.url!)'")
                
                // Attempt to log the JSON response in a readable format.
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                   let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString) // Pretty printed JSON output
                } else {
                    print("Failed to decode JSON")
                }
                
                // Check for HTTP error status codes
                if !(200...299).contains(response.statusCode) {
                    throw httpError(response.statusCode)
                }
                
                return data
            }
            .receive(on: DispatchQueue.main)  // Switch back to the main thread
            .decode(type: ReturnType.self, decoder: JSONDecoder())  // Decode the response
            .handleEvents(receiveOutput: { decodedData in
                // Save the successful response to cache
                self.cacheManager.saveResponse(decodedData, forKey: cacheKey, expiryTime: cacheExpiryTime)
            })
            .map(Result.success)  // Convert the successful response to a `Result.success`
            .catch { error in Just(.failure(handleError(error))) }  // Convert errors to `Result.failure`
            .eraseToAnyPublisher()
    }
    
    /// Maps HTTP status codes to `NetworkRequestError` cases.
    ///
    /// - Parameter statusCode: The HTTP response status code.
    /// - Returns: Corresponding `NetworkRequestError` type.
    private func httpError(_ statusCode: Int) -> NetworkRequestError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500: return .serverError
        case 501...599: return .error5xx(statusCode)
        default: return .unknownError
        }
    }
    
    /// Handles general errors encountered during network requests.
    ///
    /// - Parameter error: The encountered error.
    /// - Returns: Corresponding `NetworkRequestError` type.
    private func handleError(_ error: Error) -> NetworkRequestError {
        switch error {
        case is Swift.DecodingError:
            return .decodingError(error.localizedDescription)
        case let urlError as URLError:
            if urlError.code == .timedOut {
                return .timeOut
            }
            return .urlSessionFailed(urlError)
        case let error as NetworkRequestError:
            return error
        default:
            return .unknownError
        }
    }
}

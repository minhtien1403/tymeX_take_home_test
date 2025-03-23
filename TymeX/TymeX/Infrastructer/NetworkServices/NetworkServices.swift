//
//  NetworkServices.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Foundation
import Combine

struct NetworkServices {
    
    private let urlSession: URLSession
    private let cacheManager: CacheManagerProtocol
    static let shared = NetworkServices()
    
    private init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = 10
        sessionConfig.timeoutIntervalForRequest = 10
        urlSession = URLSession(configuration: sessionConfig)
        cacheManager = CacheManager.shared
    }
    
    func request<T: Codable>(request: HTTPRequest, cacheExpiryTime: TimeInterval = 3600) -> AnyPublisher<Result<T, NetworkRequestError>, Never> {
        guard let request = request.buildRequest() else {
            return Just(.failure(.invalidRequest)).eraseToAnyPublisher()
        }
        let cacheKey = request.url?.absoluteString.sha256() ?? ""
        if let cachedData = cacheManager.loadResponse(forKey: cacheKey, type: T.self) {
            return Just(.success(cachedData)).eraseToAnyPublisher()
        }
        return makeRequest(request: request, cacheExpiryTime: cacheExpiryTime)
    }
    
    private func makeRequest<ReturnType: Codable>(request: URLRequest, cacheExpiryTime: TimeInterval = 3600) -> AnyPublisher<Result<ReturnType, NetworkRequestError>, Never> {
        print("[\(request.httpMethod?.uppercased() ?? "")] '\(request.url!)'")
        let cacheKey = request.url?.absoluteString.sha256() ?? ""
        return urlSession
            .dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse else {
                    throw httpError(0)
                }
                // Log Request result
                print("[\(response.statusCode)] '\(request.url!)'")
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                   let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString) // Pretty printed JSON output
                } else {
                    print("Failed to decode JSON")
                }
                
                if !(200...299).contains(response.statusCode) {
                    throw httpError(response.statusCode)
                }
                return data
            }
            .receive(on: DispatchQueue.main)
            .decode(type: ReturnType.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { decodedData in
                self.cacheManager.saveResponse(decodedData, forKey: cacheKey, expiryTime: cacheExpiryTime)
            })
            .map(Result.success) // Convert to Result.success case
            .catch { error in Just(.failure(handleError(error))) } // Handle errors as Result.failure
            .eraseToAnyPublisher()
    }

    
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

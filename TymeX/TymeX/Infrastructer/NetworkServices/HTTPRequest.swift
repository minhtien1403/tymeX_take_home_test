//
//  HTTPRequest.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Foundation

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

enum HTTPHeaderField: String {
    
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case apiKey = "x-api-key"
}

protocol HTTPRequest {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: String { get }
    var body: [String: Any]? { get }
    var queryParams: [String: Any]? { get }
    var headers: [String: String]? { get }
    var apiKey: String { get }
    var token: String { get }
}

extension HTTPRequest {
    
    // Default
    var baseURL: String { return URLs.Git.base }
    var method: HTTPMethod { return .get }
    var contentType: String { return "application/json; charset=utf-8" }
    var queryParams: [String: Any]? { return nil }
    var body: [String: Any]? { return nil }
    var headers: [String: String]? { return nil }
    var apiKey: String { return "" }
    var token: String { return "" }
    
    private func requestBodyFrom(params: [String: Any]?) -> Data? {
        guard let params = params else { return nil }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return nil
        }
        return httpBody
    }
    
    func addQueryItems(queryParams: [String: Any]?) -> [URLQueryItem]? {
        guard let param = queryParams else {
            return nil
        }
        return param.map({URLQueryItem(name: $0.key, value: "\($0.value)")})
    }
    
    func buildRequest() -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL) else { return nil }
        urlComponents.path = "\(urlComponents.path)\(path)"
        urlComponents.queryItems = addQueryItems(queryParams: queryParams)
        guard let finalURL = urlComponents.url else {
            return nil
        }
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.httpBody = requestBodyFrom(params: body)
        request.allHTTPHeaderFields = headers
        
        ///Set your Common Headers here
        ///Like: api secret key for authorization header
        ///Or set your content type
        //request.setValue("Your API Token key", forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
        //request.setValue(contentType, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        //request.setValue(apiKey, forHTTPHeaderField: HTTPHeaderField.apiKey.rawValue)
        //request.setValue(token, forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
        return request
    }
}

//
//  APIEndPoint.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Foundation

struct APIEndPoint {
    
    struct getUsers: HTTPRequest {
        
        var path: String = "/users"
        var queryParams: [String : Any]?
        
        init(queryParams: APIParameters.getListUser) {
            self.queryParams = queryParams.asDictionary
        }
    }
    
    struct getUser: HTTPRequest {
        
        var path: String
                
        init(param: APIParameters.getUser) {
            path = "/users/\(param.username)"
        }
    }
}

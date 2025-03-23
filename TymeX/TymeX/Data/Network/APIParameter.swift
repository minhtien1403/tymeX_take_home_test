//
//  APIParameter.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Foundation

struct APIParameters {
    
    struct getListUser: Encodable {
        
        var perPage: Int
        var since: Int
        
        private enum CodingKeys: String, CodingKey {
            case perPage = "per_page"
            case since
        }
    }
    
    struct getUser: Encodable {
        
        var username: String
    }
}

//
//  User.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Foundation

import Foundation

struct User: Codable {
    
    let login: String
    let avatarURL: String
    let htmlURL: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case login, id
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
}

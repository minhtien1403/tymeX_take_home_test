//
//  UserDetails.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Foundation

struct UserDetails: Codable {
    
    let login: String
    let avatarURL: String
    let blog: String
    let location: String?
    let followers: Int
    let following: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case login, name, blog, location, followers, following
        case avatarURL = "avatar_url"
    }
}

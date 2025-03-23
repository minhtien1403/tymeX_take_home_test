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
    let id: Int
    let nodeID: String
    let avatarURL: String
    let gravatarID: String
    let url: String
    let htmlURL: String
    let followersURL: String
    let followingURL: String
    let gistsURL: String
    let starredURL: String
    let subscriptionsURL: String
    let organizationsURL: String
    let reposURL: String
    let eventsURL: String
    let receivedEventsURL: String
    let type: String
    let userViewType: String
    let siteAdmin: Bool

    enum CodingKeys: String, CodingKey {
        case login, id, gravatarID = "gravatar_id", url, type, siteAdmin = "site_admin"
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case userViewType = "user_view_type"
    }
}

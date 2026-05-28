//
//  User.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import Foundation

struct User: Codable {

    let login: String
    let avatarUrl: URL
    let htmlURL: URL

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
        case htmlURL = "html_url"
    }
}

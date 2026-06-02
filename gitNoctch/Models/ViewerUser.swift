//
//  ViewerUser.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 01/06/2026.
//

import Foundation

struct ViewerUser: Codable {
    let login: String
    let avatarUrl: URL
    let url: URL
    let followers: TotalCount
    let repositories: TotalCount
    
    struct TotalCount: Codable {
        let totalCount: Int
    }
}
struct ViewerResponse: Codable {
    let data: ViewerData
    
    struct ViewerData: Codable {
        let viewer: ViewerUser
    }
}

//
//  PullRequestsAndReviews.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 01/06/2026.
//

import Foundation

struct PullRequestsResponse: Codable {
    let data: Data
    
    struct Data: Codable {
        let viewer: Viewer
        let search: Search
    }
    
    struct Viewer: Codable {
        let pullRequests: Connection
    }
    
    struct Connection: Codable {
        let totalCount: Int
    }
    
    struct Search: Codable {
        let issueCount: Int
    }
    
}

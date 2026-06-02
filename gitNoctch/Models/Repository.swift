//
//  Repository.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 01/06/2026.
//

import Foundation

// Pour viewer.repositories
struct RepositoryResponse: Codable {
    let data: Data
    
    struct Data: Codable {
        let viewer: Viewer
    }
    
    struct Viewer: Codable {
        let repositories: RepositoryConnection
    }
    
    struct RepositoryConnection: Codable {
        let pageInfo: PageInfo
        let nodes: [Repository]
    }
    
    struct PageInfo: Codable {
        let hasNextPage: Bool
        let endCursor: String?
    }
}

// Pour search
struct SearchRepositoryResponse: Codable {
    let data: Data
    
    struct Data: Codable {
        let search: SearchConnection
    }
    
    struct SearchConnection: Codable {
        let pageInfo: PageInfo
        let nodes: [Repository]
    }
    
    struct PageInfo: Codable {
        let hasNextPage: Bool
        let endCursor: String?
    }
}

struct Repository: Codable {
    let name: String
    let nameWithOwner: String
    let url: URL
    let isPrivate: Bool
    let stargazerCount: Int
    let forkCount: Int
    let pushedAt: String?
    let primaryLanguage: Language?
    let licenseInfo: LicenseInfo?
    
    struct Language: Codable {
        let name: String
    }
    
    struct LicenseInfo: Codable {
        let spdxId: String
    }
}

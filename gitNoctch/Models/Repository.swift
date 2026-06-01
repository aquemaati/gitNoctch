//
//  Repository.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 01/06/2026.
//

import Foundation

struct RepositoryResponse: Codable {
    let data: Data
    
    struct Data: Codable {
        let viewer: Viewer
    }
    
    struct Viewer: Codable {
        let repositories: RepositoryConnection
    }
    
    struct RepositoryConnection: Codable {
        let nodes: [Repository]
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

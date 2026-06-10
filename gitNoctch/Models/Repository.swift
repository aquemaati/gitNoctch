//
//  Repository.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 01/06/2026.
//

import Foundation
import SwiftUI

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
        let color: String?
    }

    struct LicenseInfo: Codable {
        let spdxId: String
    }
}

extension Repository {
    /// Couleur du langage principal fournie par GitHub (hex), sinon une couleur neutre.
    var languageColor: Color {
        Color(hex: primaryLanguage?.color) ?? .gray
    }

    /// Libellé court "il y a X" calculé à partir de `pushedAt`.
    var lastUpdateText: String? {
        guard let pushedAt,
              let date = ISO8601DateFormatter().date(from: pushedAt) else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

extension Color {
    /// Initialise une couleur à partir d'une chaîne hex GitHub ("#RRGGBB").
    init?(hex: String?) {
        guard let hex, hex.hasPrefix("#") else { return nil }
        let hexString = String(hex.dropFirst())
        guard hexString.count == 6, let value = Int(hexString, radix: 16) else { return nil }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

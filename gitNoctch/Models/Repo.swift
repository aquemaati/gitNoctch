//
//  Repo.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import Foundation

struct Repo: Codable {
    let id: Int
    let name: String
    let fullName: String
    let language: String?
    let htmlUrl: URL
    let pushedAt: Date
    var épinglé: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case language
        case htmlUrl = "html_url"
        case pushedAt = "pushed_at"
    }
    
    func initiales() -> String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0).uppercased() }
            .joined()
    }
    
    func lastActivity() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: pushedAt, relativeTo: Date())
    }
}

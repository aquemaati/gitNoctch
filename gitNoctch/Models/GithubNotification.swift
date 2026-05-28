//
//  Notification.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import Foundation

struct GithubNotification: Codable{
    let id: String
    let reason: String
    let unread: Bool
    let updatedAt: Date
    let subject: Subject
    
    struct Subject: Codable {
        let type: String
        let title: String
        let url: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case reason
        case unread
        case updatedAt = "updated_at"
        case subject
    }
    
    func isUrgent() -> Bool {
        reason == "review_requested" || reason == "mention" || reason == "assign"
    }
    
    func icon() -> String {
        switch reason {
        case "review_requested": return "eyes"
        case "mention": return "at"
        case "assign": return "person.fill"
        case "push": return "arrow.up.circle"
        case "security_alert": return "shield.fill"
        case "state_change": return "circle.fill"
        default: return "bell"
        }
    }
}

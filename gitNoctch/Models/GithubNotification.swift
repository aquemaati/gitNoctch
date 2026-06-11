//
//  Notification.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import Foundation
import SwiftUI

struct GithubNotification: Codable{
    let id: String
    let reason: String
    let unread: Bool
    let updatedAt: Date
    let subject: Subject
    let repository: Repository?

    struct Subject: Codable {
        let type: String
        let title: String
        let url: String
    }

    struct Repository: Codable {
        let fullName: String

        enum CodingKeys: String, CodingKey {
            case fullName = "full_name"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case reason
        case unread
        case updatedAt = "updated_at"
        case subject
        case repository
    }

    /// "owner/repo" du dépôt concerné, si disponible.
    var repoName: String? { repository?.fullName }

    /// Numéro d'issue/PR extrait de l'URL du subject (ex. "#5"), si présent.
    var subjectNumber: String? {
        guard let number = subject.url.split(separator: "/").last,
              Int(number) != nil else { return nil }
        return "#\(number)"
    }

    /// Libellé court "il y a X" basé sur updatedAt.
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: updatedAt, relativeTo: Date())
    }

    /// Libellé de raison à afficher en badge, ou nil quand peu utile (ex. abonnement).
    var reasonBadge: String? {
        switch reason {
        case "subscribed": return nil
        default: return reasonText()
        }
    }

    /// Description lisible de la raison.
    func reasonText() -> String {
        switch reason {
        case "review_requested": return "Revue demandée"
        case "mention": return "Mention"
        case "assign": return "Assignation"
        case "security_alert": return "Alerte sécurité"
        case "push": return "Nouveau commit"
        case "state_change": return "Changement d'état"
        case "subscribed": return "Abonnement"
        case "comment": return "Commentaire"
        default: return reason.capitalized
        }
    }
    
    func isUrgent() -> Bool {
        reason == "review_requested" || reason == "mention" || reason == "assign"
    }
    
    /// Icône SF Symbol ressemblant à celle de GitHub, selon le type et l'état.
    func icon(_ detail: NotificationSubjectDetail? = nil) -> String {
        switch subject.type {
        case "Issue":
            if detail?.state == "closed" {
                return detail?.stateReason == "not_planned" ? "slash.circle.fill" : "checkmark.circle.fill"
            }
            return "smallcircle.filled.circle"
        case "PullRequest":
            if detail?.merged == true { return "arrow.triangle.merge" }
            if detail?.state == "closed" { return "xmark.circle.fill" }
            return "arrow.triangle.pull"
        case "Commit": return "circle.and.line.horizontal"
        case "Release": return "tag.fill"
        case "Discussion": return "bubble.left.and.bubble.right.fill"
        case "CheckSuite": return "checkmark.seal.fill"
        case "RepositoryVulnerabilityAlert": return "shield.lefthalf.filled"
        default: return "bell.fill"
        }
    }

    /// Couleur proche de celle utilisée par GitHub, selon le type et l'état.
    func iconColor(_ detail: NotificationSubjectDetail? = nil) -> Color {
        let green = Color(hex: "#3FB950")
        let purple = Color(hex: "#A371F7")
        let red = Color(hex: "#F85149")
        let gray = Color(hex: "#8B949E")

        switch subject.type {
        case "Issue":
            if detail?.state == "closed" {
                return detail?.stateReason == "not_planned" ? gray : purple
            }
            return green
        case "PullRequest":
            if detail?.merged == true { return purple }
            if detail?.state == "closed" { return red }
            return green
        case "Commit": return gray
        case "Release": return green
        case "Discussion": return purple
        case "CheckSuite": return green
        case "RepositoryVulnerabilityAlert": return red
        default: return .white.opacity(0.6)
        }
    }

    /// Libellé d'état lisible ("Ouverte", "Fermée", "Fusionnée"…) si pertinent.
    func statusLabel(_ detail: NotificationSubjectDetail?) -> String? {
        guard let detail else { return nil }
        switch subject.type {
        case "Issue":
            guard let state = detail.state else { return nil }
            if state == "closed" {
                return detail.stateReason == "not_planned" ? "Fermée" : "Résolue"
            }
            return "Ouverte"
        case "PullRequest":
            if detail.merged == true { return "Fusionnée" }
            guard let state = detail.state else { return nil }
            if state == "closed" { return "Fermée" }
            if detail.draft == true { return "Brouillon" }
            return "Ouverte"
        default:
            return nil
        }
    }
}

/// Détail récupéré via `subject.url` pour connaître l'état d'une issue/PR.
struct NotificationSubjectDetail: Codable {
    let state: String?
    let merged: Bool?
    let draft: Bool?
    let stateReason: String?

    enum CodingKeys: String, CodingKey {
        case state, merged, draft
        case stateReason = "state_reason"
    }
}

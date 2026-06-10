import Foundation
import SwiftUI

struct GithubEvent: Codable {
    let id: String
    let type: String
    let createdAt: Date
    let repo: EventRepo
    let payload: Payload?
    
    struct EventRepo: Codable {
        let name: String
    }
    
    struct Payload: Codable {
        let ref: String?
        let head: String?
        let commits: [Commit]?

        struct Commit: Codable {
            let sha: String?
            let message: String
        }

        func shortHead() -> String? {
            guard let head = head else { return nil }
            return String(head.prefix(7))
        }

        func branchName() -> String? {
            ref?.replacingOccurrences(of: "refs/heads/", with: "")
        }
    }

    func branchName() -> String? {
        payload?.branchName()
    }

    func commitHash() -> String? {
        payload?.shortHead()
    }

    /// Première ligne du message du dernier commit poussé (le HEAD), si disponible.
    func commitMessage() -> String? {
        guard let message = payload?.commits?.last?.message else { return nil }
        return message.components(separatedBy: "\n").first
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case createdAt = "created_at"
        case repo
        case payload
    }
    
    func icon() -> String {
        switch type {
        case "PushEvent": return "arrow.up.circle"
        case "PullRequestEvent": return "arrow.triangle.pull"
        case "IssuesEvent": return "exclamationmark.circle"
        case "IssueCommentEvent": return "bubble.left"
        case "CreateEvent": return "plus.circle"
        case "DeleteEvent": return "minus.circle"
        case "ForkEvent": return "tuningfork"
        case "WatchEvent": return "star"
        default: return "circle"
        }
    }
    
    func description() -> String {
        switch type {
        case "PushEvent":
            let branch = payload?.branchName() ?? "main"
            let sha = payload?.shortHead() ?? ""
            return "\(sha) sur \(branch) — \(repo.name)"
        case "PullRequestEvent": return "PR sur \(repo.name)"
        case "IssuesEvent": return "Issue sur \(repo.name)"
        case "IssueCommentEvent": return "Commentaire sur \(repo.name)"
        case "CreateEvent": return "Création sur \(repo.name)"
        case "ForkEvent": return "Fork de \(repo.name)"
        case "WatchEvent": return "Watch \(repo.name)"
        default: return "Activité sur \(repo.name)"
        }
    }
    func iconColor() -> Color {
        switch type {
        case "PushEvent": return .green
        case "PullRequestEvent": return .purple
        case "IssuesEvent": return .orange
        case "IssueCommentEvent": return .blue
        case "CreateEvent": return .teal
        case "DeleteEvent": return .red
        case "ForkEvent": return .yellow
        case "WatchEvent": return .pink
        default: return .white.opacity(0.5)
        }
    }
    
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    /// URL GitHub vers laquelle ouvrir cet événement (commit pour un push, sinon le repo).
    func htmlURL() -> URL? {
        switch type {
        case "PushEvent":
            if let head = payload?.head {
                return URL(string: "https://github.com/\(repo.name)/commit/\(head)")
            }
            return URL(string: "https://github.com/\(repo.name)")
        default:
            return URL(string: "https://github.com/\(repo.name)")
        }
    }
}

//
//  EventRowView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct EventRowView: View {
    @Environment(GitHubViewModel.self) var gitHubViewModel
    let event: GithubEvent
    var showCommitMessage: Bool = false
    @State private var commitMessage: String?

    var body: some View {
        Button {
            if let url = event.htmlURL() {
                NSWorkspace.shared.open(url)
            }
        } label: {
            rowContent
        }
        .buttonStyle(.plain)
        .task {
            // L'endpoint events ne fournit pas les messages : on les charge à part.
            if showCommitMessage, commitMessage == nil {
                commitMessage = await gitHubViewModel.commitMessage(for: event)
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: 8) {
            // Icône branche
            Image(systemName: event.icon())
                .font(.system(size: 12))
                .foregroundStyle(event.iconColor())

            // Branche
            Text(event.branchName() ?? "merge")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(event.iconColor())
                .lineLimit(1)
                .frame(width: 60, alignment: .leading)

            // Repo
            Text(event.repo.name)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)

            // Message de commit tronqué sur la même ligne (vue activité).
            // Sinon une chaîne vide remplit l'espace pour pousser hash/temps à droite.
            Text(showCommitMessage ? (commitMessage ?? "") : "")
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(.white.opacity(0.45))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Hash
            Text(event.commitHash() ?? "")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))

            // Temps
            Text(event.timeAgo())
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(.white.opacity(0.3))
        }
    }
}
//#Preview {
//    EventRowView()
//}

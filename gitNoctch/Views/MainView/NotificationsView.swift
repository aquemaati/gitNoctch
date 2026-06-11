//
//  NotificationsView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 10/06/2026.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(GitHubViewModel.self) var gitHubViewModel
    @Binding var isNotificationsPresented: Bool

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 3) {
                if gitHubViewModel.notifications.isEmpty {
                    HStack {
                        Spacer()
                        Text("No notifications")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.white.opacity(0.4))
                        Spacer()
                    }
                    .padding(.top, 24)
                } else {
                    ForEach(gitHubViewModel.notifications, id: \.id) { notif in
                        Button {
                            Task { await gitHubViewModel.openNotification(notif) }
                        } label: {
                            NotificationRow(notif: notif)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
    }
}

/// Ligne factuelle d'une notification. Charge l'état (ouvert/fermé/fusionné)
/// du sujet pour afficher l'icône, la couleur et le libellé corrects.
private struct NotificationRow: View {
    @Environment(GitHubViewModel.self) private var gitHubViewModel
    let notif: GithubNotification

    /// État lu depuis le ViewModel (rafraîchi à chaque poll), jamais figé.
    private var detail: NotificationSubjectDetail? {
        gitHubViewModel.subjectDetails[notif.id]
    }

    var body: some View {
        HStack(spacing: 10) {
            // Icône GitHub colorée selon le type et l'état
            Image(systemName: notif.icon(detail))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(notif.iconColor(detail))
                .frame(width: 24, height: 24)
                .background(Circle().fill(notif.iconColor(detail).opacity(0.2)))
                .overlay(Circle().stroke(notif.iconColor(detail).opacity(0.4), lineWidth: 1))

            // Titre factuel + détails
            VStack(alignment: .leading, spacing: 2) {
                Text(notif.subject.title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(notif.unread ? 0.95 : 0.6))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    // Pastille d'état (Ouverte / Fermée / Fusionnée…)
                    if let status = notif.statusLabel(detail) {
                        Text(status)
                            .font(.system(size: 8, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(notif.iconColor(detail).opacity(0.25)))
                            .foregroundStyle(notif.iconColor(detail))
                    }

                    // Pastille raison (masquée si peu utile, ex. abonnement)
                    if let badge = notif.reasonBadge {
                        Text(badge)
                            .foregroundStyle(.white.opacity(0.45))
                    }

                    if let repo = notif.repoName {
                        Text(repo)
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(1)
                    }

                    if let number = notif.subjectNumber {
                        Text(number)
                            .foregroundStyle(.white.opacity(0.35))
                    }

                    Text(notif.timeAgo())
                        .foregroundStyle(.white.opacity(0.35))
                }
                .font(.system(size: 9, design: .rounded))
                .lineLimit(1)
            }

            Spacer()

            // Pastille bleue si non lue
            if notif.unread {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(notif.unread ? 0.06 : 0.02))
        )
    }
}

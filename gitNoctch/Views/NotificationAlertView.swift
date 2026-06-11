//
//  NotificationAlertView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 10/06/2026.
//

import SwiftUI

/// Popup affiché dans le notch à l'arrivée d'une nouvelle notification.
/// Présentation factuelle, identique à celle de la liste des notifications.
struct NotificationAlertView: View {
    let notification: GithubNotification
    let detail: NotificationSubjectDetail?

    var body: some View {
        HStack(spacing: 12) {
            // Badge icône coloré selon le type et l'état
            ZStack {
                Circle()
                    .fill(notification.iconColor(detail).opacity(0.22))
                Image(systemName: notification.icon(detail))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(notification.iconColor(detail))
            }
            .frame(width: 40, height: 40)
            .overlay(Circle().stroke(notification.iconColor(detail).opacity(0.45), lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                // Titre factuel de l'issue/PR
                Text(notification.subject.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Ligne de détails
                HStack(spacing: 8) {
                    // Pastille d'état (Ouverte / Fermée / Fusionnée…)
                    if let status = notification.statusLabel(detail) {
                        Text(status)
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(notification.iconColor(detail).opacity(0.25)))
                            .foregroundStyle(notification.iconColor(detail))
                    }

                    // Pastille raison (masquée si peu utile, ex. abonnement)
                    if let badge = notification.reasonBadge {
                        Text(badge)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    if let repo = notification.repoName {
                        HStack(spacing: 3) {
                            Image(systemName: "folder.fill")
                            Text(repo)
                                .lineLimit(1)
                        }
                        .foregroundStyle(.white.opacity(0.6))
                    }

                    if let number = notification.subjectNumber {
                        Text(number)
                            .foregroundStyle(.white.opacity(0.45))
                    }

                    Text(notification.timeAgo())
                        .foregroundStyle(.white.opacity(0.4))
                }
                .font(.system(size: 10, design: .rounded))
            }

            Spacer(minLength: 0)

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 14))
                .foregroundStyle(.red)
                .symbolRenderingMode(.multicolor)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: 440, alignment: .leading)
    }
}

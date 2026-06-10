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
                            notifRow(notif)
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

    func notifRow(_ notif: GithubNotification) -> some View {
        HStack(spacing: 10) {
            // Icône représentant la raison de la notification
            Image(systemName: notif.icon())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(notif.iconColor())
                .frame(width: 20, height: 20)
                .background(Circle().fill(notif.iconColor().opacity(0.18)))

            // Titre + date
            VStack(alignment: .leading, spacing: 1) {
                Text(notif.subject.title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(notif.unread ? 0.95 : 0.6))
                    .lineLimit(1)

                Text("\(notif.subject.type) · \(timeAgo(notif.updatedAt))")
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
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
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(notif.unread ? 0.06 : 0.02))
        )
    }

    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

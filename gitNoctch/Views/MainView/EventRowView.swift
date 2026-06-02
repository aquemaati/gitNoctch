//
//  EventRowView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct EventRowView: View {
    let event: GithubEvent
    
    var body: some View {
        HStack(spacing: 8) {
            // Icône branche
            Image(systemName: event.icon())
                .font(.system(size: 10))
                .foregroundStyle(event.iconColor())
            
            // Branche
            Text(event.branchName() ?? "")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(event.iconColor())
                .lineLimit(1)
                .frame(width: 60, alignment: .leading)
            
            // Repo
            Text(event.repo.name)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
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

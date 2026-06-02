//
//  UserStatsView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct UserStatsView: View {
    @Environment(GitHubViewModel.self) var gitHubViewModel
    
    var body: some View {
        HStack(spacing: 6) {
            Text("\(gitHubViewModel.viewer?.followers.totalCount ?? 0)")
                .foregroundStyle(.orange)
                .font(.system(size: 12, weight: .bold, design: .rounded))
            Text("Followers")
                .foregroundStyle(.white.opacity(0.5))
                .font(.system(size: 12, design: .rounded))
            
            Text("·")
                .foregroundStyle(.white.opacity(0.3))
            
            Text("\(gitHubViewModel.viewer?.repositories.totalCount ?? 0)")
                .foregroundStyle(.cyan)
                .font(.system(size: 12, weight: .bold, design: .rounded))
            Text("Repos")
                .foregroundStyle(.white.opacity(0.5))
                .font(.system(size: 12, design: .rounded))
        }
    }
}

#Preview {
    UserStatsView()
}

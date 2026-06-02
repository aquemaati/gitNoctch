//
//  MainView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct MainView: View {
    @Environment(AuthService.self) var authService
    @Environment(GitHubViewModel.self) var gitHubViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            leftBlock
            rightBlock
        }
        .frame(minWidth: 520, minHeight: 160)
    }
    
    var leftBlock: some View {
        HStack(alignment: .top, spacing: 16) {
            AvatarView()
            VStack(alignment: .leading, spacing: 12) {
                ContributionGridView()
                UserStatsView()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(width: 300)
    }
    
    var rightBlock: some View {
        VStack {
            Text("right")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainView()
}

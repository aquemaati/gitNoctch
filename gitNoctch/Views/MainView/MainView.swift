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
//        .frame(minWidth: 520, minHeight: 160)
    }
    
    var leftBlock: some View {
        HStack(alignment: .top, spacing: 16) {
            AvatarView()
            VStack(alignment: .leading, spacing: 12) {
                ContributionGridView()
                UserStatsView()
            }
        }
//        .padding(.trailing, )
        .padding(.vertical, 2)
//        .frame(width: 300)
    }
    
    var rightBlock: some View {
        let _ = print("events count: \(gitHubViewModel.events.count)")
        return VStack(alignment: .center, spacing: 14) {
            ActivityHeaderView()
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(gitHubViewModel.events.prefix(2), id: \.id) { event in
                    EventRowView(event: event)
                }
            }
            
//            Spacer()
            
            PRReviewButtonsView()
        }
        .padding(.leading, 24)
        .padding(.vertical, 2)
//        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainView()
}

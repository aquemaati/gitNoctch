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
    @State private var isSearchPresented = false
    @State private var searchText: String = ""

    

    var body: some View {
        ZStack(alignment: .top) {
            if isSearchPresented {
                SearchView(isSearchPresented: $isSearchPresented, searchText: $searchText)
                    .frame(width: 700, height: 100)
                    .transition(.opacity)
            } else {
                HStack(alignment: .top, spacing: 0) {
                    leftBlock
                    rightBlock
                }
                .frame(minWidth: 520)
                .transition(.opacity)
            }
            
            NotchTopBarView(isSearchPresented: $isSearchPresented, searchText: $searchText)
        }
        .animation(.easeInOut(duration: 0.3), value: isSearchPresented)
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
        return VStack(alignment: .center, spacing: 8) {
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

//
//  ContentView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthService.self) var authService
    @Environment(GitHubViewModel.self) var gitHubViewModel
    
    @State private var isSearching = false
    @State private var searchQuery = ""
    @State private var searchResults: [Repo] = []
    
    var unreadNotifs: [GithubNotification] {
        gitHubViewModel.notifications.filter(\.unread)
    }
    
    var body: some View {
        if authService.isAuthenticated {
            mainView
        } else {
            loginView
        }
    }
    
    // MARK: - Login
    var loginView: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("gitNotch")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("GitHub in your notch.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }
            Spacer()
            Button {
                authService.startOAuth()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.key.fill")
                    Text("Sign in with GitHub")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(.white)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
        .frame(minWidth: 420)
    }
    
    // MARK: - Main
    var mainView: some View {
        ZStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 0) {
                userBlock
                    .transition(.move(edge: .leading).combined(with: .opacity))
                
                Rectangle()
                    .fill(.white.opacity(0.07))
                    .frame(width: 1)
                    .padding(.vertical, 16)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                
                rightBlock
            }
            .opacity(isSearching ? 0 : 1)
            .offset(x: isSearching ? -30 : 0)
            
            if isSearching {
                searchFullView
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .frame(minWidth: 520, minHeight: 160)
        .animation(.spring(duration: 0.35), value: isSearching)
    }
    
    // MARK: - User Block
    var userBlock: some View {
        VStack(alignment: .center, spacing: 12) {
            KpiView(authService: authService)
            
            if let avatarUrl = authService.currentUser?.avatarUrl {
                AsyncImage(url: avatarUrl) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.12), lineWidth: 1))
                } placeholder: {
                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 52, height: 52)
                }
            }
            
            Text(authService.currentUser?.login ?? "...")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(spacing: 4) {
                Button {
                    if let url = authService.currentUser?.htmlURL {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 9))
                        Text("profile")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.07))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                Button {
                    authService.logout()
                    gitHubViewModel.stopPolling()
                } label: {
                    Text("logout")
                        .font(.system(size: 8, design: .rounded))
                        .foregroundStyle(.white.opacity(0.2))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(width: 130)
    }
    
    // MARK: - Right Block
    var rightBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            if !unreadNotifs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel("Notifications", icon: "bell.fill", badge: unreadNotifs.count)
                    ForEach(unreadNotifs.prefix(2), id: \.id) { notif in
                        Button {
                            if let url = URL(string: notif.subject.url) {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            notifRow(notif)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                
                Rectangle()
                    .fill(.white.opacity(0.07))
                    .frame(height: 1)
            }
            
            HStack {
                sectionLabel("Activity", icon: "bolt.fill")
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.white.opacity(0.07))
                .clipShape(Capsule())
                .onTapGesture {
                    withAnimation(.spring(duration: 0.35)) {
                        isSearching = true
                    }
                }
            }
            
            activityView
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring(duration: 0.4), value: unreadNotifs.isEmpty)
    }
    
    // MARK: - Activity View
    var activityView: some View {
        Group {
            if gitHubViewModel.isLoading {
                loadingView
            } else if gitHubViewModel.events.isEmpty {
                ghostText("nothing yet")
            } else {
                let maxEvents = unreadNotifs.isEmpty ? 4 : 3
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(gitHubViewModel.events.prefix(maxEvents), id: \.id) { event in
                        Button {
                            NSWorkspace.shared.open(
                                URL(string: "https://github.com/\(event.repo.name)")!
                            )
                        } label: {
                            eventRow(event)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Search Results View
    var searchResultsView: some View {
        Group {
            if searchQuery.isEmpty {
                ghostText("type to search your repos...")
            } else if searchResults.isEmpty {
                ghostText("no results for \"\(searchQuery)\"")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(searchResults.prefix(4), id: \.id) { repo in
                        Button {
                            NSWorkspace.shared.open(repo.htmlUrl)
                        } label: {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(.blue.opacity(0.15))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "folder.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.blue)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(repo.name)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.9))
                                    Text(repo.language ?? "no language")
                                        .font(.system(size: 10, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                                Spacer()
                                Text(repo.lastActivity())
                                    .font(.system(size: 9, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.2))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Search Full View
    var searchFullView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionLabel("Search", icon: "magnifyingglass")
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.9))
                    
                    TextField("Search repos...", text: $searchQuery)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.white)
                        .textFieldStyle(.plain)
                        .frame(width: 160)
                        .onChange(of: searchQuery) { _, newValue in
                            Task {
                                searchResults = await gitHubViewModel.searchRepos(query: newValue)
                            }
                        }
                    
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            isSearching = false
                            searchQuery = ""
                            searchResults = []
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.07))
                .clipShape(Capsule())
            }
            
            searchResultsView
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Rows
    func eventRow(_ event: GithubEvent) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(event.iconColor().opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: event.icon())
                    .font(.system(size: 12))
                    .foregroundStyle(event.iconColor())
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(event.description())
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                Text(event.repo.name)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
    }
    
    func notifRow(_ notif: GithubNotification) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(notif.iconColor().opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: notif.icon())
                    .font(.system(size: 12))
                    .foregroundStyle(notif.iconColor())
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(notif.subject.title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                Text(notif.reason)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
            }
            Spacer()
            Circle()
                .fill(.blue)
                .frame(width: 6, height: 6)
        }
    }
    
    // MARK: - Helpers
    func sectionLabel(_ title: String, icon: String, badge: Int = 0) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .semibold))
            Text(title.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .rounded))
                .kerning(1.2)
            if badge > 0 {
                Text("\(badge)")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(.white)
                    .clipShape(Capsule())
            }
        }
        .foregroundStyle(.secondary)
    }
    
    var loadingView: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 5, height: 5)
            }
        }
    }
    
    func ghostText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, design: .rounded))
            .foregroundStyle(.white.opacity(0.2))
    }
}

#Preview {
    let authService = AuthService()
    let gitHubService = GitHubService(authService: authService)
    let gitHubViewModel = GitHubViewModel(gitHubService: gitHubService)
    
    ContentView()
        .environment(authService)
        .environment(gitHubViewModel)
        .background(.black)
        .frame(width: 520, height: 170)
}

//
//  GitHubViewModel.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 29/05/2026.
//

import Foundation

@Observable
class GitHubViewModel {
    // data
    var notifications: [GithubNotification] = []
    var events: [GithubEvent] = []
    var repos: [Repo] = []
    var isLoading: Bool = false

    // Pooling
    private var pollingTask: Task<Void, Never>?
    private let gitHubService: GitHubService

    init(gitHubService: GitHubService) {
        self.gitHubService = gitHubService
    }

    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                await fetchAll()
                try? await Task.sleep(for: .seconds(60))
            }
        }
    }
    
    func stopPolling() {
            pollingTask?.cancel()
            pollingTask = nil
        }

    func fetchAll() async {
        print("fetchAll called — token: \(gitHubService.authService.token ?? "nil")")
        isLoading = true
        async let n = gitHubService.fetchNotifications()
        async let e = gitHubService.fetchEvents()
        async let r = gitHubService.fetchUserRepos()
        notifications = await n ?? []
        events = await e ?? []
        repos = await r ?? []
        isLoading = false

    }
    func searchRepos(query: String) async -> [Repo] {
        return await gitHubService.fetchUserRepos(query: query) ?? []
    }
}

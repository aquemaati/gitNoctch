//
//  GitHubViewModel.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 29/05/2026.
//

import Foundation
import SwiftUI
//internal import Combine

@Observable
class GitHubViewModel {
    
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
                try? await Task.sleep(for: .seconds(20))
            }
        }
    }
    
    func stopPolling() {
            pollingTask?.cancel()
            pollingTask = nil
        }

    func fetchAll() async {
        print("fetchAll called")
        isLoading = true
        async let n = gitHubService.fetchNotifications()
        async let e = gitHubService.fetchEvents()
        let fetchedNotifs = await n ?? []
        let fetchedEvents = await e ?? []
        
        fetchedEvents.indices.forEach { index in
            print("EVENT: \(fetchedEvents[index].repo.name), \(fetchedEvents[index].type), \(fetchedEvents[index].createdAt)")
        }
        print("fetchAll done — events: \(fetchedEvents.count), notifs: \(fetchedNotifs.count)")
        print("------------------------------------------------------------------------")
        
        fetchedNotifs.forEach { notification in
            print("NOTIF: \(notification.unread), \(notification.reason), \(notification.subject), \(notification.updatedAt)")
        }
        await MainActor.run {
            self.notifications = fetchedNotifs
            self.events = fetchedEvents
            self.isLoading = false
        }
        print("fetchAll MainActor done — viewModel.events: \(self.events.count)")
    }
    
    func searchRepos(query: String) async -> [Repo] {
        return await gitHubService.fetchUserRepos(query: query) ?? []
    }
    
    
    func openNotification(_ notif: GithubNotification) async {
        let subjectUrl = notif.subject.url
        guard let htmlUrl = await gitHubService.fetchNotificationHtmlUrl(subjectUrl),
              let url = URL(string: htmlUrl) else { return }
        NSWorkspace.shared.open(url)
    }
}

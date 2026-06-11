//
//  GitHubViewModel.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 29/05/2026.
//

import Foundation
import SwiftUI

@Observable
class GitHubViewModel {
    
    // MARK: - State
    var viewer: ViewerUser?
    var contributions: ContributionCalendar?
    var events: [GithubEvent] = []
    var notifications: [GithubNotification] = []
    var repositories: [Repository] = []
    var pullRequestsCount: Int = 0
    var reviewsCount: Int = 0
    var isLoading: Bool = false

    /// Cache des messages de commit par identifiant d'événement (évite de re-fetch).
    private var commitMessages: [String: String] = [:]

    /// Identifiants de notifications déjà vues (pour détecter les nouvelles).
    private var seenNotificationIDs: Set<String> = []
    private var didSeedNotifications = false

    /// Appelé quand une nouvelle notification non lue est détectée lors d'un poll.
    var onNewNotification: ((GithubNotification) async -> Void)?
    
    // MARK: - Private
    private var pollingTask: Task<Void, Never>?
    private let gitHubService: GitHubService

    init(gitHubService: GitHubService) {
        self.gitHubService = gitHubService
    }

    // MARK: - Polling
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

    // MARK: - Fetch
    func fetchAll() async {
        
        isLoading = true
        
        
        let fetchedViewer = await gitHubService.fetchViewer()

//        async let v = gitHubService.fetchViewer()
        async let c = gitHubService.fetchContributions()
        async let e = gitHubService.fetchEvents(login: fetchedViewer?.login ?? "")
        
        async let n = gitHubService.fetchNotifications()
        async let pr = gitHubService.fetchPullRequestsAndReviews()
        async let r = gitHubService.fetchRepositories()
        
//        let fetchedViewer = await v
        let fetchedContributions = await c
        let fetchedEvents = await e ?? []
        print("fetched events raw: \(fetchedEvents.count)")

        let fetchedNotifs = await n ?? []
        let fetchedPR = await pr
        let fetchedRepos = await r
        
        await MainActor.run {
            self.viewer = fetchedViewer
            self.contributions = fetchedContributions
            self.events = fetchedEvents
            self.notifications = fetchedNotifs
            self.pullRequestsCount = fetchedPR?.prs ?? 0
            self.reviewsCount = fetchedPR?.reviews ?? 0
            self.repositories = fetchedRepos?.repos ?? []
            self.isLoading = false
        }
        await detectNewNotifications(fetchedNotifs)
        print("fetchAll done — events: \(fetchedEvents.count)")
    }

    /// Détecte les notifications non lues apparues depuis le dernier poll et
    /// déclenche `onNewNotification` pour la plus récente (évite le spam).
    private func detectNewNotifications(_ notifs: [GithubNotification]) async {
        let currentIDs = Set(notifs.map(\.id))

        // Premier chargement : on mémorise sans alerter.
        guard didSeedNotifications else {
            didSeedNotifications = true
            seenNotificationIDs = currentIDs
            return
        }

        let newOnes = notifs.filter { $0.unread && !seenNotificationIDs.contains($0.id) }
        seenNotificationIDs.formUnion(currentIDs)

        if let latest = newOnes.sorted(by: { $0.updatedAt > $1.updatedAt }).first {
            await onNewNotification?(latest)
        }
    }
    
    // MARK: - Repos
    func loadMoreRepositories(after cursor: String) async {
        let result = await gitHubService.fetchRepositories(after: cursor)
        await MainActor.run {
            self.repositories.append(contentsOf: result?.repos ?? [])
        }
    }
    
    func searchRepositories(query: String) async {
        let result = await gitHubService.fetchRepositories(query: query)
        await MainActor.run {
            self.repositories = result?.repos ?? []
        }
    }
    
    // MARK: - Commit messages
    /// Renvoie la première ligne du message de commit d'un PushEvent (avec cache).
    func commitMessage(for event: GithubEvent) async -> String? {
        if let cached = commitMessages[event.id] { return cached }
        guard event.type == "PushEvent",
              let sha = event.payload?.head else { return nil }
        let message = await gitHubService.fetchCommitMessage(repoFullName: event.repo.name, sha: sha)
        if let message {
            await MainActor.run { self.commitMessages[event.id] = message }
        }
        return message
    }

    // MARK: - Notifications
    /// Cache des détails d'état (ouvert/fermé/fusionné) par identifiant de notification.
    private var subjectDetailsCache: [String: NotificationSubjectDetail] = [:]

    /// Récupère (avec cache) l'état du sujet d'une notification.
    func subjectDetail(for notif: GithubNotification) async -> NotificationSubjectDetail? {
        if let cached = subjectDetailsCache[notif.id] { return cached }
        guard let detail = await gitHubService.fetchSubjectDetail(url: notif.subject.url) else { return nil }
        await MainActor.run { self.subjectDetailsCache[notif.id] = detail }
        return detail
    }

    func openNotification(_ notif: GithubNotification) async {
        let subjectUrl = notif.subject.url
        guard let htmlUrl = await gitHubService.fetchNotificationHtmlUrl(subjectUrl),
              let url = URL(string: htmlUrl) else { return }
        NSWorkspace.shared.open(url)
    }
}

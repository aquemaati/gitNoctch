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

    /// Dernière date `updatedAt` vue par fil de notification (pour détecter les nouveautés,
    /// même quand GitHub réutilise le même id pour un nouvel événement, ex. clôture d'issue).
    private var seenNotificationDates: [String: Date] = [:]
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
                try? await Task.sleep(for: .seconds(20))
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
        await refreshSubjectDetails(for: fetchedNotifs)
        print("fetchAll done — events: \(fetchedEvents.count)")
    }

    /// Rafraîchit l'état (ouvert/fermé/fusionné) de toutes les notifications à chaque poll,
    /// pour éviter d'afficher un statut périmé (le fil GitHub réutilise le même id).
    private func refreshSubjectDetails(for notifs: [GithubNotification]) async {
        let items: [(id: String, owner: String, repo: String, number: Int)] = notifs.compactMap { notif in
            guard let (owner, repo) = notif.ownerAndRepo,
                  let number = notif.subjectNumberValue else { return nil }
            return (notif.id, owner, repo, number)
        }
        guard !items.isEmpty else {
            await MainActor.run { self.subjectDetails = [:] }
            return
        }

        // Une seule requête GraphQL groupée pour tous les sujets.
        let results = await gitHubService.fetchSubjectStates(for: items)
        await MainActor.run { self.subjectDetails = results }
    }

    /// Détecte les notifications non lues apparues depuis le dernier poll et
    /// déclenche `onNewNotification` pour la plus récente (évite le spam).
    private func detectNewNotifications(_ notifs: [GithubNotification]) async {
        // Premier chargement : on mémorise les dates sans alerter.
        guard didSeedNotifications else {
            didSeedNotifications = true
            for notif in notifs { seenNotificationDates[notif.id] = notif.updatedAt }
            return
        }

        // Nouveau = non lu ET (jamais vu OU date d'activité plus récente que la dernière vue).
        // Détecte aussi les nouveaux événements sur un fil existant (ex. clôture d'issue).
        let newOnes = notifs.filter { notif in
            guard notif.unread else { return false }
            if let lastSeen = seenNotificationDates[notif.id] {
                return notif.updatedAt > lastSeen
            }
            return true
        }

        for notif in notifs { seenNotificationDates[notif.id] = notif.updatedAt }

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
    /// État (ouvert/fermé/fusionné) par identifiant de notification, rafraîchi à chaque poll.
    var subjectDetails: [String: NotificationSubjectDetail] = [:]

    /// Récupère l'état frais du sujet d'une notification via GraphQL (utilisé par le popup).
    func subjectDetail(for notif: GithubNotification) async -> NotificationSubjectDetail? {
        guard let (owner, repo) = notif.ownerAndRepo,
              let number = notif.subjectNumberValue,
              let detail = await gitHubService.fetchSubjectState(owner: owner, repo: repo, number: number) else { return nil }
        await MainActor.run { self.subjectDetails[notif.id] = detail }
        return detail
    }

    func openNotification(_ notif: GithubNotification) async {
        // Ouvre la page GitHub correspondante.
        if let subjectUrl = notif.subject.url,
           let htmlUrl = await gitHubService.fetchNotificationHtmlUrl(subjectUrl),
           let url = URL(string: htmlUrl) {
            NSWorkspace.shared.open(url)
        }

        // Marque comme lue côté GitHub + mise à jour optimiste immédiate de l'UI.
        await gitHubService.markNotificationAsRead(id: notif.id)
        await MainActor.run {
            self.notifications.removeAll { $0.id == notif.id }
        }
    }
}

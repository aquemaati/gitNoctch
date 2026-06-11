//
//  gitNoctchApp.swift
//  gitNotch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

internal import Combine
import DynamicNotchKit
import SwiftUI

@main
struct GitNotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("gitNotch", systemImage: "bell.badge") {
            Button("Quitter", role: .destructive) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    var authService = AuthService()

    lazy var gitHubService: GitHubService = GitHubService(
        authService: authService
    )
    lazy var gitHubViewModel: GitHubViewModel = GitHubViewModel(
        gitHubService: gitHubService
    )

    var notch: DynamicNotch<NotchContentWrapper, GitNotchCompactLeadingView, GitNotchCompactTrailingView>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Présente automatiquement un popup à chaque nouvelle notification.
        gitHubViewModel.onNewNotification = { [weak self] notif in
            await self?.presentNotificationAlert(for: notif)
        }

        if let token = authService.getToken() {
            authService.token = token
            authService.isAuthenticated = true
            Task {
                await gitHubViewModel.fetchAll()
                gitHubViewModel.startPolling()
            }
        }

        notch = DynamicNotch<NotchContentWrapper, GitNotchCompactLeadingView, GitNotchCompactTrailingView>(
            style: .notch(topCornerRadius: 25, bottomCornerRadius: 45),
            expanded: {
                NotchContentWrapper(
                    authService: self.authService,
                    gitHubViewModel: self.gitHubViewModel
                )
            },
            compactLeading: { GitNotchCompactLeadingView() },
            compactTrailing: { GitNotchCompactTrailingView() }
        )

        Task {
            await notch?.compact()
            guard let notch else { return }
            for await isHovering in notch.$isHovering.values {
                if isHovering {
                    await notch.expand()
                } else {
                    await notch.compact()
                }
            }
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        guard
            let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "code" })?.value
        else { return }
        Task {
            await authService.handleCallback(code: code)
            await gitHubViewModel.fetchAll()
            gitHubViewModel.startPolling()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        gitHubViewModel.stopPolling()
    }

    /// Affiche la notification (même présentation factuelle que la liste) dans le notch.
    func presentNotificationAlert(for notif: GithubNotification) async {
        // On pré-charge l'état (ouvert/fermé/fusionné) pour l'afficher dans le popup.
        let detail = await gitHubViewModel.subjectDetail(for: notif)

        let alert = DynamicNotch(
            style: .notch(topCornerRadius: 25, bottomCornerRadius: 45),
            expanded: {
                NotificationAlertView(notification: notif, detail: detail) { [weak self] in
                    // Clic sur le popup → ouvre la page GitHub correspondante.
                    Task { await self?.gitHubViewModel.openNotification(notif) }
                }
            },
            compactLeading: {
                Image(systemName: notif.icon(detail))
                    .foregroundStyle(notif.iconColor(detail))
            },
            compactTrailing: {
                Image(systemName: "bell.badge.fill")
                    .foregroundStyle(.red)
            }
        )

        // On ne touche PAS au notch principal (sa boucle de hover tourne en
        // continu) : manipuler le même notch en concurrence fait fuiter une
        // continuation. On présente simplement ce popup indépendant.
        await alert.expand()
        try? await Task.sleep(for: .seconds(5))
        await alert.hide()
    }
}

struct NotchContentWrapper: View {
    let authService: AuthService
    let gitHubViewModel: GitHubViewModel

    var body: some View {
        ContentView()
            .environment(authService)
            .environment(gitHubViewModel)
    }
}

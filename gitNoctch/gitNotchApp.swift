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

    var notch:
        DynamicNotch<
            NotchContentWrapper, GitNotchCompactLeadingView,
            GitNotchCompactTrailingView
        >?

    func applicationDidFinishLaunching(_ notification: Notification) {

        //récupération du token
        if let token = authService.getToken() {
            authService.token = token
            authService.isAuthenticated = true
            Task {
                authService.currentUser = await gitHubService.fetchUser()
            }
            gitHubViewModel.startPolling()
        }
        let notch = DynamicNotch<
            NotchContentWrapper, GitNotchCompactLeadingView,
            GitNotchCompactTrailingView
        >(
            style: .auto,
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
            await notch.compact()
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
            let code = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )?.queryItems?.first(where: { $0.name == "code" })?.value
        else { return }
        Task {
            await authService.handleCallback(code: code)
            authService.currentUser = await gitHubService.fetchUser()
            gitHubViewModel.startPolling()

        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        gitHubViewModel.stopPolling()
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

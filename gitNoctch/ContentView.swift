//
//  ContentView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthService.self) var authService
    @Environment(GitHubService.self) var gitHubService
    @State private var user: User? = nil
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, gitNotch!")
            if authService.isAuthenticated {
                if let avatarUrl = user?.avatarUrl {
                    AsyncImage(url: avatarUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                }
                Text("Connecté en tant que \(user?.login ?? "...")")
                if let htmlURL = user?.htmlURL {
                    Link("Voir le profil", destination: htmlURL)
                }
                Button("Logout") {
                    authService.logout()
                    user = nil
                }
            } else {
                Button("Login") {
                    authService.startOAuth()
                }
            }
        }
        .padding()
        .task(id: authService.isAuthenticated) {
            guard authService.isAuthenticated else { return }
            user = await gitHubService.fetchUser()
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthService())
        .environment(GitHubService(authService: AuthService()))
}

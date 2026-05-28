//
//  ContentView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthService.self) var authService
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, gitNotch!")
            if authService.isAuthenticated {
                Text("You are currently logged in")
                Button("Logout") {
                    authService.logout()
                }
            } else {
                Button("Login") {
                    authService.startOAuth()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environment(AuthService())
}

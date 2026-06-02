//
//  ContentView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        @Environment(AuthService.self) var authService
        @Environment(GitHubViewModel.self) var githubViewModel
        MainView()
        //
    }
}

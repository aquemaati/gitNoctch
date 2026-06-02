//
//  MainView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct MainView: View {
    @Environment(AuthService.self) var authService
    @Environment(GitHubViewModel.self) var gitHubViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            AvatarView()
            Spacer()
        }
    }
}

#Preview {
    MainView()
}

//
//  NotchTopBarView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct NotchTopBarView: View {
    @Environment(GitHubViewModel.self) var gitHubViewModel
    var body: some View {
        HStack {
            // Loupe à gauche
            Button {
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .buttonStyle(.plain)

            Spacer()

            // Login + cloche à droite
            HStack(spacing: 8) {
                Text(gitHubViewModel.viewer?.login ?? "")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))

                Button {
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .offset(y: -25)
    }
}

#Preview {
    NotchTopBarView()
}

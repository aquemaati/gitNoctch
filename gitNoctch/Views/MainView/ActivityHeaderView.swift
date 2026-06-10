//
//  ActivityHeaderView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct ActivityHeaderView: View {
    @Environment(GitHubViewModel.self) var gitHubViewModel

    var body: some View {
        HStack {
            Text("last Activty")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                if let login = gitHubViewModel.viewer?.login,
                   let url = URL(string: "https://github.com/\(login)?tab=overview") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Text("See all")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ActivityHeaderView()
}

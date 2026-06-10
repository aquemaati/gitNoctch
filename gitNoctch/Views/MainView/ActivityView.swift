//
//  ActivityView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 10/06/2026.
//

import SwiftUI

struct ActivityView: View {
    @Environment(GitHubViewModel.self) var gitHubViewModel
    @Binding var isActivityPresented: Bool

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 3) {
                if gitHubViewModel.events.isEmpty {
                    HStack {
                        Spacer()
                        Text("No activity")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.white.opacity(0.4))
                        Spacer()
                    }
                    .padding(.top, 24)
                } else {
                    ForEach(Array(gitHubViewModel.events.prefix(30)), id: \.id) { event in
                        EventRowView(event: event, showCommitMessage: true)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white.opacity(0.04))
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
    }
}

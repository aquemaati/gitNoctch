//
//  PRReviewButtonsView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct PRReviewButtonsView: View {
    @Environment(GitHubViewModel.self) var gitHubViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                if let url = URL(string: "https://github.com/pulls") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                HStack(spacing: 6) {
                    Text("\(gitHubViewModel.pullRequestsCount)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                    Text("Pull Requests")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [.blue.opacity(0.4), .indigo.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            
            Button {
                if let url = URL(string: "https://github.com/pulls/review-requested") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                HStack(spacing: 6) {
                    Text("\(gitHubViewModel.reviewsCount)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.purple)
                    Text("Code Reviews")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [.purple.opacity(0.4), .pink.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    PRReviewButtonsView()
}

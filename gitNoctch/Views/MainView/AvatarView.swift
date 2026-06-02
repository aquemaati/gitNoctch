//
//  AvatarView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct AvatarView: View {
    @Environment(GitHubViewModel.self) var gitHubViewModel

    var body: some View {
        AsyncImage(url: gitHubViewModel.viewer?.avatarUrl) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        } placeholder: {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.08))
                .frame(width: 96, height: 96)
        }
    }
}
#Preview {
    AvatarView()
}

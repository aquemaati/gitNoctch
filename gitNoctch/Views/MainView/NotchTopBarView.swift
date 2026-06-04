//
//  NotchTopBarView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct NotchTopBarView: View {
    @Environment(GitHubViewModel.self) var gitHubViewModel
    @Binding var isSearchPresented: Bool
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            // Loupe ou barre de recherche à gauche
            if isSearchPresented {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    TextField("Search repos...", text: $searchText)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.white)
                        .textFieldStyle(.plain)
                        .frame(width: 140)
                    
                    Button {
                        isSearchPresented = false
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.white.opacity(0.1))
                .clipShape(Capsule())
            } else {
                Button {
                    isSearchPresented = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Login + cloche — toujours visibles
            HStack(spacing: 8) {
                Text(gitHubViewModel.viewer?.login ?? "")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))

                Button { } label: {
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
    NotchTopBarView(isSearchPresented: .constant(false), searchText: .constant(""))
}

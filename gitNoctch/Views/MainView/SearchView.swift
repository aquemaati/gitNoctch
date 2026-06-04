//
//  SearchView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 03/06/2026.
//

import SwiftUI

struct SearchView: View {
    @Environment(GitHubViewModel.self) var gitHubViewModel
    @Binding var isSearchPresented: Bool
    @Binding var searchText: String
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(gitHubViewModel.repositories, id: \.nameWithOwner) { repo in
                    Button {
                        NSWorkspace.shared.open(repo.url)
                    } label: {
                        repoRow(repo)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
//        .frame(minWidth: 520, maxHeight: 200)
        .onChange(of: searchText) { _, newValue in
            Task {
                await gitHubViewModel.searchRepositories(query: newValue)
            }
        }
    }
    
    func repoRow(_ repo: Repository) -> some View {
        HStack(spacing: 10) {
            // Icône langage placeholder
            Circle()
                .fill(.white.opacity(0.1))
                .frame(width: 20, height: 20)
                .overlay(
                    Text(String(repo.primaryLanguage?.name.prefix(1) ?? "?"))
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.5))
                )
            
            // Nom
            Text(repo.nameWithOwner)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
            
            Spacer()
            
            // Forks
            if repo.forkCount > 0 {
                HStack(spacing: 3) {
                    Image(systemName: "tuningfork")
                        .font(.system(size: 9))
                    Text("\(repo.forkCount)")
                        .font(.system(size: 10))
                }
                .foregroundStyle(.white.opacity(0.4))
            }
            
            // Licence
            if let license = repo.licenseInfo?.spdxId {
                HStack(spacing: 3) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 9))
                    Text(license)
                        .font(.system(size: 10))
                }
                .foregroundStyle(.white.opacity(0.4))
            }
            
            // Stars
            if repo.stargazerCount > 0 {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.yellow)
                    Text("\(repo.stargazerCount)")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            
            // Cadenas si privé
            if repo.isPrivate {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
    }
}

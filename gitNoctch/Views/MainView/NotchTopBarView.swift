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
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        HStack {
            // Loupe fixe + barre de recherche qui s'étend
            HStack(spacing: 0) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isSearchPresented.toggle()
                        if !isSearchPresented {
                            searchText = ""
                            isSearchFocused = false
                        } else {
                            isSearchFocused = true
                        }
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                
                HStack(spacing: 6) {
                    TextField("Search repos...", text: $searchText)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.white)
                        .textFieldStyle(.plain)
                        .frame(width: isSearchPresented ? 120 : 0)
                        .focused($isSearchFocused)
                        .opacity(isSearchPresented ? 1 : 0)
                    
                    if isSearchPresented {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                searchText = ""
                                isSearchPresented = false
                                isSearchFocused = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity)
                    }
                }
                .padding(.leading, isSearchPresented ? 6 : 0)
                .padding(.trailing, isSearchPresented ? 10 : 0)
                .padding(.vertical, isSearchPresented ? 5 : 0)
                .frame(width: isSearchPresented ? nil : 0)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.1))
                        .opacity(isSearchPresented ? 1 : 0)
                )
                .clipped()
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

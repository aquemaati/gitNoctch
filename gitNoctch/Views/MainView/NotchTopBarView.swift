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
    @Binding var isNotificationsPresented: Bool
    @FocusState private var isSearchFocused: Bool

    private var unreadCount: Int {
        gitHubViewModel.notifications.filter { $0.unread }.count
    }

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
                            isNotificationsPresented = false
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
                    if isSearchPresented {
                        ZStack(alignment: .leading) {
                            if searchText.isEmpty {
                                Text("Search repos...")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .allowsHitTesting(false)
                            }
                            
                            TextField("", text: $searchText)
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(.white)
                                .textFieldStyle(.plain)
                                .focused($isSearchFocused)
                        }
                        .frame(width: 120)
                        .transition(.opacity)
                    }
                    
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
                Button {
                    if let login = gitHubViewModel.viewer?.login,
                       let url = URL(string: "https://github.com/\(login)") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Text(gitHubViewModel.viewer?.login ?? "")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isNotificationsPresented.toggle()
                        if isNotificationsPresented {
                            isSearchPresented = false
                            searchText = ""
                            isSearchFocused = false
                        }
                    }
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(isNotificationsPresented ? .white : .white.opacity(0.7))
                        .overlay(alignment: .topTrailing) {
                            if unreadCount > 0 {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 6, height: 6)
                                    .offset(x: 3, y: -2)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .offset(y: -34)
    }
}

#Preview {
    NotchTopBarView(
        isSearchPresented: .constant(false),
        searchText: .constant(""),
        isNotificationsPresented: .constant(false)
    )
}

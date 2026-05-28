//
//  GitHubService.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import Foundation

@Observable
class GitHubService {
    let baseURL: URL = URL(string: "https://api.github.com")!
    let session = URLSession.shared
    
    let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    // MARK: - User
    
    func fetchUser() async -> User? {
       
       let url = baseURL.appendingPathComponent("user")

       var request = URLRequest(url: url)
       guard let token = authService.token else { return nil }
       request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
       
       do {
           let (data, _) = try await URLSession.shared.data(for: request)
           let user = try JSONDecoder().decode(User.self, from: data)
           return user

       } catch {
           print(error)
       }
       
       return nil
    }
    
    // MARK: - Notification
    
    func fetchNotifications() async -> [GithubNotification]? {

        let url = baseURL.appendingPathComponent("notifications")
        
        var request = URLRequest(url: url)
        guard let token = authService.token else { return nil }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let notifications = try decoder.decode([GithubNotification].self, from: data)
            return notifications
        } catch {
            print(error)
        }
        return nil
    }
    
    // MARK: - Repo
    func fetchUserRepos(query: String? = nil) async -> [Repo]? {
        let url = baseURL.appendingPathComponent("user/repos")
        
        var request = URLRequest(url: url)
        guard let token = authService.token else { return nil }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let repos = try decoder.decode([Repo].self, from: data)
            
            if let query = query {
                return repos.filter { $0.name.localizedCaseInsensitiveContains(query) }
            }
            return repos
        } catch {
            print(error)
        }
        return nil
    }
}

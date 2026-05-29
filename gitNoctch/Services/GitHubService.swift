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
    
    // MARK: - GithubEvent
    func fetchEvents() async -> [GithubEvent]? {
        guard let login = authService.currentUser?.login else { return nil }
        guard let token = authService.token else { return nil }
        
        let url = baseURL.appendingPathComponent("users/\(login)/events")
        
        // 1. Utiliser reloadIgnoringLocalCacheData pour éviter les données périmées
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 2. Ajouter un User-Agent (requis par GitHub)
        request.setValue("gitNotch/1.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                print("Erreur HTTP")
                return nil
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([GithubEvent].self, from: data)
        } catch {
            print("Erreur lors du décodage ou du réseau : \(error)")
            return nil
        }
    }
}

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
    
   func fetchUser() async -> User? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
       components.path.append("/user")
       
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

}

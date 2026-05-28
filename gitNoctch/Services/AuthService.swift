//
//  AuthService.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import AppKit
import Foundation

@Observable
class AuthService {

    var token: String? = nil
    var isAuthenticated: Bool = false

    let clientId: String = Secrets.clientId
    let clientSecret: String = Secrets.clientSecret
    let redirectUri: String = "gitnotch://callback"

    func startOAuth() {
        var components = URLComponents(
            string: "https://github.com/login/oauth/authorize"
        )
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: "notifications repo read:user"),
        ]
        if let url = components?.url {
            NSWorkspace.shared.open(url)
        }
    }

    func handleCallback(code: String) async {
        guard let token = await exchangeCode(code: code) else { return }
        saveToken(token)
        self.token = token
        self.isAuthenticated = true

    }
    func exchangeCode(code: String) async -> String? {
        var components = URLComponents(
            string: "https://github.com/login/oauth/access_token"
        )
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
        ]
        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(
                OAuthResponse.self,
                from: data
            )
            return response.accessToken

        } catch {
            print("exchangeCode error: \(error)")
            return nil
        }
    }

    private struct OAuthResponse: Codable {
        let accessToken: String

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }

    func saveToken(_ token: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "gitNotchToken",
            kSecValueData as String: token.data(using: .utf8)!,
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func logout() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "gitNotchToken",
        ]
        SecItemDelete(query as CFDictionary)
        token = nil
        isAuthenticated = false
    }
    
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "gitNotchToken",
            kSecReturnData as String: kCFBooleanTrue!,
        ]
        var data: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &data)
        guard status == errSecSuccess,
              let data = data as? Data,
              let token = String(data: data, encoding: .utf8)
        else { return nil }
        return token
    }
}

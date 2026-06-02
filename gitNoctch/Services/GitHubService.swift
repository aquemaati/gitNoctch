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

    func fetchViewer() async -> ViewerUser? {
        let query = """
            {
               viewer {
                    login
                    avatarUrl
                    url
                    followers {
                     totalCount
                    }
                    repositories {
                        totalCount
                    }
                }
            }
            """

        guard let data = await fetchGraphQL(query: query) else { return nil }

        return try? JSONDecoder().decode(ViewerResponse.self, from: data).data.viewer
    }
    
    func fetchContributions() async -> ContributionCalendar? {
        let query = """
        {
          viewer {
            contributionsCollection {
              contributionCalendar {
                weeks {
                  contributionDays {
                    date
                    contributionCount
                    color
                  }
                }
              }
            }
          }
        }
        """
        
        guard let data = await fetchGraphQL(query: query) else { return nil }
        return try? JSONDecoder().decode(ContributionResponse.self, from: data).data.viewer.contributionsCollection.contributionCalendar
    }
    
    func fetchPullRequestsAndReviews() async -> (prs: Int, reviews: Int)? {
        let query = """
        {
          viewer {
            pullRequests(states: OPEN) {
              totalCount
            }
          }
          search(query: "is:pr is:open review-requested:@me", type: ISSUE) {
            issueCount
          }
        }
        """
        
        guard let data = await fetchGraphQL(query: query) else { return nil }
        guard let response = try? JSONDecoder().decode(PullRequestsResponse.self, from: data) else { return nil }
        return (
            prs: response.data.viewer.pullRequests.totalCount,
            reviews: response.data.search.issueCount
        )
    }
    
    func fetchRepositories(query: String = "", after: String? = nil) async -> (repos: [Repository], nextCursor: String?)? {
        let afterClause = after.map { ", after: \"\($0)\"" } ?? ""
        
        if query.isEmpty {
            let gqlQuery = """
            {
              viewer {
                repositories(first: 50, orderBy: {field: PUSHED_AT, direction: DESC}\(afterClause)) {
                  pageInfo {
                    hasNextPage
                    endCursor
                  }
                  nodes {
                    name
                    nameWithOwner
                    url
                    isPrivate
                    stargazerCount
                    forkCount
                    pushedAt
                    primaryLanguage { name }
                    licenseInfo { spdxId }
                  }
                }
              }
            }
            """
            guard let data = await fetchGraphQL(query: gqlQuery) else { return nil }
            guard let response = try? JSONDecoder().decode(RepositoryResponse.self, from: data) else { return nil }
            let connection = response.data.viewer.repositories
            return (
                repos: connection.nodes,
                nextCursor: connection.pageInfo.hasNextPage ? connection.pageInfo.endCursor : nil
            )
            
        } else {
            let gqlQuery = """
            {
              search(query: "user:@me \(query) fork:false", type: REPOSITORY, first: 50\(afterClause)) {
                pageInfo {
                  hasNextPage
                  endCursor
                }
                nodes {
                  ... on Repository {
                    name
                    nameWithOwner
                    url
                    isPrivate
                    stargazerCount
                    forkCount
                    pushedAt
                    primaryLanguage { name }
                    licenseInfo { spdxId }
                  }
                }
              }
            }
            """
            guard let data = await fetchGraphQL(query: gqlQuery) else { return nil }
            guard let response = try? JSONDecoder().decode(SearchRepositoryResponse.self, from: data) else { return nil }
            let connection = response.data.search
            return (
                repos: connection.nodes,
                nextCursor: connection.pageInfo.hasNextPage ? connection.pageInfo.endCursor : nil
            )
        }
    }

    // MARK: - Notification

    func fetchNotifications() async -> [GithubNotification]? {
        guard let token = authService.token else { return nil }

        let url = baseURL.appendingPathComponent("notifications")
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 10
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("gitNotch/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            guard let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode)
            else {
                print("Erreur HTTP notifications")
                return nil
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([GithubNotification].self, from: data)
        } catch {
            print("Erreur notifications : \(error)")
        }
        return nil
    }

    func fetchNotificationHtmlUrl(_ apiUrl: String) async -> String? {
        guard let token = authService.token else { return nil }
        guard let url = URL(string: apiUrl) else { return nil }

        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 10
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("gitNotch/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )
            guard let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode)
            else { return nil }

            if let json = try JSONSerialization.jsonObject(with: data)
                as? [String: Any],
                let htmlUrl = json["html_url"] as? String
            {
                return htmlUrl
            }
        } catch {
            print("Erreur fetchNotificationHtmlUrl: \(error)")
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
                return repos.filter {
                    $0.name.localizedCaseInsensitiveContains(query)
                }
            }
            return repos
        } catch {
            print(error)
        }
        return nil
    }

    // MARK: - GithubEvent
    func fetchEvents(login: String) async -> [GithubEvent]? {
//        guard let login = authService.currentUser?.login else { return nil }
        guard let token = authService.token else { return nil }

        let url = baseURL.appendingPathComponent("users/\(login)/events")

        // 1. Utiliser reloadIgnoringLocalCacheData pour éviter les données périmées
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 10
        )

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 2. Ajouter un User-Agent (requis par GitHub)
        request.setValue("gitNotch/1.0", forHTTPHeaderField: "User-Agent")
        print("fetchEvents token: \(authService.token?.prefix(10) ?? "nil")")


        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            guard let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode)
            else {
                print("Erreur HTTP")
                return nil
            }
            print(String(data: data, encoding: .utf8) ?? "no data")

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([GithubEvent].self, from: data)
        } catch {
            print("Erreur lors du décodage ou du réseau : \(error)")
            return nil
        }
    }

    // MARK: - Graphql api
    func fetchGraphQL(query: String) async -> Data? {
        guard let token = authService.token else { return nil }

        let url = URL(string: "https://api.github.com/graphql")!

        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 10
        )
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gitNotch/1.0", forHTTPHeaderField: "User-Agent")

        let body = ["query": query]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            guard let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode)
            else { return nil }
            return data
        } catch {
            print("GraphQL error: \(error)")
        }

        return nil
    }
}

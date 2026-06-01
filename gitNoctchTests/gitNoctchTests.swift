//
//  gitNoctchTests.swift
//  gitNoctchTests
//
//  Created by Mathias Marchetti on 01/06/2026.
//

import Testing

@testable import gitNoctch

struct gitNoctchTests {
    @Test @MainActor func returnsNilWhenNoToken() async {
        let authService = AuthService()
        let githubService = GitHubService(authService: authService)
        // authService.token est nil par défaut
        let token = authService.getToken()
        print(token ?? "no token")
        let result = await githubService.fetchGraphQL(
            query: "{ viewer { login } }"
        )
        #expect(result == nil)
    }

    @Test @MainActor func fetchGraqlReturnsDats() async {
        let authService = AuthService()
        authService.token = authService.getToken()
        let githubService = GitHubService(authService: authService)

        let result = await githubService.fetchViewer()
        print(result ?? "no result")
        #expect(result != nil)
    }
    
    @Test @MainActor func fetchContributionsReturnsData() async {
        let authService = AuthService()
        authService.token = authService.getToken()
        let githubService = GitHubService(authService: authService)
        
        let result = await githubService.fetchContributions()
        print(result ?? "nil")
        #expect(result != nil)
        #expect(result?.weeks.isEmpty == false)
    }
    
    @Test @MainActor func fetchPullRequestsAndReviewsReturnsData() async {
        let authService = AuthService()
        authService.token = authService.getToken()
        let githubService = GitHubService(authService: authService)
        
        let result = await githubService.fetchPullRequestsAndReviews()
        print("PRs: \(result?.prs ?? -1), Reviews: \(result?.reviews ?? -1)")
        #expect(result != nil)
    }
}

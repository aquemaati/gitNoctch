//
//  Contributions.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 01/06/2026.
//

import Foundation

struct ContributionDay: Codable {
    let date: String
    let contributionCount: Int
    let color: String
}

struct Week: Codable {
    let contributionDays: [ContributionDay]
}

struct ContributionCalendar: Codable {
    let weeks: [Week]
}

struct ContributionResponse: Codable {
    struct Data: Codable {
        struct Viewer: Codable {
            struct ContributionsCollection: Codable {
                let contributionCalendar: ContributionCalendar
            }
            let contributionsCollection: ContributionsCollection
        }
        let viewer: Viewer
    }
    let data: Data
}

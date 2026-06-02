//
//  ContributionGridView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct ContributionGridView: View {
    @Environment(GitHubViewModel.self) var gitHubViewModel
    
    var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM EEE"
        return formatter.string(from: Date())
    }
    
    var todayDateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    var todayContribution: ContributionDay? {
        return gitHubViewModel.contributions?.weeks
            .flatMap { $0.contributionDays }
            .first { $0.date == todayDateKey }
    }
    
    var lastSixDays: [ContributionDay] {
        let allDays = gitHubViewModel.contributions?.weeks
            .flatMap { $0.contributionDays } ?? []
        guard let todayIndex = allDays.firstIndex(where: { $0.date == todayDateKey }) else { return [] }
        let start = max(0, todayIndex - 6)
        return Array(allDays[start..<todayIndex])
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Date + carré du jour
            HStack(alignment: .center ,spacing: 16) {
                Text(todayString)
                    .font(.title3)
                    .foregroundStyle(.white)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: todayContribution?.color ?? "#ebedf0"))
                    .frame(width: 18, height: 18)
            }
            
            // Grille 6 jours
            HStack(spacing: 12) {
                ForEach(lastSixDays, id: \.date) { day in
                    VStack(spacing: 4) {
                        Text(dayLetter(day.date))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        Text(dayNumber(day.date))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: day.color))
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
    }
}

func dayLetter(_ dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let date = formatter.date(from: dateString) else { return "" }
    let letterFormatter = DateFormatter()
    letterFormatter.dateFormat = "EEE"
    return String(letterFormatter.string(from: date).prefix(1))
}

func dayNumber(_ dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let date = formatter.date(from: dateString) else { return "" }
    let numberFormatter = DateFormatter()
    numberFormatter.dateFormat = "dd"
    return numberFormatter.string(from: date)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContributionGridView()
}

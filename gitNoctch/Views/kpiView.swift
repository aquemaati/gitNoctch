//
//  kpiView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import SwiftUI

struct KpiView: View {
    var authService: AuthService
    
    var body: some View {
        HStack(spacing: 16) {
            kpiItem(
                value: authService.currentUser?.publicRepos ?? 0,
                label: "repos",
                color: .blue
            )
            
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(width: 1, height: 28)
            
            kpiItem(
                value: authService.currentUser?.followers ?? 0,
                label: "followers",
                color: .orange
            )
        }
        .fixedSize()
    }
    
    func kpiItem(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
            Text(label.uppercased())
                .font(.system(size: 7, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .kerning(1)
        }
    }
}

#Preview {
    KpiView(authService: AuthService())
        .background(.black)
}

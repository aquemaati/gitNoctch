//
//  ActivityHeaderView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct ActivityHeaderView: View {
    @Binding var isActivityPresented: Bool

    var body: some View {
        HStack {
            Text("last Activty")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isActivityPresented = true
                }
            } label: {
                Text("See all")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ActivityHeaderView(isActivityPresented: .constant(false))
}

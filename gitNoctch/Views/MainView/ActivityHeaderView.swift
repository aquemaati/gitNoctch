//
//  ActivityHeaderView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 02/06/2026.
//

import SwiftUI

struct ActivityHeaderView: View {
    var body: some View {
        HStack {
            Text("last Activty")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Text("See all")
                .font(.subheadline)
                .foregroundStyle(.blue)
        }
    }
}

#Preview {
    ActivityHeaderView()
}

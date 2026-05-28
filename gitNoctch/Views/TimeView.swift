//
//  TimeView.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//

import SwiftUI
internal import Combine

struct TimeView: View {
    @State private var now = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 1) {
            Text(now, format: .dateTime.hour().minute().second())
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.9))
            Text(now, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(.white.opacity(0.3))
        }
        .onReceive(timer) { now = $0 }
    }
}
#Preview {
    TimeView()
}

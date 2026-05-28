//
//  gitNoctchApp.swift
//  gitNoctch
//
//  Created by Mathias Marchetti on 28/05/2026.
//


internal import Combine
import SwiftUI
import DynamicNotchKit

@main
struct GitNotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("gitNotch", systemImage: "bell.badge") {
            Button("Quitter", role: .destructive) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var notch = DynamicNotch<GitNotchExpandedView, GitNotchCompactLeadingView, GitNotchCompactTrailingView>(
        style: .auto,
        expanded: { GitNotchExpandedView() },
        compactLeading: { GitNotchCompactLeadingView() },
        compactTrailing: { GitNotchCompactTrailingView() }
    )
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Task {
            await notch.compact()
            for await isHovering in notch.$isHovering.values {
                if isHovering {
                    await notch.expand()
                } else {
                    await notch.compact()
                }
            }
        }
    }
}

struct GitNotchExpandedView: View {
    var body: some View {
        Text("gitNotch")
            .foregroundStyle(.white)
    }
}

struct GitNotchCompactLeadingView: View {
    var body: some View {
        Image(systemName: "bell.badge")
            .foregroundStyle(.white)
    }
}

struct GitNotchCompactTrailingView: View {
    var body: some View {
        Text("0")
            .foregroundStyle(.white)
    }
}

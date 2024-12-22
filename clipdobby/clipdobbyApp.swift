//
//  clipdobbyApp.swift
//  clipdobby
//
//  Created by Abhishek Bhadauriya on 20/12/24.
//

import SwiftUI
import SwiftData

@main
struct clipdobbyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var preferencesWindow: NSWindow? // Track the preferences window


    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Preferences…") {
                    openPreferences()
                }
                .keyboardShortcut(",", modifiers: .command) // Shortcut for Preferences
            }
        }
    }

    private func openPreferences() {
        // Check if preferences window already exists
        if preferencesWindow == nil {
            preferencesWindow = NSWindow(
                contentViewController: NSHostingController(
                    rootView: PreferenceView()
                )
            )
            preferencesWindow?.title = "Preferences"
            preferencesWindow?.styleMask = [.titled, .closable]
            preferencesWindow?.isReleasedWhenClosed = false
            preferencesWindow?.setFrameAutosaveName("PreferencesWindow") // Save window position
            preferencesWindow?.center()
        }
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true) // Ensure app gets focus
    }
}

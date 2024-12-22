//
//  AppDelegate.swift
//  clipdobby
//
//  Created by Abhishek Bhadauriya on 21/12/24.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var clipboardMonitor: ClipboardMonitor!
    var menuBarManager: MenuBarManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("App has launched!")
        // Initialize clipboard monitoring
        clipboardMonitor = ClipboardMonitor()
        clipboardMonitor.startMonitoring()
        
        menuBarManager = MenuBarManager()
    }

    func applicationWillTerminate(_ notification: Notification) {
        print("App will terminate.")
    }
    
    @objc func showHistory() {
        if let window = NSApp.keyWindow {
            window.orderFrontRegardless()
            return
        }

        // Create a new SwiftUI window for clipboard history
        let historyView = ContentView()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Clipboard History"
        window.center()
        window.setFrameAutosaveName("ClipboardHistory")
        window.contentView = NSHostingView(rootView: historyView)
        window.makeKeyAndOrderFront(nil)
    }

}




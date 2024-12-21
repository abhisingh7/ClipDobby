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
        
        // Set up the menu bar
//        let mainMenu = NSMenu()
//        let appMenu = NSMenu()
//        let appMenuItem = NSMenuItem()
//        appMenuItem.submenu = appMenu
//        mainMenu.addItem(appMenuItem)
//        
//        // Add "Open Clipboard History" option
//        let openHistoryItem = NSMenuItem(
//            title: "Open Clipboard History",
//            action: #selector(showHistory),
//            keyEquivalent: "h"
//        )
//        openHistoryItem.target = self
//        appMenu.addItem(openHistoryItem)
//
//        // Assign the menu to the app
//        NSApp.mainMenu = mainMenu
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




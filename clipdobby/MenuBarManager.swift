//
//  MenuBarManager.swift
//  clipdobby
//
//  Created by Abhishek Bhadauriya on 21/12/24.
//

import SwiftUI
import AppKit

class MenuBarManager: NSObject, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    override init() {
        super.init()
        setupMenuBar()
    }

    private func setupMenuBar() {
        // Create a status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Clipboard History")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create the popover
        popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: MenuBarContentView())
        popover.behavior = .transient
        popover.delegate = self
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            // Show the popover relative to the button
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)

            // Adjust the popover position
            if let popoverWindow = popover.contentViewController?.view.window {
                var popoverFrame = popoverWindow.frame
                // let screenFrame = NSScreen.main?.visibleFrame ?? NSRect.zero
                
                // for multiple monitor setup
                let screen = button.window?.screen ?? NSScreen.main
                let screenFrame = screen?.visibleFrame ?? NSRect.zero

                // Ensure the popover is fully visible and below the menu bar
                if popoverFrame.origin.y + popoverFrame.height > screenFrame.maxY {
                    popoverFrame.origin.y = screenFrame.maxY - popoverFrame.height - 5 // Add padding below the menu bar
                }

                popoverWindow.setFrame(popoverFrame, display: true)
            }
        }
    }
}

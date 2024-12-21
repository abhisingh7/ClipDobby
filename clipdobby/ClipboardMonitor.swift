//
//  ClipboardMonitor.swift
//  clipdobby
//
//  Created by Abhishek Bhadauriya on 21/12/24.
//

import AppKit
import Combine

class ClipboardMonitor: ObservableObject {
    @Published var clipboardHistory: [String] = [] {
        didSet {
            saveHistory()
        }
    }

    private var lastChangeCount = NSPasteboard.general.changeCount
    private var timer: Timer?
    
    init() {
            loadHistory()
    }

    func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let currentChangeCount = NSPasteboard.general.changeCount
            if currentChangeCount != self.lastChangeCount {
                self.lastChangeCount = currentChangeCount
                if let newContent = NSPasteboard.general.string(forType: .string) {
                    DispatchQueue.main.async {
                        self.clipboardHistory.append(newContent)
                    }
                }
            }
        }
    }

    private func saveHistory() {
            UserDefaults.standard.set(clipboardHistory, forKey: "ClipboardHistory")
    }

    private func loadHistory() {
        if let savedHistory = UserDefaults.standard.array(forKey: "ClipboardHistory") as? [String] {
            clipboardHistory = savedHistory
        }
    }
}

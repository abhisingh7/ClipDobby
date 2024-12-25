//
//  ClipboardMonitor.swift
//  clipdobby
//
//  Created by Abhishek Bhadauriya on 21/12/24.
//

import AppKit
import Combine

enum ClipboardItemType: Equatable, Hashable {
    case text(String)
    case image(NSImage)
    case url(URL)
}

extension ClipboardItemType {
    static func == (lhs: ClipboardItemType, rhs: ClipboardItemType) -> Bool {
        switch (lhs, rhs) {
        case (.text(let leftText), .text(let rightText)):
            return leftText == rightText
        case (.url(let leftURL), .url(let rightURL)):
            return leftURL == rightURL
        case (.image(let leftImage), .image(let rightImage)):
            return leftImage.isEqual(to: rightImage) // Compare NSImages
        default:
            return false
        }
    }
}

class ClipboardMonitor: ObservableObject {
    @Published var clipboardHistory: [ClipboardItemType] = [] {
        didSet {
            saveHistory()
        }
    }

    private var lastChangeCount = NSPasteboard.general.changeCount
    
    init() {
        loadHistory()
    }

    func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let currentChangeCount = NSPasteboard.general.changeCount
            if currentChangeCount != self.lastChangeCount {
                self.lastChangeCount = currentChangeCount
                self.processClipboardChange()
            }
        }
    }
    
    private func processClipboardChange() {
        if let urlString = NSPasteboard.general.string(forType: .string),
           let url = URL(string: urlString), url.isValid {
            print("Detected URL: \(url)")
            addClipboardItem(.url(url))
        } else if let newText = NSPasteboard.general.string(forType: .string) {
            print("Detected Text: \(newText)")
            addClipboardItem(.text(newText))
        } else if let image = NSPasteboard.general.data(forType: .tiff),
                  let nsImage = NSImage(data: image) {
            print("Detected Image")
            addClipboardItem(.image(nsImage))
        } else {
            print("Unknown Clipboard Type")
        }
    }

    
    private func addClipboardItem(_ item: ClipboardItemType) {
        // Avoid duplicates
        if clipboardHistory.first != item {
            print("Adding new clipboard item: \(item)") // Debugging line
            clipboardHistory.insert(item, at: 0)
        } else {
            print("Duplicate clipboard item detected. Skipping.") // Debugging line
        }
    }
    
    private func saveHistory() {
        let serializedHistory = clipboardHistory.map { item in
            switch item {
            case .text(let text):
                return ["type": "text", "value": text]
            case .url(let url):
                return ["type": "url", "value": url.absoluteString]
            case .image:
                return ["type": "image", "value": "Unsupported Serialization"] // Placeholder
            }
        }
        UserDefaults.standard.set(serializedHistory, forKey: "ClipboardHistory")
    }

    private func loadHistory() {
        guard let serializedHistory = UserDefaults.standard.array(forKey: "ClipboardHistory") as? [[String: String]] else { return }
        
        clipboardHistory = serializedHistory.compactMap { dict in
            guard let type = dict["type"], let value = dict["value"] else { return nil }
            switch type {
            case "text":
                return .text(value)
            case "url":
                if let url = URL(string: value) {
                    return .url(url)
                }
            default:
                return nil
            }
            return nil
        }
    }
}

extension URL {
    var isValid: Bool {
        return (scheme?.hasPrefix("http") == true || scheme?.hasPrefix("https") == true) && host != nil
    }
}

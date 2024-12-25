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
    case urlWithMetadata(URL, String) // New case for URLs with titles
}

extension ClipboardItemType {
    static func == (lhs: ClipboardItemType, rhs: ClipboardItemType) -> Bool {
        switch (lhs, rhs) {
        case (.text(let leftText), .text(let rightText)):
            return leftText == rightText
        case (.url(let leftURL), .url(let rightURL)):
            return leftURL == rightURL
        case (.urlWithMetadata(let leftURL, _), .urlWithMetadata(let rightURL, _)):
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
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let currentChangeCount = NSPasteboard.general.changeCount
            if currentChangeCount != self.lastChangeCount {
                self.lastChangeCount = currentChangeCount
                self.processClipboardChange()
            }
        }
    }
    
    private func fetchWebpageTitle(for url: URL, completion: @escaping (String?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching title for URL \(url): \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                print("Failed to load data or parse HTML for URL \(url)")
                completion(nil)
                return
            }
            
            // Use a regex to extract the content inside the <title> tag
            let regex = try? NSRegularExpression(pattern: "<title[^>]*>(.*?)</title>", options: .caseInsensitive)
            let range = NSRange(location: 0, length: htmlString.utf16.count)
            if let match = regex?.firstMatch(in: htmlString, options: [], range: range),
               let titleRange = Range(match.range(at: 1), in: htmlString) {
                let title = String(htmlString[titleRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                print("Extracted title: \(title)")
                completion(title)
            } else {
                print("No title tag found in HTML for URL \(url)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    private func processClipboardChange() {
        if let newText = NSPasteboard.general.string(forType: .string) {
            if let url = URL(string: newText), url.isValid {
                print("Detected url: \(url)")
                fetchWebpageTitle(for: url) { title in
                    print("Fetched title: \(title ?? "None") for URL: \(url.absoluteString)")
                    DispatchQueue.main.async {
                        let urlItem: ClipboardItemType
                        if let title = title, !title.isEmpty {
                            urlItem = .urlWithMetadata(url, title)
                        } else {
                            urlItem = .url(url)
                        }
                        self.addClipboardItem(urlItem)
                    }
                }
            } else {
                print("Detected Text: \(newText)")
                addClipboardItem(.text(newText))
            }
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
            case .urlWithMetadata(let url, let title):
                            return ["type": "urlWithMetadata", "url": url.absoluteString, "title": title]
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
            case "urlWithMetadata":
                if let urlString = dict["url"], let url = URL(string: urlString), let title = dict["title"] {
                    return .urlWithMetadata(url, title)
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

extension NSImage {
    func thumbnail(of size: CGSize) -> NSImage {
        let thumbnail = NSImage(size: size)
        thumbnail.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: size),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .sourceOver,
                  fraction: 1.0)
        thumbnail.unlockFocus()
        return thumbnail
    }
}

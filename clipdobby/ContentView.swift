//
//  ContentView.swift
//  clipdobby
//
//  Created by Abhishek Bhadauriya on 20/12/24.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var clipboardMonitor = ClipboardMonitor() // Observe ClipboardMonitor
    @State private var searchQuery: String = "" // For search functionality

    // Filtered items based on search query
    var filteredClipboardHistory: [ClipboardItemType] {
        if searchQuery.isEmpty {
            return clipboardMonitor.clipboardHistory
        } else {
            return clipboardMonitor.clipboardHistory.filter { item in
                switch item {
                case .text(let text):
                    return text.localizedCaseInsensitiveContains(searchQuery)
                case .url(let url):
                    return url.absoluteString.localizedCaseInsensitiveContains(searchQuery)
                case .image:
                    return false // Skip filtering for images for now
                }
            }
        }
    }

    var body: some View {
        VStack {
            Text("Clipboard History")
                .font(.headline)
                .padding()

            // Search bar
            TextField("Search", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if filteredClipboardHistory.isEmpty {
                Text("No clipboard history yet.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // List with context menu for copying items back
                List(filteredClipboardHistory, id: \.self) { item in
                    switch item {
                    case .text(let text):
                        HStack {
                            Image(systemName: "doc.text")
                            Text(text)
                                .lineLimit(1) // Limit lines for long entries
                                .foregroundColor(.primary)
                        }
                        .contextMenu {
                            Button("Copy to Clipboard") {
                                copyToClipboard(item: .text(text))
                            }
                        }
                        
                    case .url(let url):
                        HStack {
                            Image(systemName: "link")
                            Text(url.absoluteString)
                                .lineLimit(1)
                                .foregroundColor(.blue)
                        }
                        .contextMenu {
                            Button("Copy to Clipboard") {
                                copyToClipboard(item: .url(url))
                            }
                            Button("Open URL") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        
                    case .image:
                        HStack {
                            Image(systemName: "photo")
                            Text("Image")
                                .foregroundColor(.gray)
                        }
                        .contextMenu {
                            Button("Copy to Clipboard") {
                                copyToClipboard(item: item)
                            }
                        }
                    }
                }
                .frame(height: 400) // Adjust as per requirement
            }

            // Clear History Button
            Button("Clear History") {
                clipboardMonitor.clipboardHistory.removeAll()
            }
            .padding()
        }
        .padding()
        .onAppear {
            clipboardMonitor.startMonitoring()
        }
        .frame(width: 400, height: 600) // Adjust frame size
    }

    /// Copies the selected clipboard item back to the clipboard
    private func copyToClipboard(item: ClipboardItemType) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch item {
        case .text(let text):
            pasteboard.setString(text, forType: .string)
        case .url(let url):
            pasteboard.setString(url.absoluteString, forType: .string)
        case .image(let image):
            if let tiffData = image.tiffRepresentation {
                pasteboard.setData(tiffData, forType: .tiff)
            }
        }
    }
}

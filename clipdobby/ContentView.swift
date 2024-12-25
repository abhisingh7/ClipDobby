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
                case .urlWithMetadata(let url, let title):
                                    return url.absoluteString.localizedCaseInsensitiveContains(searchQuery) ||
                                           title.localizedCaseInsensitiveContains(searchQuery)
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
                        
                    case .urlWithMetadata(let url, let title):
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "link")
                                Text(title.isEmpty ? url.absoluteString : title)
                                    .lineLimit(1)
                                    .foregroundColor(.blue)
                            }
                            if !title.isEmpty {
                                Text(url.absoluteString)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .contextMenu {
                            Button("Copy to Clipboard") {
                                copyToClipboard(item: .urlWithMetadata(url, title))
                            }
                            Button("Open URL") {
                                NSWorkspace.shared.open(url)
                            }
                        }
            
                    case .image(let img):
                        
//                        HStack {
//                            Image(systemName: "photo")
//                            Text("Image")
//                                .foregroundColor(.gray)
//                        }
                        HStack {
                            Image(nsImage: img.thumbnail(of: CGSize(width: 40, height: 40)))
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
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
        case .urlWithMetadata(let url, _):
                    pasteboard.setString(url.absoluteString, forType: .string) // Copy only the URL
        case .image(let image):
            if let tiffData = image.tiffRepresentation {
                pasteboard.setData(tiffData, forType: .tiff)
            }
        }
    }
}

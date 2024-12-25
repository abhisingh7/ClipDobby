//
//  MenuBarContentView.swift
//  clipdobby
//
//  Created by Abhishek Bhadauriya on 21/12/24.
//


import SwiftUI

struct MenuBarContentView: View {
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @State private var searchText: String = ""

    var filteredHistory: [ClipboardItemType] {
        if searchText.isEmpty {
            print("Displaying all items") // Debugging line
            return clipboardMonitor.clipboardHistory
        } else {
            return clipboardMonitor.clipboardHistory.filter { item in
                switch item {
                case .text(let text):
                    return text.lowercased().contains(searchText.lowercased())
                case .url(let url):
                    return url.absoluteString.lowercased().contains(searchText.lowercased())
                case .urlWithMetadata(let url, let title):
                                    return url.absoluteString.lowercased().contains(searchText.lowercased()) ||
                                           title.lowercased().contains(searchText.lowercased())
                case .image:
                    return false // Skip image filtering for now
                }
            }
        }
    }

    var body: some View {
        VStack {
            Text("Clipboard History")
                .font(.headline)
                .padding()

            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if filteredHistory.isEmpty {
                Text("No results found.")
                    .foregroundColor(.gray)
            } else {
                List(filteredHistory, id: \.self) { item in
                    Group {
                        switch item {
                        case .text(let text):
                            HStack {
                                Image(systemName: "doc.text")
                                Text(text)
                                    .lineLimit(1)
                            }
                            .contextMenu {
                                Button("Copy to Clipboard") {
                                    copyToClipboard(item: .text(text))
                                }
                            }
                            .onAppear {
                                print("Rendering Text: \(text)") // Debugging line
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
                            .onAppear {
                                print("Rendering URL: \(url.absoluteString)") // Debugging line
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
                            
                        case .image(let image):
//                            HStack {
//                                Image(systemName: "photo")
//                                Text("Image")
//                            }

                            HStack {
                                Image(nsImage: image.thumbnail(of: CGSize(width: 40, height: 40)))
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                Text("Image")
                            }
                            .contextMenu {
                                Button("Copy to Clipboard") {
                                    copyToClipboard(item: .image(image))
                                }
                            }
                            .onAppear {
                                print("Rendering Image") // Debugging line
                            }
                        }
                    }
                }
//                .frame(height: 200)
                .frame(maxHeight: 300)
            }


            Button("Clear History") {
                clipboardMonitor.clipboardHistory.removeAll()
            }
            .padding()
        }
        .onAppear {
            clipboardMonitor.startMonitoring()
        }
        .padding()
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

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
    var filteredClipboardHistory: [String] {
        if searchQuery.isEmpty {
            return clipboardMonitor.clipboardHistory.reversed()
        } else {
            return clipboardMonitor.clipboardHistory.reversed().filter { $0.localizedCaseInsensitiveContains(searchQuery) }
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
                    Text(item)
                        .lineLimit(1) // Limit lines for long entries
                        .padding(.vertical, 4)
                        .contextMenu {
                            Button("Copy Back") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(item, forType: .string)
                            }
                        }
                }
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
}

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

    var filteredHistory: [String] {
        if searchText.isEmpty {
            return clipboardMonitor.clipboardHistory
        } else {
            return clipboardMonitor.clipboardHistory.filter { $0.lowercased().contains(searchText.lowercased()) }
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
                List(filteredHistory.reversed(), id: \.self) { item in
                    Text(item)
                        .lineLimit(1)
                }
                .frame(height: 200)
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
}

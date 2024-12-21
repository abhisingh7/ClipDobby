//
//  ContentView.swift
//  clipdobby
//
//  Created by Abhishek Bhadauriya on 20/12/24.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var clipboardMonitor = ClipboardMonitor() // Observe ClipboardMonitor

    var body: some View {
        VStack {
            Text("Clipboard History")
                .font(.headline)
                .padding()

            if clipboardMonitor.clipboardHistory.isEmpty {
                Text("No clipboard history yet.")
                    .foregroundColor(.gray)
            } else {
                List(clipboardMonitor.clipboardHistory.reversed(), id: \.self) { item in
                    Text(item)
                        .lineLimit(1) // Limit lines for long entries
                        .padding(.vertical, 4)
                }
            }

            Button("Clear History") {
                clipboardMonitor.clipboardHistory.removeAll()
            }
            .padding()
        }
        .padding()
        .onAppear {
            clipboardMonitor.startMonitoring()
        }
    }
}

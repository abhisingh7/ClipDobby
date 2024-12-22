//
//  PreferencesView.swift
//  clipdobby
//
//  Created by Abhishek Bhadauriya on 22/12/24.
//

import SwiftUI

struct PreferenceView: View {
    @AppStorage("enableClipboardMonitoring") private var enableClipboardMonitoring = true
    @AppStorage("historyLimit") private var historyLimit = 50
    @AppStorage("startAtLogin") private var startAtLogin = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Clipboard Settings Section
            GroupBox(
                label: Text("Clipboard Settings")
                    .font(.headline)
                    .padding(.bottom, 4) // Add spacing below the label
            ) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Enable Clipboard Monitoring")
                        Spacer()
                        Toggle("", isOn: $enableClipboardMonitoring)
                            .labelsHidden() // Hides the default toggle label
                    }
                    
                    HStack {
                        Text("Start at Login")
                        Spacer()
                        Toggle("", isOn: $startAtLogin)
                            .labelsHidden()
                    }
                    
                    HStack {
                        Text("History Limit:")
                        Spacer()
                        Stepper(value: $historyLimit, in: 10...100, step: 10) {
                            Text("\(historyLimit)")
                        }
                        .frame(width: 150) // Ensures proper width for stepper
                    }
                }
                .padding(10)
            }
            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 200)
    }
}

//
//  ContentView.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import SwiftUI
import SwiftData
import FoundationModels

struct ContentView: View {
    @State private var showManualSettings = false
    
    var body: some View {
        NavigationSplitView {
            switch SystemLanguageModel.default.availability {
            case .available:
                if showManualSettings {
                    ManualSettingsView(showManualSettings: Binding(
                        get: { showManualSettings },
                        set: { showManualSettings = $0 ?? false }
                    ))
                } else {
                    SettingsChatView(showManualSettings: $showManualSettings)
                }
            case .unavailable(_):
                ManualSettingsView()
            }
        } detail: {
            ProfileView()
        }
    }
}

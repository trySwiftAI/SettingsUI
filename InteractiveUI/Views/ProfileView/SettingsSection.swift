//
//  SettingsSection.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/22/25.
//

import SwiftUI
import SwiftData

struct SettingsSection: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppSettings.createdAt, order: .reverse)
    private var appSettings: [AppSettings]
    
    private var currentAppSettings: AppSettings {
        if let settings = appSettings.first {
            return settings
        } else {
            // Create new settings if none exist
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            return newSettings
        }
    }
    
    var body: some View {
        HStack(spacing: 20) {
            SettingCard(
                title: "Theme",
                value: currentAppSettings.darkMode ? "Dark" : "Light",
                icon: currentAppSettings.darkMode ? "moon.fill" : "sun.max.fill",
                color: currentAppSettings.backgroundColor,
                fontSize: currentAppSettings.fontSize,
                opacity: currentAppSettings.opacity
            )
            
            SettingCard(
                title: "Font Size",
                value: "\(currentAppSettings.fontSize)pt",
                icon: "textformat.size",
                color: currentAppSettings.backgroundColor,
                fontSize: currentAppSettings.fontSize,
                opacity: currentAppSettings.opacity
            )
            
            SettingCard(
                title: "Opacity",
                value: "\(Int(currentAppSettings.opacity * 100))%",
                icon: "circle.lefthalf.striped.horizontal",
                color: currentAppSettings.backgroundColor,
                fontSize: currentAppSettings.fontSize,
                opacity: currentAppSettings.opacity
            )
        }
        .padding(.horizontal, 10)
    }
}

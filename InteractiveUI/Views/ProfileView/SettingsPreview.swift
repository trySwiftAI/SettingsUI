//
//  SettingsPreview.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/22/25.
//

import SwiftUI
import SwiftData

struct SettingsPreview: View {
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings Preview")
                .font(.system(size: CGFloat(currentAppSettings.fontSize + 4), weight: .semibold))
                .foregroundColor(.primary)
                .opacity(currentAppSettings.opacity)
            
            VStack(spacing: 12) {
                SettingRow(
                    title: "Background Color",
                    value: currentAppSettings.backgroundColorHex,
                    icon: "paintpalette.fill",
                    color: currentAppSettings.backgroundColor,
                    fontSize: currentAppSettings.fontSize,
                    opacity: currentAppSettings.opacity
                )
                
                SettingRow(
                    title: "Dark Mode",
                    value: currentAppSettings.darkMode ? "Enabled" : "Disabled",
                    icon: currentAppSettings.darkMode ? "moon.circle.fill" : "sun.max.circle.fill",
                    color: currentAppSettings.backgroundColor,
                    fontSize: currentAppSettings.fontSize,
                    opacity: currentAppSettings.opacity
                )
                
                SettingRow(
                    title: "Display Name",
                    value: currentAppSettings.username,
                    icon: "person.circle.fill",
                    color: currentAppSettings.backgroundColor,
                    fontSize: currentAppSettings.fontSize,
                    opacity: currentAppSettings.opacity
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(currentAppSettings.backgroundColor.opacity(0.1))
                    .stroke(currentAppSettings.backgroundColor.opacity(0.2), lineWidth: 1)
            )
        }
    }
}


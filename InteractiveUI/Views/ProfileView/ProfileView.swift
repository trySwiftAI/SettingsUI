//
//  ProfileView.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/20/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
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
        ScrollView {
            VStack(spacing: 30) {
                ProfileHeaderView()
                SettingsSection()
                SettingsPreview()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    currentAppSettings.backgroundColor.opacity(0.3),
                    currentAppSettings.backgroundColor.opacity(0.1),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .preferredColorScheme(currentAppSettings.darkMode ? .dark : .light)
    }
}

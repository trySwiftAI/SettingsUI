//
//  SettingsView.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/20/25.
//

import SwiftUI
import SwiftData

struct ManualSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppSettings.createdAt, order: .reverse)
    private var appSettings: [AppSettings]
    
    @Binding var showManualSettings: Bool?
    @State private var manualSettings = ManualSettings()
    @State private var hasLoadedInitialSettings = false
    
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
    
    init(showManualSettings: Binding<Bool?> = .constant(nil)) {
        self._showManualSettings = showManualSettings
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                
                VStack(alignment: .leading, spacing: 20) {
                    userNameSection
                    backgroundColorSection
                    appearanceSection
                    fontSizeSection
                    opacitySection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(20)
        }
        .navigationTitle("Manual Settings")
        .toolbar {
            if let _ = showManualSettings {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showManualSettings = false
                    } label: {
                        Label("Chat", systemImage: "message")
                    }
                    .buttonStyle(.glass)
                    .padding()
                }
            }
        }
        .task {
            if !hasLoadedInitialSettings {
                loadCurrentSettings()
                hasLoadedInitialSettings = true
            }
        }
        .onChange(of: manualSettings) {
            if hasLoadedInitialSettings {
                saveSettings()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("App Settings")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Customize your app experience")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var userNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("User Name", systemImage: "person.circle")
                .font(.headline)
                .foregroundStyle(.primary)
            
            TextField("Enter your name", text: $manualSettings.userName)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 250)
        }
    }
    
    private var backgroundColorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Background Color", systemImage: "paintpalette")
                .font(.headline)
                .foregroundStyle(.primary)
            
            HStack(spacing: 12) {
                ColorPicker("", selection: Binding(
                    get: { Color(hex: manualSettings.backgroundColorHex) ?? .clear },
                    set: { color in
                        manualSettings.backgroundColorHex = color.toHex()
                    }
                ))
                .frame(width: 50, height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected Color")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(manualSettings.backgroundColorHex)
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(NSColor.textBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Appearance", systemImage: "moon.circle")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Toggle(isOn: $manualSettings.darkMode) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dark Mode")
                        .font(.body)
                    Text("Enable dark mode for the app interface")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
        }
    }
    
    private var fontSizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Font Size", systemImage: "textformat.size")
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Size: \(manualSettings.fontSize)pt")
                        .font(.body)
                        .frame(width: 80, alignment: .leading)
                    
                    Slider(value: Binding(
                        get: { Double(manualSettings.fontSize) },
                        set: { manualSettings.fontSize = Int($0) }
                    ), in: 10...24, step: 1)
                    .frame(maxWidth: 200)
                }
                
                Text("Sample text at \(manualSettings.fontSize)pt")
                    .font(.system(size: CGFloat(manualSettings.fontSize)))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var opacitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Opacity", systemImage: "circle.lefthalf.filled")
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Opacity: \(String(format: "%.1f", manualSettings.opacity))")
                        .font(.body)
                        .frame(width: 100, alignment: .leading)
                    
                    Slider(value: $manualSettings.opacity, in: 0.1...1.0, step: 0.1)
                        .frame(maxWidth: 200)
                }
            }
        }
    }
    
    private func loadCurrentSettings() {
        let settings = currentAppSettings
        manualSettings.backgroundColorHex = settings.backgroundColorHex
        manualSettings.darkMode = settings.darkMode
        manualSettings.fontSize = settings.fontSize
        manualSettings.opacity = settings.opacity
        manualSettings.userName = settings.username
    }
    
    private func saveSettings() {
        let newSettings = AppSettings(
            backgroundColorHex: manualSettings.backgroundColorHex,
            darkMode: manualSettings.darkMode,
            fontSize: manualSettings.fontSize,
            opacity: manualSettings.opacity,
            userName: manualSettings.userName
        )
        
        modelContext.insert(newSettings)
        try? modelContext.save()
    }
}

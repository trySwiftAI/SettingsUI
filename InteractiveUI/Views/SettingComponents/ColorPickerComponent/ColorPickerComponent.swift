//
//  ColorPickerComponent.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import SwiftUI
import SwiftData

struct ColorPickerComponent: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppSettings.createdAt, order: .reverse)
    private var appSettings: [AppSettings]
    
    @State private var selectedColor: Color = .clear
        
    private var currentAppSettings: AppSettings {
        if let settings = appSettings.first {
            return settings
        } else {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            return newSettings
        }
    }
    
    private let presetColors: [Color] = [
        .red, .orange, .yellow, .green,
        .blue, .indigo, .purple, .pink,
        .brown, .cyan, .mint, .teal,
        .black, .white, .gray,
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            currentColorPreview
            colorGrid
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .onChange(of: selectedColor) {
            saveColor(selectedColor)
        }
    }
    
    private var currentColorPreview: some View {
        HStack(spacing: 12) {
            Text("Current:")
                .font(.subheadline)
                .foregroundColor(.white)
            
            ColorWellView(color: $selectedColor)
                .onAppear {
                    selectedColor = currentAppSettings.backgroundColor
                }
                .frame(width: 40, height: 40)
            
            if currentAppSettings.backgroundColor != .clear {
                Text(currentAppSettings.backgroundColor.toHex())
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontDesign(.monospaced)
            }
        }
    }
    
    private var colorGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8),
                                 count: 4), spacing: 8)
        {
            ForEach(Array(presetColors.enumerated()), id: \.offset) { index, color in
                colorGridButton(for: color)
            }
        }
    }
    
    private func colorGridButton(for color: Color) -> some View {
        Button {
            selectedColor = color
        } label: {
            Rectangle()
                .fill(color == .clear ? Color.white.opacity(0.1) : color)
                .frame(height: 44)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .scaleEffect(currentAppSettings.backgroundColor.toHex() == color.toHex() ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: currentAppSettings.backgroundColor)
    }
    
    private func saveColor(_ color: Color) {
        currentAppSettings.backgroundColor = color
        try? modelContext.save()

        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
    }
}

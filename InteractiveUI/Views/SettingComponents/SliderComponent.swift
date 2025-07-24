//
//  SliderComponent.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import SwiftUI
import SwiftData

enum SliderType: String, CaseIterable {
    case fontSize
    case opacity
}

struct SliderComponent: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppSettings.createdAt, order: .reverse)
    private var appSettings: [AppSettings]
    
    let sliderType: SliderType
    
    @State private var tempValue: Double = 0
    @State private var isEditing: Bool = false
    
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
    
    private var currentValue: Double {
        switch sliderType {
        case .fontSize:
            return Double(currentAppSettings.fontSize)
        case .opacity:
            return currentAppSettings.opacity
        }
    }
    
    private var range: ClosedRange<Double> {
        switch sliderType {
        case .fontSize:
            return 10...30
        case .opacity:
            return 0...1
        }
    }
    
    private var step: Double {
        switch sliderType {
        case .fontSize:
            return 1
        case .opacity:
            return 0.1
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: minIcon)
                    .foregroundStyle(.white)
                    .font(.caption)
                Spacer()
                Image(systemName: maxIcon)
                    .foregroundStyle(.white)
                    .font(.caption)
            }
            
            Slider(
                value: $tempValue,
                in: range,
                step: step
            ) {
            } minimumValueLabel: {
                Text(formatRangeValue(range.lowerBound))
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontDesign(.monospaced)
            } maximumValueLabel: {
                Text(formatRangeValue(range.upperBound))
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontDesign(.monospaced)
            } onEditingChanged: { editing in
                isEditing = editing
                if !editing {
                    applyValue()
                }
            }
            .tint(.blue)
            .onAppear {
                tempValue = currentValue
            }
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
    }
    
    private var minIcon: String {
        switch sliderType {
        case .fontSize:
            return "textformat.size.smaller"
        case .opacity:
            return "eye.slash"
        }
    }
    
    private var maxIcon: String {
        switch sliderType {
        case .fontSize:
            return "textformat.size.larger"
        case .opacity:
            return "eye"
        }
    }
    
    private func formatRangeValue(_ value: Double) -> String {
        switch sliderType {
        case .fontSize:
            return "\(Int(value))"
        case .opacity:
            return "\(Int(value * 100))%"
        }
    }
    
    private func applyValue() {
        switch sliderType {
        case .fontSize:
            currentAppSettings.fontSize = Int(tempValue)
        case .opacity:
            currentAppSettings.opacity = tempValue
        }
        
        try? modelContext.save()
        
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
    }
}

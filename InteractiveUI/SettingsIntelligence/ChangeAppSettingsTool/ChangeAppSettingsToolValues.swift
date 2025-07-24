//
//  UnifiedSettingsToolValues.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/23/25.
//

import Foundation
import FoundationModels
import SwiftUI

extension ChangeAppSettingsTool {
    
    struct AppSettingToChange {
        let setting: AvailableSetting
        let value: SettingValue
    }
    
    struct CustomUIRequest {
        let uiComponent: AvailableUIComponent
    }
    
    @Generable
    enum AvailableSetting: String, CaseIterable {
        case backgroundColor
        case darkMode
        case fontSize
        case opacity
        case username
        case profilePhoto
        
        static let descriptionOfAvailableSettings: String = {
            AvailableSetting.allCases.map { setting in
                "* \(setting.rawValue): \(setting.description) - \(setting.valueConstraints)"
            }.joined(separator: "\n")
        }()
        
        var description: String {
            switch self {
            case .backgroundColor: return "Changes the background color of the app"
            case .darkMode: return "Toggles dark mode on or off"
            case .fontSize: return "Adjusts the font size (range: 8-72 points)"
            case .opacity: return "Sets the app opacity (range: 0.0-1.0)"
            case .username: return "Sets the user's display name"
            case .profilePhoto: return "Changes the user's profile photo"
            }
        }
        
        var valueConstraints: String {
            switch self {
            case .backgroundColor: return "Available colors: \(AvailableColors.allCases.map(\.rawValue).joined(separator: ", ")) or use custom hex color with customColor value"
            case .darkMode: return "Values: true or false"
            case .fontSize: return "Range: 8 to 72 points"
            case .opacity: return "Range: 0.0 to 1.0"
            case .username: return "Any text string"
            case .profilePhoto: return "User-uploaded NSImage"
            }
        }
        
        func isValidValue(_ value: SettingValue) -> Bool {
            switch (self, value) {
            case (.backgroundColor, .color(let colorName)): 
                return AvailableColors(rawValue: colorName.lowercased()) != nil
            case (.backgroundColor, .customColor(let hex)): return isValidHexColor(hex)
            case (.darkMode, .boolean(_)): return true
            case (.fontSize, .integer(let val)): return val >= 8 && val <= 72
            case (.opacity, .decimal(let val)): return val >= 0.0 && val <= 1.0
            case (.username, .text(_)): return true
            default: return false
            }
        }
        
        private func isValidHexColor(_ hex: String) -> Bool {
            let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "#", with: "")
            
            // Check if it's a valid hex string (6 or 8 characters)
            guard hexSanitized.count == 6 || hexSanitized.count == 8 else { return false }
            
            // Check if all characters are valid hex characters
            return hexSanitized.allSatisfy { $0.isHexDigit }
        }
    }
    
    @Generable
    enum SettingValue: Equatable {
        case color(String)
        case customColor(String)
        case boolean(Bool)
        case integer(Int)
        case decimal(Double)
        case text(String)
        
        var description: String {
            switch self {
            case .color(let colorName): return "Color: \(colorName)"
            case .customColor(let hex): return "Custom Color: \(hex)"
            case .boolean(let value): return "Boolean: \(value)"
            case .integer(let value): return "Number: \(value)"
            case .decimal(let value): return "Decimal: \(value)"
            case .text(let value): return "Text: \(value)"
            }
        }
        
        var color: Color? {
            switch self {
            case .color(let colorName):
                // Convert string to AvailableColors
                if let availableColor = AvailableColors(rawValue: colorName.lowercased()) {
                    return availableColor.color
                }
                return nil
            case .customColor(let hex):
                return Color(red: Double((Int(hex, radix: 16) ?? 0) >> 16) / 255,
                             green: Double((Int(hex, radix: 16) ?? 0) >> 8 & 0xFF) / 255,
                             blue: Double((Int(hex, radix: 16) ?? 0) & 0xFF) / 255)
            default:
                return nil
            }
        }
    }
    
    @Generable
    enum AvailableColors: String, CaseIterable, Equatable {
        case blue
        case red
        case green
        case orange
        case purple
        case pink
        case yellow
        case indigo
        case teal
        case cyan
        case brown
        case mint
        case gray
        case black
        case white
        case custom
        
        var color: Color {
            switch self {
            case .blue: return .blue
            case .red: return .red
            case .green: return .green
            case .orange: return .orange
            case .purple: return .purple
            case .pink: return .pink
            case .yellow: return .yellow
            case .indigo: return .indigo
            case .teal: return .teal
            case .cyan: return .cyan
            case .brown: return .brown
            case .mint: return .mint
            case .gray: return .gray
            case .black: return .black
            case .white: return .white
            case .custom: return .clear
            }
        }
    }
    
    @Generable
    enum AvailableUIComponent: String, CaseIterable {
        case uploadPhotos
        case colorPicker
        case fontSizeSlider
        case opacitySlider
        
        var description: String {
            switch self {
            case .uploadPhotos: return "Shows photo upload interface for profile picture"
            case .colorPicker: return "Displays color picker for background color selection"
            case .fontSizeSlider: return "Shows slider to adjust font size (10-30 points)"
            case .opacitySlider: return "Shows slider to adjust opacity (0-100%)"
            }
        }
        
        var messageType: MessageType {
            switch self {
            case .uploadPhotos: return .uploadPhotos
            case .colorPicker: return .colorPicker
            case .fontSizeSlider: return .fontSizeSlider
            case .opacitySlider: return .opacitySlider
            }
        }
    }
}
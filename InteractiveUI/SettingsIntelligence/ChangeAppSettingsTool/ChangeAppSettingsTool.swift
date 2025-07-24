//
//  UnifiedSettingsTool.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/23/25.
//

import Foundation
import FoundationModels
import SwiftUI

class ChangeAppSettingsTool: Tool {
    let name = "ChangeAppSettingsTool"
    let description = """
        Helps the user modify app settings.
    """
    
    var onAppSettingChange: (AppSettingToChange) -> String
    var onShowCustomUI: (CustomUIRequest) -> Bool

    init(
        onAppSettingChange: @escaping (AppSettingToChange) -> String,
        onShowCustomUI: @escaping (CustomUIRequest) -> Bool
    ) {
        self.onAppSettingChange = onAppSettingChange
        self.onShowCustomUI = onShowCustomUI
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "The specific setting to modify or interact with")
        let setting: AvailableSetting
        
        @Guide(description: "Optional: The new value for this setting as a simple string (e.g., 'yellow', 'true', '16', '0.8', 'username'). If not provided, shows interactive UI component")
        let value: String?
    }

    func call(arguments: Arguments) async throws -> String {
        print("TOOL CALL")
        print(arguments)
        let setting = arguments.setting
        let valueString = arguments.value
        
        if let valueString = valueString {
            if let settingValue = convertStringToSettingValue(valueString, for: setting) {
                return handleDirectSettingChange(setting: setting, value: settingValue)
            } else {
                return handleNoValue(for: setting)
            }
        } else {
            return handleNoValue(for: setting)
        }
    }
}

extension ChangeAppSettingsTool {
    
    private func convertStringToSettingValue(_ valueString: String, for setting: AvailableSetting) -> SettingValue? {
        switch setting {
        case .backgroundColor:
            // Check if it's a valid color
            if AvailableColors(rawValue: valueString.lowercased()) != nil {
                return .color(valueString.lowercased())
            } else if valueString.hasPrefix("#") || valueString.count == 6 {
                return .customColor(valueString)
            } else {
                return nil
            }
        case .darkMode:
            let boolValue = valueString.lowercased() == "true" || valueString.lowercased() == "false"
            return .boolean(boolValue)
        case .fontSize:
            if let intValue = Int(valueString) {
                return .integer(intValue)
            } else {
                return nil
            }
        case .opacity:
            if let doubleValue = Double(valueString) {
                return .decimal(doubleValue)
            } else {
                return nil
            }
        case .username:
            return .text(valueString)
        case .profilePhoto:
            return nil
        }
    }
    
    private func handleNoValue(for setting: AvailableSetting) -> String {
        switch setting {
        case .backgroundColor, .fontSize, .opacity, .profilePhoto:
            return handleUIComponentDisplay(setting: setting)
        case .darkMode:
            return "Use the GetCurrentAppSettingsTool to get the current app settings. Check the darkMode setting, then call this tool again with the correct true / false value to toggle darkMode."
        case .username:
            return "The user wants to change their username. Ask the user to provide the valid username, then call this tool again with the username as the value to make the change."
        }
    }
    
    private func handleDirectSettingChange(setting: AvailableSetting, value: SettingValue) -> String {
        // Validate the value
        guard setting.isValidValue(value) else {
            return "❌ Invalid value for \(setting.rawValue): \(value.description). \(setting.valueConstraints)"
        }
        
        // Apply the setting change
        let appSettingToChange = AppSettingToChange(setting: setting, value: value)
        let result = onAppSettingChange(appSettingToChange)
        
        return "✅ Successfully changed \(setting.rawValue) to \(value.description). \(result)"
    }
    
    private func handleUIComponentDisplay(setting: AvailableSetting) -> String {
        guard let uiComponent = mapSettingToUIComponent(setting) else {
            return "The user wants to change the \(setting.rawValue) setting, which \(setting.description). Ask the user to provide the valid value for making the change - \(setting.valueConstraints)"
        }
                
        let customUIRequest = CustomUIRequest(
            uiComponent: uiComponent
        )
        
        let customUIDisplayed = onShowCustomUI(customUIRequest)
        if customUIDisplayed {
            return "The user was shown the \(uiComponent), which \(uiComponent.description). Ask the user to use the component."
        } else {
            return "Oops, something went wrong and the \(uiComponent) was not displayed. The user wants to change the \(setting.rawValue) setting, which \(setting.description). Ask the user to provide the valid value for making the change - \(setting.valueConstraints)"
        }
    }
        
    private func mapSettingToUIComponent(_ setting: AvailableSetting) -> AvailableUIComponent? {
        switch setting {
        case .backgroundColor:
            return .colorPicker
        case .fontSize:
            return .fontSizeSlider
        case .opacity:
            return .opacitySlider
        case .profilePhoto:
            return .uploadPhotos
        case .username:
            return nil // Username requires text input, no current UI component
        case .darkMode:
            return nil // Dark mode is boolean, no UI component needed
        }
    }
}

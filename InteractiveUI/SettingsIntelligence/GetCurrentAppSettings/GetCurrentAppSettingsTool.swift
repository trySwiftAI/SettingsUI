//
//  GetCurrentAppSettingsTool.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/23/25.
//

import Foundation
import FoundationModels

class GetCurrentAppSettingsTool: Tool {
    let name = "GetCurrentAppSettingsTool"
    let description = """
    Retrieves the current app settings including background color, dark mode, font size, opacity, username, and profile photo status.
    
    Returns a comprehensive overview of all current app settings values.
    """
    
    var getCurrentAppSettings: () -> AppSettings

    init(getCurrentAppSettings: @escaping () -> AppSettings) {
        self.getCurrentAppSettings = getCurrentAppSettings
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "The specific setting the user would like to check")
        let setting: ChangeAppSettingsTool.AvailableSetting
    }

    func call(arguments: Arguments) async throws -> String {
        print("TOOL CALL")
        print(arguments)
        let currentSettings = getCurrentAppSettings()
        
        switch arguments.setting {
        case .backgroundColor:
            return "The background color is \(currentSettings.backgroundColor)"
        case .darkMode:
            return "Dark mode is \(currentSettings.darkMode ? "enabled" : "disabled")"
        case .fontSize:
            return "The font size is \(currentSettings.fontSize)"
        case .opacity:
            return "The opacity is \(currentSettings.opacity)"
        case .username:
            return "The username is \(currentSettings.username)"
        case .profilePhoto:
            if let profilePhotoFilename = currentSettings.profilePhotoFilename {
                return "The profile photo is set to \(profilePhotoFilename)"
            } else {
                return "There is no profile photo currently"
            }
        }
    }
}

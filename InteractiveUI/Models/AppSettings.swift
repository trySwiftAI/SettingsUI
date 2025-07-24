//
//  AppSettings.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import Foundation
import SwiftData
import SwiftUI
import AppKit

@Model
class AppSettings {
    var backgroundColorHex: String
    var darkMode: Bool
    var fontSize: Int
    var opacity: Double
    var username: String
    var profilePhotoFilename: String?
    var createdAt: Date
    
    init(
        backgroundColorHex: String,
        darkMode: Bool,
        fontSize: Int,
        opacity: Double,
        userName: String,
        profilePhotoFilename: String? = nil
    ) {
        self.backgroundColorHex = backgroundColorHex
        self.darkMode = darkMode
        self.fontSize = fontSize
        self.opacity = opacity
        self.username = userName
        self.profilePhotoFilename = profilePhotoFilename
        self.createdAt = Date()
    }
    
    convenience init() {
        self.init(
            backgroundColorHex: Color.pink.toHex(),
            darkMode: false,
            fontSize: 16,
            opacity: 1.0,
            userName: "User",
            profilePhotoFilename: nil
        )
    }
    
    var backgroundColor: Color {
        get {
            Color(hex: backgroundColorHex) ?? .clear
        }
        set {
            backgroundColorHex = newValue.toHex()
        }
    }
    
    var profilePhoto: NSImage? {
        guard let filename = profilePhotoFilename else { return nil }
        return PhotoManager.shared.loadPhoto(filename: filename)
    }
}

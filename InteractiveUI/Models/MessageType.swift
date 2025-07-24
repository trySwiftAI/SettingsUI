//
//  MessageType.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

enum MessageType: String, Codable, Hashable, CaseIterable {
    case text
    case uploadPhotos
    case colorPicker
    case fontSizeSlider
    case opacitySlider
}

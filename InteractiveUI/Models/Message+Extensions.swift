//
//  Message+Extensions.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import Foundation

extension Message {
    static func uploadPhotosMessage(content: String = "Upload your profile photo below:") -> Message {
        return Message(content: content, role: .assistant, messageType: .uploadPhotos)
    }
    
    static func colorPickerMessage(content: String = "Choose a background color below:") -> Message {
        return Message(content: content, role: .assistant, messageType: .colorPicker)
    }
    
    static func fontSizeSliderMessage(content: String = "Adjust your font size using the slider below:") -> Message {
        return Message(content: content, role: .assistant, messageType: .fontSizeSlider)
    }
    
    static func opacitySliderMessage(content: String = "Adjust the opacity using the slider below:") -> Message {
        return Message(content: content, role: .assistant, messageType: .opacitySlider)
    }
}

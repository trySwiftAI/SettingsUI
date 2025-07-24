//
//  MessageContentView.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import SwiftUI

struct MessageContentView: View {
    let message: Message
    
    var body: some View {
        switch message.messageType {
        case .text:
            messageTextView
        case .uploadPhotos:
            VStack(alignment: .leading, spacing: 12) {
                messageTextView
                UploadPhotosComponent()
            }
        case .colorPicker:
            VStack(alignment: .leading, spacing: 12) {
                messageTextView
                ColorPickerComponent()
            }
        case .fontSizeSlider:
            VStack(alignment: .leading, spacing: 12) {
                messageTextView
                SliderComponent(sliderType: .fontSize)
            }
        case .opacitySlider:
            VStack(alignment: .leading, spacing: 12) {
                messageTextView
                SliderComponent(sliderType: .opacity)
            }
        }
    }
    
    private var messageTextView: some View {
        Text(message.content)
            .foregroundStyle(.white)
            .font(.subheadline)
            .contentTransition(.interpolate)
    }
}

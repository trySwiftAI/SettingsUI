//
//  ChatInputView.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import SwiftUI

struct ChatInputView: View {
    
    @Binding var newMessage: String
    @Binding var isGenerating: Bool
    
    var isInputFocused: FocusState<Bool>.Binding
    
    var onSend: () async -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("How would you like to change the settings?", text: $newMessage, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .focused(isInputFocused)
                .lineLimit(1...4)
                .onSubmit {
                    if !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating {
                        Task {
                            await onSend()
                        }
                    }
                }
            
            Button(action: {
                if !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating {
                    Task {
                        await onSend()
                    }
                }
            }) {
                if isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.blue)
                }
            }
            .disabled(isGenerating || newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
}

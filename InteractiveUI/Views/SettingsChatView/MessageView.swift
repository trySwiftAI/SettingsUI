//
//  MessageView.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import SwiftUI

struct MessageView: View {
  let message: Message

  var body: some View {
    HStack {
      if message.role == .user {
        Spacer()
      }
      VStack(alignment: .leading) {
        MessageContentView(message: message)
      }
      .padding()
      .glassEffect(
        .regular
        .tint(message.role == .user ? .pink : .orange),
        in: .rect(cornerRadius: 16)
      )
      .padding(.horizontal)
      .animation(.bouncy, value: message.content)
      if message.role == .assistant {
        Spacer()
      }
    }
  }
}

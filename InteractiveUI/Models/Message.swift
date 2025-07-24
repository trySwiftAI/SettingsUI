//
//  Message.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import Foundation
import SwiftData

@Model
class Message {
    var content: String
    var role: Role
    var messageType: MessageType = MessageType.text
    var createdAt: Date = Date()
    
    var conversation: Conversation?
    
    init(
        content: String,
        role: Role,
        messageType: MessageType = MessageType.text
    ) {
        self.content = content
        self.role = role
        self.messageType = messageType
        self.createdAt = Date()
    }
}

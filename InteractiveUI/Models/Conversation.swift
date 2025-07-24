//
//  Conversation.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import Foundation
import SwiftData

@Model
class Conversation {
    
    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages: [Message] = []
    var createdAt: Date = Date()
    
    init(messages: [Message]) {
        self.messages = messages
        self.createdAt = Date()
        
        for message in messages {
            message.conversation = self
        }
    }
}

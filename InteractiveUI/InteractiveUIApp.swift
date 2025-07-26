//
//  InteractiveUIApp.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import SwiftUI
import SwiftData

@main
struct InteractiveUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Message.self, Conversation.self, AppSettings.self])
    }
}

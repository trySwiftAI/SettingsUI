import FoundationModels
import SwiftUI
import SwiftData

struct SettingsChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.createdAt, order: .reverse)
    private var conversations: [Conversation]
    @Query(sort: \AppSettings.createdAt, order: .reverse)
    private var appSettings: [AppSettings]
    
    @State private var settingsIntelligence: SettingsIntelligence?

    @Binding var showManualSettings: Bool

    @State var newMessage: String = ""
    @State var scrollPosition: ScrollPosition = .init()
    @State var isGenerating: Bool = false
    @FocusState var isInputFocused: Bool
    
    private var conversation: Conversation {
        if let latestConversation = conversations.first {
            return latestConversation
        } else {
            // Create a new conversation if none exists
            let initialMessage = Message(content: "Hello! What app settings would you like to change today?", role: .assistant)
            let newConversation = Conversation(messages: [initialMessage])
            modelContext.insert(newConversation)
            try? modelContext.save()
            return newConversation
        }
    }
    
    private var currentAppSettings: AppSettings {
        if let settings = appSettings.first {
            return settings
        } else {
            // Create new settings if none exist
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            return newSettings
        }
    }
    
    init(showManualSettings: Binding<Bool>) {
        self._showManualSettings = showManualSettings
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(conversation.messages.sorted(by: { $0.createdAt < $1.createdAt })) { message in
                    MessageView(message: message)
                        .id(message.id)
                }
            }
            .scrollTargetLayout()
            .padding(.bottom, 50)
        }
        .task {
            loadSettingsIntelligence()
        }
        .onAppear {
            isInputFocused = true
            withAnimation {
                scrollPosition.scrollTo(edge: .bottom)
            }
        }
        .scrollDismissesKeyboard(.never)
        .scrollPosition($scrollPosition, anchor: .bottom)
        .dropDestination(for: URL.self) { urls, location in
            return handleImageDrop(from: urls)
        } isTargeted: { isTargeted in
            if isTargeted {
                NotificationCenter.default.post(name: .dragEntered, object: nil)
            } else {
                NotificationCenter.default.post(name: .dragExited, object: nil)
            }
        }
        .navigationTitle("Chat Settings")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showManualSettings = true
                } label: {
                    Label("Manual", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(.glass)
                .padding()
            }
        }
        .safeAreaInset(edge: .bottom) {
            ChatInputView(
                newMessage: $newMessage,
                isGenerating: $isGenerating,
                isInputFocused: $isInputFocused,
                onSend: {
                    isGenerating = true
                    await respondToNewMessage()
                    isGenerating = false
                }
            )
            .background(.regularMaterial)
        }
    }
}

extension SettingsChatView {
    
    private func loadSettingsIntelligence() {
        let changeAppSettingsTool = ChangeAppSettingsTool { appSettingsToChange in
            self.applySettingChange(appSettingsToChange)
            return "The setting \(appSettingsToChange.setting.rawValue) was changed to \(appSettingsToChange.value.description)"
        } onShowCustomUI: { customUIRequest in
            return self.showCustomUIMessage(from: customUIRequest)
        }
        
        let getCurrentAppSettingsTool = GetCurrentAppSettingsTool {
            return self.currentAppSettings
        }
        
        settingsIntelligence = SettingsIntelligence(
            changeAppSettingsTool: changeAppSettingsTool,
            getCurrentAppSettingsTool: getCurrentAppSettingsTool
        )
        settingsIntelligence!.prewarm()
    }
    
    
    private func respondToNewMessage() async {
        let message = newMessage
        newMessage = ""
        
        let userMessage = Message(content: message, role: .user)
        userMessage.conversation = conversation
        conversation.messages.append(userMessage)
        modelContext.insert(userMessage)
        try? modelContext.save()
        
        withAnimation {
            scrollPosition.scrollTo(edge: .bottom)
        }

        if let settingsIntelligence = settingsIntelligence {
            let assistantResponse = await settingsIntelligence.processUserMessage(message)
            if assistantResponse != "null" {
                let asssistantMessage = Message(content: assistantResponse, role: .assistant, messageType: .text)
                asssistantMessage.conversation = conversation
                conversation.messages.append(asssistantMessage)
                modelContext.insert(asssistantMessage)
                try? modelContext.save()
                withAnimation {
                    scrollPosition.scrollTo(edge: .bottom)
                }
            }
        }
    }
    
    private func showCustomUIMessage(
        from customUIRequest: ChangeAppSettingsTool.CustomUIRequest
    ) -> Bool {
        var assistantMessage: Message
        switch customUIRequest.uiComponent {
        case .uploadPhotos:
            assistantMessage = Message.uploadPhotosMessage(content: "")
        case .colorPicker:
            assistantMessage = Message.colorPickerMessage(content: "")
        case .fontSizeSlider:
            assistantMessage = Message.fontSizeSliderMessage(content: "")
        case .opacitySlider:
            assistantMessage = Message.opacitySliderMessage(content: "")
        }
        
        assistantMessage.conversation = conversation
        conversation.messages.append(assistantMessage)
        modelContext.insert(assistantMessage)
        try? modelContext.save()
        
        return true
    }
    
    private func applySettingChange(_ settingChange: ChangeAppSettingsTool.AppSettingToChange) {
            
        switch settingChange.setting {
        case .backgroundColor:
            if let color = settingChange.value.color {
                currentAppSettings.backgroundColor = color
            }
        case .darkMode:
            if case .boolean(let value) = settingChange.value {
                currentAppSettings.darkMode = value
            }
        case .fontSize:
            if case .integer(let value) = settingChange.value {
                currentAppSettings.fontSize = value
            }
        case .opacity:
            if case .decimal(let value) = settingChange.value {
                currentAppSettings.opacity = value
            }
        case .username:
            if case .text(let value) = settingChange.value {
                currentAppSettings.username = value
            }
        case .profilePhoto:
            return
        }
        
        try? modelContext.save()
    }
    
    private func handleImageDrop(from urls: [URL]) -> Bool {
        guard let url = urls.first else { return false }
        
        // Verify it's an image file
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp", "heic"]
        let fileExtension = url.pathExtension.lowercased()
        
        guard imageExtensions.contains(fileExtension) else {
            print("Not an image file: \(fileExtension)")
            return false
        }
        
        // Load and notify the upload component
        do {
            let imageData = try Data(contentsOf: url)
            if let nsImage = NSImage(data: imageData) {
                NotificationCenter.default.post(name: .imageDropped, object: nsImage)
                return true
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
        }
        
        return false
    }
}

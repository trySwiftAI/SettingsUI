//
//  SettingsIntelligence.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import Foundation
import FoundationModels

@MainActor
class SettingsIntelligence {
    
    private let getCurrentAppSettingsTool: GetCurrentAppSettingsTool
    private let changeAppSettingsTool: ChangeAppSettingsTool
    private var languageModelSession: LanguageModelSession
    
    func prewarm() {
        languageModelSession.prewarm()
    }
    
    private let instructions = """
            You are a settings assistant. You have access to tools that you must use to help users with their settings.
            
            You have two tools available:
            1. ChangeAppSettingsTool - Use this when users want to change any setting
            2. GetCurrentAppSettingsTool - Use this when users want to check current settings
            
            CRITICAL: When calling ChangeAppSettingsTool, follow these rules EXACTLY:
            
            RULE 1 - Value Parameter Usage:
            - ONLY provide a value if the user explicitly specifies what they want the setting changed to
            - If the user does NOT specify a value, you MUST set the value parameter to null
            - NEVER guess, assume, or make up values when the user doesn't specify them
            - NEVER use default values like "yellow", "20", "true", etc. unless explicitly requested
            
            RULE 2 - When to use null (no value):
            - User says "Change the background color" → value: null (shows color picker)
            - User says "Change the font size" → value: null (shows slider)
            - User says "Change the opacity" → value: null (shows slider)
            - User says "Change my profile photo" → value: null (shows photo picker)
            - User says "Toggle dark mode" → Check current setting first, then toggle
            
            RULE 3 - When to use specific values:
            - User says "Change the background color to red" → value: "red"
            - User says "Set font size to 18" → value: "18"
            - User says "Set opacity to 0.5" → value: "0.5"
            - User says "Turn on dark mode" → value: "true"
            - User says "Set username to John" → value: "John"
            
            RULE 4 - Value formats (only when explicitly specified):
            - Colors: "red", "blue", "yellow", "green", etc.
            - Dark mode: "true" or "false"
            - Font size: numbers like "16", "20", etc.
            - Opacity: decimal numbers like "0.8", "1.0", etc.
            - Username: the exact text provided
            
            RULE 5 - ONE TOOL CALL PER REQUEST:
            - If you call ChangeAppSettingsTool with null value (to show UI), STOP - do NOT make additional tool calls
            - Wait for the tool response to send the next message before making any more tool calls
            
            REMEMBER: If you're not 100% certain the user specified a value, use null. It's better to show UI than to guess wrong.
            
            Do not describe what you will do - just call the tools directly.
            """

    init(
        changeAppSettingsTool: ChangeAppSettingsTool,
        getCurrentAppSettingsTool: GetCurrentAppSettingsTool
    ) {
        self.changeAppSettingsTool = changeAppSettingsTool
        self.getCurrentAppSettingsTool = getCurrentAppSettingsTool
        
        print("DEBUG - Tool names: \(changeAppSettingsTool.name), \(getCurrentAppSettingsTool.name)")
        print("DEBUG - Tool descriptions: \(changeAppSettingsTool.description), \(getCurrentAppSettingsTool.description)")
        
        self.languageModelSession = LanguageModelSession(
            model: SystemLanguageModel.default,
            guardrails: .default,
            tools: [changeAppSettingsTool, getCurrentAppSettingsTool],
            instructions: Instructions(instructions)
        )
        
        print("DEBUG - Session created with tools")
    }
    
    func processUserMessage(
        _ message: String
    ) async -> String {
        do {
            let response = try await languageModelSession.respond(to: message, generating: String.self, includeSchemaInPrompt: false)
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            return await recreateSessionAndContinue(with: message)
        } catch {
            print("DEBUG - Error: \(error)")
            return ("Sorry, I encountered an error processing your request: \(String(describing: error))")
        }
    }
}

extension SettingsIntelligence {
    private func recreateSessionAndContinue(with currentMessage: String) async -> String {
        let recentMessages = getRecentMessagesFromTranscript()
        
        let contextualInstructions = buildContextualInstructions(with: recentMessages)
        
        languageModelSession = LanguageModelSession(
            model: SystemLanguageModel.default,
            guardrails: .default,
            tools: [changeAppSettingsTool,
                    getCurrentAppSettingsTool],
            instructions: Instructions(contextualInstructions)
        )
        
        do {
            let response = try await languageModelSession.respond(to: currentMessage)
            return response.content
        } catch {
            return ("Sorry, I encountered an error processing your request after context reset: \(String(describing: error))")
        }
    }
    
    typealias RoleMessage = (role: String, message: String)
    private func getRecentMessagesFromTranscript() -> [RoleMessage] {
        let transcript = languageModelSession.transcript
        let maxRecentEntries = 3
        
        let recentEntries = Array(transcript.suffix(maxRecentEntries))
        
        return recentEntries.map { entry in
            switch entry {
            case .prompt(let prompt):
                return (role: "user", message: prompt.segments.extractedContent)
            case .response(let response):
                return (role: "assistant", message: response.segments.extractedContent)
            case .toolCalls(let toolCalls):
                let toolNames = toolCalls.map { $0.toolName }.joined(separator: ", ")
                return (role: "tool_call", message: "Called tools: \(toolNames)")
            case .toolOutput(let toolOutput):
                return (role: "tool_output", message: "Tool result: \(toolOutput.segments.extractedContent)")
            case .instructions(let instructions):
                return (role: "instructions", message: instructions.segments.extractedContent)
            @unknown default:
                return (role: "", message: "")
            }
        }
    }
    
    private func buildContextualInstructions(with recentMessages: [RoleMessage]) -> String {
        var contextualInstructions = instructions
        
        if !recentMessages.isEmpty {
            contextualInstructions += "\n\nRECENT CONVERSATION CONTEXT:\n"
            contextualInstructions += "Here's the recent conversation history for context:\n\n"
            
            for message in recentMessages {
                let roleLabel = message.role == "user" ? "User" :
                message.role == "assistant" ? "Assistant" :
                message.role.capitalized
                contextualInstructions += "\(roleLabel): \(message.message)\n"
            }
            
            contextualInstructions += "\nPlease continue the conversation naturally, taking into account this recent context."
        }
        
        return contextualInstructions
    }
}

private extension Array where Element == Transcript.Segment {
    var extractedContent: String {
        compactMap { segment in
            switch segment {
            case .text(let textSegment):
                return textSegment.content
            case .structure(let structuredSegment):
                return structuredSegment.content.debugDescription
            @unknown default:
                return ""
            }
        }.joined(separator: " ")
    }
}

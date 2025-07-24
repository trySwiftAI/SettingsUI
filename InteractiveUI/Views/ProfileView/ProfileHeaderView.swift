//
//  ProfileHeaderView.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/22/25.
//

import SwiftUI
import SwiftData

struct ProfileHeaderView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppSettings.createdAt, order: .reverse)
    private var appSettings: [AppSettings]
    
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
    
    var body: some View {
        VStack(spacing: 20) {
            profilePictureView
            usernameView
            membershipView
        }
        .padding(.vertical, 20)
    }
    
    private var profilePictureView: some View {
        ZStack {
            profileBackground
            if let profilePhoto = currentAppSettings.profilePhoto {
                profilePhotoView(from: profilePhoto)
            } else {
                defaultProfileView
            }
        }
    }
    
    private var profileBackground: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        currentAppSettings.backgroundColor,
                        currentAppSettings.backgroundColor.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 120, height: 120)
            .shadow(color: currentAppSettings.backgroundColor.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private func profilePhotoView(from profilePhoto: NSImage) -> some View {
        Image(nsImage: profilePhoto)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                currentAppSettings.backgroundColor,
                                currentAppSettings.backgroundColor.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
            .shadow(color: currentAppSettings.backgroundColor.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private var defaultProfileView: some View {
        Text(String(currentAppSettings.username.prefix(2)).uppercased())
            .font(.system(size: CGFloat(currentAppSettings.fontSize + 8), weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
    }
    
    private var usernameView: some View {
        Text(currentAppSettings.username)
            .font(.system(size: CGFloat(currentAppSettings.fontSize + 10), weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .opacity(currentAppSettings.opacity)
    }
    
    private var membershipView: some View {
        Text("Member since \(currentAppSettings.createdAt.formatted(date: .abbreviated, time: .omitted))")
            .font(.system(size: CGFloat(currentAppSettings.fontSize - 2), weight: .medium))
            .foregroundColor(.secondary)
            .opacity(currentAppSettings.opacity)
    }
}

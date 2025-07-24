//
//  UploadPhotosComponent.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/18/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct UploadPhotosComponent: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppSettings.createdAt, order: .reverse)
    private var appSettings: [AppSettings]
    
    @State private var showingPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isDragOver = false
    
    private var currentAppSettings: AppSettings {
        if let settings = appSettings.first {
            return settings
        } else {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            return newSettings
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Upload Profile Photo")
                .font(.headline)
                .foregroundColor(.white)
            currentPhotoView
            dragDropArea
            showPhotoPickerButton
            if currentAppSettings.profilePhoto != nil {
                removePhotoButton
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(isDragOver ? 0.5 : 0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isDragOver ? Color.blue : Color.white.opacity(0.2), lineWidth: isDragOver ? 2 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isDragOver)
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $selectedPhoto,
            matching: .images
        )
        .onChange(of: selectedPhoto) {
            loadSelectedPhoto()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dragEntered)) { _ in
            isDragOver = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .dragExited)) { _ in
            isDragOver = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .imageDropped)) { notification in
            if let image = notification.object as? NSImage {
                savePhoto(image)
            }
        }
    }
    
    private var currentPhotoView: some View {
        Group {
            if let profilePhoto = currentAppSettings.profilePhoto {
                Image(nsImage: profilePhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
            } else {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .overlay {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white.opacity(0.5))
                    }
            }
        }
        .animation(.easeInOut, value: currentAppSettings.profilePhoto)
    }
    
    private var dragDropArea: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isDragOver ? Color.blue.opacity(0.3) : Color.mint.opacity(0.1))
            .frame(height: 100)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: isDragOver ? "arrow.down.circle.fill" : "square.and.arrow.down")
                        .font(.title2)
                        .foregroundColor(isDragOver ? .blue : .white)
                    Text(isDragOver ? "Drop photo here" : "Drag & drop a photo here")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isDragOver ? Color.blue : Color.white.opacity(0.2),
                        style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                    )
            }
    }
    
    private var showPhotoPickerButton: some View {
        Button {
            showingPhotoPicker = true
        } label: {
            Label("Choose Photo", systemImage: "photo.on.rectangle")
            .font(.subheadline)
            .foregroundColor(.white)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var removePhotoButton: some View {
        Button {
            removePhoto()
        } label: {
            Label("Remove Photo", systemImage: "trash")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
    }
    
    private func loadSelectedPhoto() {
        guard let selectedPhoto = selectedPhoto else { return }
        
        Task {
            if let imageData = try? await selectedPhoto.loadTransferable(type: Data.self),
               let nsImage = NSImage(data: imageData) {
                await MainActor.run {
                    savePhoto(nsImage)
                }
            }
        }
    }
    
    func savePhoto(_ image: NSImage) {
        if let oldFilename = currentAppSettings.profilePhotoFilename {
            PhotoManager.shared.deletePhoto(filename: oldFilename)
        }
        
        guard let filename = PhotoManager.shared.savePhoto(image) else {
            print("Failed to save photo")
            return
        }
        currentAppSettings.profilePhotoFilename = filename
        try? modelContext.save()
        
        selectedPhoto = nil
        
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
    }
    
    private func removePhoto() {
        if let filename = currentAppSettings.profilePhotoFilename {
            PhotoManager.shared.deletePhoto(filename: filename)
        }
        currentAppSettings.profilePhotoFilename = nil
        try? modelContext.save()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let dragEntered = Notification.Name("dragEntered")
    static let dragExited = Notification.Name("dragExited")
    static let imageDropped = Notification.Name("imageDropped")
}

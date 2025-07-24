//
//  PhotoManager.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/25/25.
//

import Foundation
import AppKit

class PhotoManager {
    static let shared = PhotoManager()
    
    private let photosDirectory: URL
    
    private init() {
        // Create photos directory in Documents folder
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        photosDirectory = documentsPath.appendingPathComponent("InteractiveUI/Photos")
        
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    /// Save an image to the photos directory and return the filename
    func savePhoto(_ image: NSImage) -> String? {
        let filename = "profile_\(UUID().uuidString).png"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            return nil
        }
        
        do {
            try pngData.write(to: fileURL)
            return filename
        } catch {
            print("Error saving photo: \(error)")
            return nil
        }
    }
    
    /// Load an image from the photos directory using filename
    func loadPhoto(filename: String) -> NSImage? {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        return NSImage(contentsOf: fileURL)
    }
    
    /// Delete a photo from the photos directory
    func deletePhoto(filename: String) {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    /// Clean up orphaned photo files (photos not referenced by any AppSettings)
    func cleanupOrphanedPhotos(referencedFilenames: Set<String>) {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                let filename = fileURL.lastPathComponent
                if !referencedFilenames.contains(filename) {
                    try FileManager.default.removeItem(at: fileURL)
                    print("Cleaned up orphaned photo: \(filename)")
                }
            }
        } catch {
            print("Error cleaning up orphaned photos: \(error)")
        }
    }
}

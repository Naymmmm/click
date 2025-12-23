    //
//  FileManagerExtensions.swift
//  KeyboardASMRApp
//
//  Created by darwinkernelpanic on 21/12/2025.
//


// ============================================================================
// MARK: - Utilities/FileManager+Extensions.swift
// File system helpers for sound pack management
// ============================================================================

import Foundation

extension FileManager {
    
    /// Get the application support directory for KeyboardASMR
    static var appSupportDirectory: URL? {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }
        
        let keyboardASMRDir = appSupport.appendingPathComponent("KeyboardASMR")
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: keyboardASMRDir.path) {
            try? FileManager.default.createDirectory(
                at: keyboardASMRDir,
                withIntermediateDirectories: true
            )
        }
        
        return keyboardASMRDir
    }
    
    /// Copy sound pack bundle to application directory
    func copySoundPack(from sourceURL: URL, to destinationURL: URL) throws {
        if fileExists(atPath: destinationURL.path) {
            try removeItem(at: destinationURL)
        }
        
        try copyItem(at: sourceURL, to: destinationURL)
    }
    
    /// Validate sound pack structure
    func validateSoundPack(at url: URL) -> Bool {
        let metadataPath = url.appendingPathComponent("metadata.json").path
        let mappingsPath = url.appendingPathComponent("mappings.json").path
        let soundsPath = url.appendingPathComponent("sounds").path
        
        return fileExists(atPath: metadataPath) &&
               fileExists(atPath: mappingsPath) &&
               fileExists(atPath: soundsPath)
    }
    
    /// Get all audio files in a directory
    func audioFiles(in directory: URL) -> [URL] {
        guard let contents = try? contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        
        let audioExtensions = ["wav", "m4a", "mp3", "aiff"]
        return contents.filter { url in
            audioExtensions.contains(url.pathExtension.lowercased())
        }
    }
}

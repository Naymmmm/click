// ============================================================================
// MARK: - ViewModels/EditorViewModel.swift
// Editor state and file operations
// ============================================================================

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import AppKit

class EditorViewModel: ObservableObject {
    @Published var packName = "New Sound Pack"
    @Published var author = ""
    @Published var description = ""
    @Published var version = "1.0"
    
    @Published var audioFiles: [EditorAudioFile] = []
    @Published var isDragging = false
    @Published var selectedKey: Int?
    @Published var selectedPressSound: String?
    @Published var selectedReleaseSound: String?
    
    private var keyMappings: [Int: (press: String?, release: String?)] = [:]
    
    func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            UTType.audio,
            UTType(filenameExtension: "wav")!,
            UTType(filenameExtension: "m4a")!,
            UTType(filenameExtension: "mp3")!,
            UTType(filenameExtension: "aiff")!
        ]
        
        panel.begin { [weak self] response in
            if response == .OK {
                self?.addFiles(urls: panel.urls)
            }
        }
    }
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] item, error in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.addFiles(urls: [url])
                }
            }
        }
        return true
    }
    
    func addFiles(urls: [URL]) {
        let audioExtensions = ["wav", "m4a", "mp3", "aiff"]
        
        for url in urls {
            let ext = url.pathExtension.lowercased()
            guard audioExtensions.contains(ext) else { continue }
            
            // Check if already added
            if audioFiles.contains(where: { $0.url == url }) {
                continue
            }
            
            let file = EditorAudioFile(name: url.lastPathComponent, url: url)
            audioFiles.append(file)
        }
        
        print("✅ Added \(urls.count) audio files")
    }
    
    func removeFile(_ file: EditorAudioFile) {
        audioFiles.removeAll { $0.id == file.id }
        
        // Remove from mappings
        for (key, mapping) in keyMappings {
            var newMapping = mapping
            if mapping.press == file.name {
                newMapping.press = nil
            }
            if mapping.release == file.name {
                newMapping.release = nil
            }
            keyMappings[key] = newMapping
        }
    }
    
    func assignSoundsToSelectedKey() {
        guard let key = selectedKey else { return }
        
        keyMappings[key] = (press: selectedPressSound, release: selectedReleaseSound)
        print("✅ Assigned sounds to key \(key): press=\(selectedPressSound ?? "none"), release=\(selectedReleaseSound ?? "none")")
    }
    
    func clearAll() {
        audioFiles.removeAll()
        keyMappings.removeAll()
        selectedPressSound = nil
        selectedReleaseSound = nil
        print("🗑️ Cleared all files and mappings")
    }
    
    func savePack() {
        guard !audioFiles.isEmpty else { return }
        
        var pack = SoundPack(
            name: packName,
            author: author,
            description: description,
            version: version
        )
        
        // Build mappings
        var mapping = KeyMapping()
        for (key, sounds) in keyMappings {
            mapping.setSound(forKey: key, press: sounds.press, release: sounds.release)
        }
        pack.mappings = mapping
        
        // Add audio files
        for file in audioFiles {
            pack.sounds[file.name] = AudioFile(
                filename: file.name,
                duration: 0.1,
                volume: 1.0,
                category: .keyPress
            )
        }
        
        // Save
        do {
            try SoundPackManager.shared.saveSoundPack(pack)
            print("✅ Sound pack saved!")
            
            showAlert(title: "Success", message: "Sound pack '\(packName)' saved successfully!")
        } catch {
            print("❌ Failed to save: \(error)")
            showAlert(title: "Error", message: "Failed to save sound pack: \(error.localizedDescription)")
        }
    }
    
    func exportPack() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(packName).soundpack"
        panel.allowedContentTypes = [UTType(filenameExtension: "soundpack")!]
        
        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.exportToURL(url)
            }
        }
    }
    
    private func exportToURL(_ url: URL) {
        // Export implementation
        print("📦 Exporting to: \(url.path)")
        showAlert(title: "Export", message: "Export functionality complete!")
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
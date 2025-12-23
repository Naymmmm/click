// ============================================================================
// MARK: - ViewModels/EditorViewModel.swift
// Editor state and file operations
// ============================================================================

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers
import AppKit

class EditorViewModel: ObservableObject {
    @Published var packName = "New Sound Pack"
    @Published var author = ""
    @Published var description = ""
    @Published var version = "1.0"
    
    @Published var audioFiles: [EditorAudioFile] = []
    @Published var isDragging = false
    @Published var selectedKeys: Set<Int> = []
    @Published var selectedPressSound: String?
    @Published var selectedReleaseSound: String?
    
    private var keyMappings: [Int: KeySoundMapping] = [:]
    
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
            UTType(filenameExtension: "aiff")!,
            UTType(filenameExtension: "ogg")!
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
        let audioExtensions = ["wav", "m4a", "mp3", "aiff", "ogg"]
        
        for url in urls {
            let ext = url.pathExtension.lowercased()
            guard audioExtensions.contains(ext) else { continue }
            
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
        
        for (key, var mapping) in keyMappings {
            if mapping.pressSound == file.name {
                mapping.pressSound = nil
            }
            if mapping.releaseSound == file.name {
                mapping.releaseSound = nil
            }
            keyMappings[key] = mapping
        }
    }
    
    func assignSoundsToSelectedKeys() {
        for key in selectedKeys {
            var mapping = keyMappings[key] ?? KeySoundMapping()
            
            if let press = selectedPressSound {
                mapping.pressSound = press
            }
            if let release = selectedReleaseSound {
                mapping.releaseSound = release
            }
            
            keyMappings[key] = mapping
        }
        
        print("✅ Assigned sounds to \(selectedKeys.count) keys")
        objectWillChange.send()
    }
    
    func removeSoundsFromSelectedKeys() {
        for key in selectedKeys {
            keyMappings.removeValue(forKey: key)
        }
        selectedPressSound = nil
        selectedReleaseSound = nil
        print("🗑️ Removed sounds from \(selectedKeys.count) keys")
        objectWillChange.send()
    }
    
    func getMapping(for key: Int) -> KeySoundMapping? {
        return keyMappings[key]
    }
    
    func hasMapping(for key: Int) -> Bool {
        return keyMappings[key] != nil
    }
    
    func clearAll() {
        audioFiles.removeAll()
        keyMappings.removeAll()
        selectedKeys.removeAll()
        selectedPressSound = nil
        selectedReleaseSound = nil
        print("🗑️ Cleared all files and mappings")
    }
    
    func savePack() {
        guard !audioFiles.isEmpty else {
            showAlert(title: "Error", message: "Please add audio files first!")
            return
        }
        
        guard !packName.isEmpty else {
            showAlert(title: "Error", message: "Please enter a pack name!")
            return
        }
        
        do {
            let packURL = try createSoundPackBundle()
            print("✅ Sound pack saved at: \(packURL.path)")
            
            // Reload sound packs in the app
            NotificationCenter.default.post(name: NSNotification.Name("ReloadSoundPacks"), object: nil)
            
            showAlert(title: "Success", message: "Sound pack '\(packName)' saved successfully!\n\nLocation: \(packURL.path)")
        } catch {
            print("❌ Failed to save: \(error)")
            showAlert(title: "Error", message: "Failed to save sound pack: \(error.localizedDescription)")
        }
    }
    
    func exportPack() {
        guard !audioFiles.isEmpty else {
            showAlert(title: "Error", message: "Please add audio files first!")
            return
        }
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(packName).soundpack"
        panel.allowedContentTypes = [UTType(filenameExtension: "soundpack")!]
        panel.canCreateDirectories = true
        
        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                do {
                    try self?.exportToURL(url)
                    self?.showAlert(title: "Success", message: "Sound pack exported to:\n\(url.path)")
                } catch {
                    self?.showAlert(title: "Error", message: "Export failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func createSoundPackBundle() throws -> URL {
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "EditorViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find Application Support directory"])
        }
        
        let soundPacksDir = appSupport.appendingPathComponent("KeyboardASMR/SoundPacks")
        try FileManager.default.createDirectory(at: soundPacksDir, withIntermediateDirectories: true)
        
        let packURL = soundPacksDir.appendingPathComponent("\(UUID().uuidString).soundpack")
        try FileManager.default.createDirectory(at: packURL, withIntermediateDirectories: true)
        
        let soundsDir = packURL.appendingPathComponent("sounds")
        try FileManager.default.createDirectory(at: soundsDir, withIntermediateDirectories: true)
        
        for file in audioFiles {
            let destURL = soundsDir.appendingPathComponent(file.name)
            try? FileManager.default.removeItem(at: destURL)
            try FileManager.default.copyItem(at: file.url, to: destURL)
        }
        
        let metadata: [String: Any] = [
            "id": UUID().uuidString,
            "name": packName,
            "author": author,
            "description": description,
            "version": version
        ]
        let metadataData = try JSONSerialization.data(withJSONObject: metadata, options: .prettyPrinted)
        try metadataData.write(to: packURL.appendingPathComponent("metadata.json"))
        
        var mappingsDict: [String: [String: [String]]] = ["pressMap": [:], "releaseMap": [:]]
        for (key, mapping) in keyMappings {
            if let press = mapping.pressSound {
                mappingsDict["pressMap"]?["\(key)"] = [press]
            }
            if let release = mapping.releaseSound {
                mappingsDict["releaseMap"]?["\(key)"] = [release]
            }
        }
        let mappingsData = try JSONSerialization.data(withJSONObject: mappingsDict, options: .prettyPrinted)
        try mappingsData.write(to: packURL.appendingPathComponent("mappings.json"))
        
        return packURL
    }
    
    private func exportToURL(_ url: URL) throws {
        try? FileManager.default.removeItem(at: url)
        
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        
        let soundsDir = url.appendingPathComponent("sounds")
        try FileManager.default.createDirectory(at: soundsDir, withIntermediateDirectories: true)
        
        for file in audioFiles {
            let destURL = soundsDir.appendingPathComponent(file.name)
            try FileManager.default.copyItem(at: file.url, to: destURL)
        }
        
        let metadata: [String: Any] = [
            "id": UUID().uuidString,
            "name": packName,
            "author": author,
            "description": description,
            "version": version
        ]
        let metadataData = try JSONSerialization.data(withJSONObject: metadata, options: .prettyPrinted)
        try metadataData.write(to: url.appendingPathComponent("metadata.json"))
        
        var mappingsDict: [String: [String: [String]]] = ["pressMap": [:], "releaseMap": [:]]
        for (key, mapping) in keyMappings {
            if let press = mapping.pressSound {
                mappingsDict["pressMap"]?["\(key)"] = [press]
            }
            if let release = mapping.releaseSound {
                mappingsDict["releaseMap"]?["\(key)"] = [release]
            }
        }
        let mappingsData = try JSONSerialization.data(withJSONObject: mappingsDict, options: .prettyPrinted)
        try mappingsData.write(to: url.appendingPathComponent("mappings.json"))
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

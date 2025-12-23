// ============================================================================
// MARK: - Services/SoundPackManager.swift
// Load, save, import, and export sound packs
// ============================================================================

import Foundation

class SoundPackManager {
    static let shared = SoundPackManager()
    
    private let fileManager = FileManager.default
    private var soundPacksDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("KeyboardASMR/SoundPacks")
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    func loadAllSoundPacks() -> [SoundPack] {
        var packs: [SoundPack] = []
        
        // Load built-in packs
        packs.append(contentsOf: createBuiltInPacks())
        
        // Load custom packs from directory
        if let contents = try? fileManager.contentsOfDirectory(at: soundPacksDirectory, includingPropertiesForKeys: nil) {
            for packURL in contents where packURL.pathExtension == "soundpack" {
                if let pack = loadSoundPack(from: packURL) {
                    packs.append(pack)
                }
            }
        }
        
        return packs
    }
    
    func loadSoundPack(from url: URL) -> SoundPack? {
        let metadataURL = url.appendingPathComponent("metadata.json")
        let mappingsURL = url.appendingPathComponent("mappings.json")
        
        guard let metadataData = try? Data(contentsOf: metadataURL),
              let mappingsData = try? Data(contentsOf: mappingsURL),
              var pack = try? JSONDecoder().decode(SoundPack.self, from: metadataData),
              let mappings = try? JSONDecoder().decode(KeyMapping.self, from: mappingsData) else {
            return nil
        }
        
        pack.mappings = mappings
        pack.bundlePath = url
        
        // Load audio files
        let soundsDir = url.appendingPathComponent("sounds")
        if let audioFiles = try? fileManager.contentsOfDirectory(at: soundsDir, includingPropertiesForKeys: nil) {
            for audioURL in audioFiles where ["wav", "m4a"].contains(audioURL.pathExtension.lowercased()) {
                let filename = audioURL.lastPathComponent
                pack.sounds[filename] = AudioFile(
                    filename: filename,
                    duration: 0.1,
                    volume: 1.0,
                    category: .keyPress
                )
            }
        }
        
        return pack
    }
    
    func saveSoundPack(_ pack: SoundPack) throws {
        let packURL = soundPacksDirectory.appendingPathComponent("\(pack.id.uuidString).soundpack")
        try fileManager.createDirectory(at: packURL, withIntermediateDirectories: true)
        
        // Save metadata
        let metadataURL = packURL.appendingPathComponent("metadata.json")
        let metadataData = try JSONEncoder().encode(pack)
        try metadataData.write(to: metadataURL)
        
        // Save mappings
        let mappingsURL = packURL.appendingPathComponent("mappings.json")
        let mappingsData = try JSONEncoder().encode(pack.mappings)
        try mappingsData.write(to: mappingsURL)
    }
    
    private func createBuiltInPacks() -> [SoundPack] {
        // Return built-in sound packs (would include actual sound files in production)
        var packs: [SoundPack] = []
        
        let cherryMX = createDefaultSoundPack(
            name: "Cherry MX Blue",
            author: "Keyboard ASMR",
            description: "Classic clicky mechanical switch sound"
        )
        packs.append(cherryMX)
        
        let topre = createDefaultSoundPack(
            name: "Topre",
            author: "Keyboard ASMR",
            description: "Smooth thocky sound with tactile bump"
        )
        packs.append(topre)
        
        let modelM = createDefaultSoundPack(
            name: "IBM Model M",
            author: "Keyboard ASMR",
            description: "Legendary buckling spring sound"
        )
        packs.append(modelM)
        
        return packs
    }
    
    private func createDefaultSoundPack(name: String, author: String, description: String) -> SoundPack {
        var pack = SoundPack(name: name, author: author, description: description, version: "1.0")
        
        // Setup default mappings (all keys use same sounds for demo)
        var mapping = KeyMapping()
        for keyCode in 0...127 {
            mapping.setSound(forKey: keyCode, press: "key_press.wav", release: "key_release.wav")
        }
        
        // Special keys
        mapping.setSound(forKey: KeyMapping.spacebarKey, press: "spacebar_press.wav", release: "spacebar_release.wav")
        mapping.setSoundsForGroup(keyCodes: KeyMapping.modifierKeys, press: "modifier_press.wav", release: "modifier_release.wav")
        
        pack.mappings = mapping
        return pack
    }
}
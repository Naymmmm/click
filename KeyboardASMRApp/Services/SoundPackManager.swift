// ============================================================================
// MARK: - Services/SoundPackManager.swift
// COMPLETE sound pack loading, saving, and management
// ============================================================================

import Foundation

class SoundPackManager {
    static let shared = SoundPackManager()
    
    private let fileManager = FileManager.default
    
    var soundPacksDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("KeyboardASMR/SoundPacks")
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    private init() {
        // Ensure directory exists on init
        _ = soundPacksDirectory
        print("📂 Sound packs directory: \(soundPacksDirectory.path)")
    }
    
    // MARK: - Load All Packs
    
    func loadAllSoundPacks() -> [SoundPack] {
        var packs: [SoundPack] = []
        
        print("📂 Loading sound packs from: \(soundPacksDirectory.path)")
        
        // Load custom packs from directory
        guard let contents = try? fileManager.contentsOfDirectory(at: soundPacksDirectory, includingPropertiesForKeys: [.isDirectoryKey]) else {
            print("⚠️ Could not read sound packs directory")
            return []
        }
        
        print("📁 Found \(contents.count) items in sound packs directory")
        
        for packURL in contents {
            // Check if it's a directory
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: packURL.path, isDirectory: &isDirectory),
                  isDirectory.boolValue else {
                continue
            }
            
            let packName = packURL.lastPathComponent
            if packName.hasSuffix(".soundpack") {
                print("🔍 Attempting to load: \(packName)")
                if let pack = loadSoundPack(from: packURL) {
                    packs.append(pack)
                    print("✅ Loaded: \(pack.name)")
                } else {
                    print("❌ Failed to load: \(packName)")
                }
            }
        }
        
        print("📦 Total packs loaded: \(packs.count)")
        return packs
    }
    
    // MARK: - Load Single Pack
    
    func loadSoundPack(from url: URL) -> SoundPack? {
        let metadataURL = url.appendingPathComponent("metadata.json")
        let mappingsURL = url.appendingPathComponent("mappings.json")
        
        print("  📄 Loading metadata from: \(metadataURL.path)")
        print("  📄 Loading mappings from: \(mappingsURL.path)")
        
        // Check if files exist
        guard fileManager.fileExists(atPath: metadataURL.path) else {
            print("  ❌ metadata.json not found")
            return nil
        }
        
        guard fileManager.fileExists(atPath: mappingsURL.path) else {
            print("  ❌ mappings.json not found")
            return nil
        }
        
        // Load metadata
        guard let metadataData = try? Data(contentsOf: metadataURL),
              let metadataDict = try? JSONSerialization.jsonObject(with: metadataData) as? [String: Any] else {
            print("  ❌ Failed to read metadata.json")
            return nil
        }
        
        guard let name = metadataDict["name"] as? String,
              let author = metadataDict["author"] as? String,
              let description = metadataDict["description"] as? String,
              let version = metadataDict["version"] as? String else {
            print("  ❌ Failed to parse metadata - missing required fields")
            return nil
        }
        
        // Load mappings
        guard let mappingsData = try? Data(contentsOf: mappingsURL),
              let mappingsDict = try? JSONSerialization.jsonObject(with: mappingsData) as? [String: Any] else {
            print("  ❌ Failed to read mappings.json")
            return nil
        }
        
        guard let pressMapDict = mappingsDict["pressMap"] as? [String: [String]],
              let releaseMapDict = mappingsDict["releaseMap"] as? [String: [String]] else {
            print("  ❌ Failed to parse mappings - missing pressMap or releaseMap")
            return nil
        }
        
        // Create sound pack
        var pack = SoundPack(name: name, author: author, description: description, version: version)
        pack.bundlePath = url
        
        // Build key mappings
        var mapping = KeyMapping()
        
        for (keyStr, sounds) in pressMapDict {
            if let keyCode = Int(keyStr) {
                mapping.pressMap[keyCode] = sounds
            }
        }
        
        for (keyStr, sounds) in releaseMapDict {
            if let keyCode = Int(keyStr) {
                mapping.releaseMap[keyCode] = sounds
            }
        }
        
        pack.mappings = mapping
        
        // Load audio file info
        let soundsDir = url.appendingPathComponent("sounds")
        if fileManager.fileExists(atPath: soundsDir.path) {
            if let audioFiles = try? fileManager.contentsOfDirectory(at: soundsDir, includingPropertiesForKeys: nil) {
                let audioExtensions = ["wav", "m4a", "mp3", "aiff", "ogg"]
                for audioURL in audioFiles {
                    let ext = audioURL.pathExtension.lowercased()
                    if audioExtensions.contains(ext) {
                        let filename = audioURL.lastPathComponent
                        pack.sounds[filename] = AudioFile(
                            filename: filename,
                            duration: 0.1,
                            volume: 1.0,
                            category: .keyPress
                        )
                    }
                }
                print("  🎵 Loaded \(pack.sounds.count) audio files")
            }
        } else {
            print("  ⚠️ sounds directory not found")
        }
        
        return pack
    }
    
    // MARK: - Save Pack
    
    func saveSoundPack(_ pack: SoundPack) throws {
        let packURL = soundPacksDirectory.appendingPathComponent("\(pack.id.uuidString).soundpack")
        
        print("💾 Saving sound pack to: \(packURL.path)")
        
        // Create pack directory
        try fileManager.createDirectory(at: packURL, withIntermediateDirectories: true)
        
        // Save metadata
        let metadataURL = packURL.appendingPathComponent("metadata.json")
        let metadata: [String: Any] = [
            "id": pack.id.uuidString,
            "name": pack.name,
            "author": pack.author,
            "description": pack.description,
            "version": pack.version
        ]
        let metadataData = try JSONSerialization.data(withJSONObject: metadata, options: .prettyPrinted)
        try metadataData.write(to: metadataURL)
        print("  ✅ Saved metadata.json")
        
        // Save mappings
        let mappingsURL = packURL.appendingPathComponent("mappings.json")
        var pressMapDict: [String: [String]] = [:]
        var releaseMapDict: [String: [String]] = [:]
        
        for (key, sounds) in pack.mappings.pressMap {
            pressMapDict["\(key)"] = sounds
        }
        
        for (key, sounds) in pack.mappings.releaseMap {
            releaseMapDict["\(key)"] = sounds
        }
        
        let mappingsDict: [String: Any] = [
            "pressMap": pressMapDict,
            "releaseMap": releaseMapDict
        ]
        let mappingsData = try JSONSerialization.data(withJSONObject: mappingsDict, options: .prettyPrinted)
        try mappingsData.write(to: mappingsURL)
        print("  ✅ Saved mappings.json")
        
        print("✅ Sound pack saved successfully")
    }
    
    // MARK: - Delete Pack
    
    func deleteSoundPack(at url: URL) throws {
        guard fileManager.fileExists(atPath: url.path) else {
            print("  ⚠️ Pack doesn't exist at: \(url.path)")
            return
        }
        
        try fileManager.removeItem(at: url)
        print("✅ Deleted sound pack at: \(url.path)")
    }
    
    // MARK: - Export Pack
    
    func exportSoundPack(from sourceURL: URL, to destinationURL: URL) throws {
        // Remove destination if it exists
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        // Copy the entire sound pack directory
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        print("✅ Exported sound pack to: \(destinationURL.path)")
    }
    
    // MARK: - Import Pack
    
    func importSoundPack(from sourceURL: URL) throws -> URL {
        let fileName = sourceURL.lastPathComponent
        let destinationURL = soundPacksDirectory.appendingPathComponent(fileName)
        
        // Remove if already exists
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        // Copy to sound packs directory
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        print("✅ Imported sound pack to: \(destinationURL.path)")
        
        return destinationURL
    }
    
    // MARK: - Validate Pack
    
    func validateSoundPack(at url: URL) -> Bool {
        let metadataPath = url.appendingPathComponent("metadata.json").path
        let mappingsPath = url.appendingPathComponent("mappings.json").path
        let soundsPath = url.appendingPathComponent("sounds").path
        
        let hasMetadata = fileManager.fileExists(atPath: metadataPath)
        let hasMappings = fileManager.fileExists(atPath: mappingsPath)
        let hasSoundsDir = fileManager.fileExists(atPath: soundsPath)
        
        if !hasMetadata {
            print("  ❌ Missing metadata.json")
        }
        if !hasMappings {
            print("  ❌ Missing mappings.json")
        }
        if !hasSoundsDir {
            print("  ⚠️ Missing sounds directory")
        }
        
        return hasMetadata && hasMappings && hasSoundsDir
    }
    
    // MARK: - Get Pack Count
    
    func getSoundPackCount() -> Int {
        guard let contents = try? fileManager.contentsOfDirectory(at: soundPacksDirectory, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return 0
        }
        
        return contents.filter { url in
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
            return isDirectory.boolValue && url.lastPathComponent.hasSuffix(".soundpack")
        }.count
    }
    
    // MARK: - Clear All Packs (for testing)
    
    func deleteAllSoundPacks() throws {
        guard let contents = try? fileManager.contentsOfDirectory(at: soundPacksDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for url in contents {
            if url.lastPathComponent.hasSuffix(".soundpack") {
                try fileManager.removeItem(at: url)
                print("🗑️ Deleted: \(url.lastPathComponent)")
            }
        }
        
        print("✅ All sound packs deleted")
    }
}

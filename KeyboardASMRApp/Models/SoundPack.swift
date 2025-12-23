//
//  SoundPack.swift
//  KeyboardASMRApp
//
//  Created by darwinkernelpanic on 21/12/2025.
//


// ============================================================================
// MARK: - Models/SoundPack.swift
// Data model for sound pack metadata and structure
// ============================================================================

import Foundation

struct SoundPack: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var author: String
    var description: String
    var version: String
    var iconFilename: String?
    var sounds: [String: AudioFile]  // key: filename, value: AudioFile
    var mappings: KeyMapping
    var bundlePath: URL?
    
    init(name: String, author: String, description: String, version: String) {
        self.id = UUID()
        self.name = name
        self.author = author
        self.description = description
        self.version = version
        self.sounds = [:]
        self.mappings = KeyMapping()
    }
    
    static func == (lhs: SoundPack, rhs: SoundPack) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AudioFile: Codable {
    let filename: String
    let duration: Double
    var volume: Float
    var category: AudioCategory
    
    enum AudioCategory: String, Codable {
        case keyPress = "key_press"
        case keyRelease = "key_release"
        case spacebar = "spacebar"
        case modifier = "modifier"
        case function = "function"
        case custom = "custom"
    }
}
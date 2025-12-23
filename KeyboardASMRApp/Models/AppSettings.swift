// ============================================================================
// MARK: - Models/AppSettings.swift
// User preferences with persistence
// ============================================================================

import Foundation

class AppSettings: ObservableObject, Codable {
    @Published var masterVolume: Float = 0.7
    @Published var selectedSoundPackId: UUID?
    @Published var isEnabled: Bool = true
    @Published var launchAtLogin: Bool = false
    @Published var enableModifierKeys: Bool = true
    @Published var enableFunctionKeys: Bool = true
    @Published var reduceVolumeOnRapidTyping: Bool = true
    @Published var customSoundPackDirectory: String = ""
    
    enum CodingKeys: String, CodingKey {
        case masterVolume, selectedSoundPackId, isEnabled, launchAtLogin
        case enableModifierKeys, enableFunctionKeys, reduceVolumeOnRapidTyping
        case customSoundPackDirectory
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        masterVolume = try container.decode(Float.self, forKey: .masterVolume)
        selectedSoundPackId = try container.decodeIfPresent(UUID.self, forKey: .selectedSoundPackId)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        launchAtLogin = try container.decode(Bool.self, forKey: .launchAtLogin)
        enableModifierKeys = try container.decode(Bool.self, forKey: .enableModifierKeys)
        enableFunctionKeys = try container.decode(Bool.self, forKey: .enableFunctionKeys)
        reduceVolumeOnRapidTyping = try container.decode(Bool.self, forKey: .reduceVolumeOnRapidTyping)
        customSoundPackDirectory = try container.decode(String.self, forKey: .customSoundPackDirectory)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(masterVolume, forKey: .masterVolume)
        try container.encodeIfPresent(selectedSoundPackId, forKey: .selectedSoundPackId)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(launchAtLogin, forKey: .launchAtLogin)
        try container.encode(enableModifierKeys, forKey: .enableModifierKeys)
        try container.encode(enableFunctionKeys, forKey: .enableFunctionKeys)
        try container.encode(reduceVolumeOnRapidTyping, forKey: .reduceVolumeOnRapidTyping)
        try container.encode(customSoundPackDirectory, forKey: .customSoundPackDirectory)
    }
    
    init() {}
}
// ============================================================================
// MARK: - Models/AppSettings.swift
// User preferences with pitch and spatial audio
// ============================================================================

import Foundation
import Combine

class AppSettings: ObservableObject, Codable {
    @Published var masterVolume: Float = 0.7
    @Published var selectedSoundPackId: UUID?
    @Published var isEnabled: Bool = true
    @Published var launchAtLogin: Bool = false
    @Published var enableModifierKeys: Bool = true
    @Published var enableFunctionKeys: Bool = true
    @Published var reduceVolumeOnRapidTyping: Bool = true
    @Published var customSoundPackDirectory: String = ""
    
    // NEW: Pitch variation settings
    @Published var enablePitchVariation: Bool = true
    @Published var pitchVariationAmount: Float = 2.0 // semitone range (±)
    
    // NEW: Spatial audio settings
    @Published var enableSpatialAudio: Bool = false
    @Published var spatialAudioWidth: Float = 0.5 // 0.0 to 1.0
    
    enum CodingKeys: String, CodingKey {
        case masterVolume, selectedSoundPackId, isEnabled, launchAtLogin
        case enableModifierKeys, enableFunctionKeys, reduceVolumeOnRapidTyping
        case customSoundPackDirectory
        case enablePitchVariation, pitchVariationAmount
        case enableSpatialAudio, spatialAudioWidth
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
        
        enablePitchVariation = try container.decodeIfPresent(Bool.self, forKey: .enablePitchVariation) ?? true
        pitchVariationAmount = try container.decodeIfPresent(Float.self, forKey: .pitchVariationAmount) ?? 2.0
        
        enableSpatialAudio = try container.decodeIfPresent(Bool.self, forKey: .enableSpatialAudio) ?? false
        spatialAudioWidth = try container.decodeIfPresent(Float.self, forKey: .spatialAudioWidth) ?? 0.5
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
        
        try container.encode(enablePitchVariation, forKey: .enablePitchVariation)
        try container.encode(pitchVariationAmount, forKey: .pitchVariationAmount)
        
        try container.encode(enableSpatialAudio, forKey: .enableSpatialAudio)
        try container.encode(spatialAudioWidth, forKey: .spatialAudioWidth)
    }
    
    init() {}
}

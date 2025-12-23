// ============================================================================
// MARK: - Services/AudioEngine.swift
// AVFoundation with pitch variation and spatial audio
// ============================================================================

import Foundation
import AVFoundation

class AudioEngine {
    static let shared = AudioEngine()
    
    private var audioPlayers: [String: [AVAudioPlayer]] = [:]
    private let poolSize = 5
    private var currentPlayerIndex: [String: Int] = [:]
    private var loadedSounds: [String: URL] = [:]
    
    var masterVolume: Float = 0.7 {
        didSet {
            audioPlayers.values.flatMap { $0 }.forEach { $0.volume = masterVolume }
        }
    }
    
    // NEW: Pitch and spatial audio settings
    var enablePitchVariation: Bool = true
    var pitchVariationAmount: Float = 0.1
    var enableSpatialAudio: Bool = false
    var spatialAudioWidth: Float = 0.5
    
    private init() {}
    
    func loadSound(filename: String, url: URL) {
        loadedSounds[filename] = url
        audioPlayers[filename] = []
        currentPlayerIndex[filename] = 0
        
        // Pre-create player pool
        for _ in 0..<poolSize {
            if let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                player.volume = masterVolume
                player.enableRate = true // Enable pitch shifting
                audioPlayers[filename]?.append(player)
            }
        }
        
        AppLogger.shared.info("Loaded sound: \(filename) with \(poolSize) player instances", category: .audio)
    }
    
    func playSound(_ filename: String, volume: Float = 1.0) {
        guard let players = audioPlayers[filename], !players.isEmpty else {
            AppLogger.shared.warning("No players found for sound: \(filename)", category: .audio)
            return
        }
        
        let index = currentPlayerIndex[filename, default: 0]
        let player = players[index]
        
        // Update to next player in pool
        currentPlayerIndex[filename] = (index + 1) % players.count
        
        // Apply volume
        player.volume = masterVolume * volume
        
        // Apply pitch variation (must be between 0.5 and 2.0)
        if enablePitchVariation {
            let variation = pitchVariationAmount * 0.5 // Scale down for realistic range
            let randomPitch = 1.0 + Float.random(in: -variation...variation)
            player.rate = max(0.5, min(2.0, randomPitch)) // Clamp to valid range
            print("🎵 Pitch: \(player.rate)")
        } else {
            player.rate = 1.0
        }
        
        // Apply spatial audio (pan between -1.0 and 1.0)
        if enableSpatialAudio {
            let randomPan = Float.random(in: -spatialAudioWidth...spatialAudioWidth)
            player.pan = max(-1.0, min(1.0, randomPan)) // Clamp to valid range
            print("🎧 Pan: \(player.pan)")
        } else {
            player.pan = 0.0
        }
        
        player.currentTime = 0
        player.play()
    }
    
    func clearAllSounds() {
        audioPlayers.values.flatMap { $0 }.forEach { $0.stop() }
        audioPlayers.removeAll()
        currentPlayerIndex.removeAll()
        loadedSounds.removeAll()
        
        AppLogger.shared.info("Cleared all sounds from engine", category: .audio)
    }
    
    func stopAllSounds() {
        audioPlayers.values.flatMap { $0 }.forEach { $0.stop() }
    }
}

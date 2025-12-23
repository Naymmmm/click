// ============================================================================
// MARK: - Services/AudioEngine.swift
// AVFoundation audio playback with pooling for low latency
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
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Audio session setup failed: \(error)")
        }
    }
    
    func loadSound(filename: String, url: URL) {
        loadedSounds[filename] = url
        audioPlayers[filename] = []
        currentPlayerIndex[filename] = 0
        
        // Pre-create player pool
        for _ in 0..<poolSize {
            if let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                player.volume = masterVolume
                audioPlayers[filename]?.append(player)
            }
        }
    }
    
    func playSound(_ filename: String, volume: Float = 1.0) {
        guard let players = audioPlayers[filename], !players.isEmpty else {
            return
        }
        
        let index = currentPlayerIndex[filename, default: 0]
        let player = players[index]
        
        // Update to next player in pool
        currentPlayerIndex[filename] = (index + 1) % players.count
        
        player.volume = masterVolume * volume
        player.currentTime = 0
        player.play()
    }
    
    func clearAllSounds() {
        audioPlayers.values.flatMap { $0 }.forEach { $0.stop() }
        audioPlayers.removeAll()
        currentPlayerIndex.removeAll()
        loadedSounds.removeAll()
    }
}
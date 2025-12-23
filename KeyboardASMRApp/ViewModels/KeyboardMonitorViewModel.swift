//
//  KeyboardMonitorViewModel.swift
//  KeyboardASMRApp
//
//  Created by darwinkernelpanic on 21/12/2025.
//


// ============================================================================
// MARK: - ViewModels/KeyboardMonitorViewModel.swift
// Manages keyboard monitoring and sound triggering
// ============================================================================

import Foundation
import Combine

class KeyboardMonitorViewModel: ObservableObject {
    @Published var isMonitoring = false
    @Published var keyPressCount: Int = 0
    private var lastKeyTime: Date = Date()
    private var typingSpeed: Double = 0
    
    private let monitor = KeyboardMonitor.shared
    private let audioEngine = AudioEngine.shared
    private var cancellables = Set<AnyCancellable>()
    private var pressedKeys = Set<Int>()
    
    var currentSoundPack: SoundPack?
    var settings: AppSettings?
    
    init() {
        setupMonitoring()
    }
    
    func setupMonitoring() {
        monitor.onKeyEvent = { [weak self] keyCode, isPress in
            self?.handleKeyEvent(keyCode: Int(keyCode), isPress: isPress)
        }
    }
    
    func startMonitoring() {
        monitor.start()
        isMonitoring = true
    }
    
    func stopMonitoring() {
        monitor.stop()
        isMonitoring = false
        pressedKeys.removeAll()
    }
    
    // Update the handleKeyEvent method in KeyboardMonitorViewModel.swift

    private func handleKeyEvent(keyCode: Int, isPress: Bool) {
        guard let pack = currentSoundPack, settings?.isEnabled == true else { return }
        
        // Suppress repeats by tracking actual key state
        if isPress {
            if pressedKeys.contains(keyCode) {
                return
            } else {
                pressedKeys.insert(keyCode)
            }
        } else {
            pressedKeys.remove(keyCode)
        }
        
        // Check if key type is enabled
        if KeyMapping.modifierKeys.contains(keyCode) && settings?.enableModifierKeys == false {
            return
        }
        if KeyMapping.functionKeys.contains(keyCode) && settings?.enableFunctionKeys == false {
            return
        }
        
        // Calculate typing speed for volume adjustment
        let now = Date()
        let timeDelta = now.timeIntervalSince(lastKeyTime)
        lastKeyTime = now
        
        if timeDelta < 0.1 {
            typingSpeed = min(typingSpeed + 0.1, 1.0)
        } else {
            typingSpeed = max(typingSpeed - 0.1, 0.0)
        }
        
        // Adjust volume based on typing speed
        var volumeMultiplier: Float = 1.0
        if settings?.reduceVolumeOnRapidTyping == true && typingSpeed > 0.5 {
            volumeMultiplier = 0.6
        }
        
        // Apply settings to audio engine
        if let settings = settings {
            audioEngine.enablePitchVariation = settings.enablePitchVariation
            audioEngine.pitchVariationAmount = settings.pitchVariationAmount
            audioEngine.enableSpatialAudio = settings.enableSpatialAudio
            audioEngine.spatialAudioWidth = settings.spatialAudioWidth
        }
        
        // Play appropriate sound
        let soundFile = isPress ? pack.mappings.getSoundForPress(keyCode) : pack.mappings.getSoundForRelease(keyCode)
        
        if let soundFile = soundFile {
            audioEngine.playSound(soundFile, volume: volumeMultiplier)
            
            if isPress {
                keyPressCount += 1
            }
        }
    }
    
    func loadSoundPack(_ pack: SoundPack) {
        currentSoundPack = pack
        
        // Load all sounds into audio engine
        if let bundlePath = pack.bundlePath {
            let soundsDir = bundlePath.appendingPathComponent("sounds")
            for (filename, _) in pack.sounds {
                let soundURL = soundsDir.appendingPathComponent(filename)
                if FileManager.default.fileExists(atPath: soundURL.path) {
                    audioEngine.loadSound(filename: filename, url: soundURL)
                }
            }
        }
    }
}


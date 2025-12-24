// ============================================================================
// MARK: - Services/AudioEngine.swift
// AVFoundation with true pitch variation (time-preserving) and spatial audio
// ============================================================================

import Foundation
import AVFoundation

private struct PlayerChain {
    let node: AVAudioPlayerNode
    let timePitch: AVAudioUnitTimePitch
}

class AudioEngine {
    static let shared = AudioEngine()
    
    private let engine = AVAudioEngine()
    
    // Higher overlap improves quality at the cost of CPU (range ~3...32)
    var timePitchOverlap: Float = 32.0 {
        didSet { updateTimePitchSettings() }
    }
    
    // For each filename, keep a pool of player chains to allow polyphony
    private var players: [String: [PlayerChain]] = [:]
    private var currentPlayerIndex: [String: Int] = [:]
    private var buffers: [String: AVAudioPCMBuffer] = [:]
    
    private let poolSize = 5
    
    var masterVolume: Float = 0.7 {
        didSet { updateAllNodeVolumes() }
    }
    
    // Pitch and spatial audio settings
    // pitchVariationAmount is interpreted as a semitone range (± amount)
    var enablePitchVariation: Bool = true {
        didSet { updatePitchBypass() }
    }
    var pitchVariationAmount: Float = 2.0 // semitones (±)
    var enableSpatialAudio: Bool = false
    var spatialAudioWidth: Float = 0.5
    
    private init() {}
    
    private func startEngine() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            AppLogger.shared.error("Failed to start AVAudioEngine: \(error)", category: .audio)
        }
    }
    
    private func updateAllNodeVolumes() {
        for chains in players.values {
            for chain in chains {
                chain.node.volume = masterVolume
            }
        }
    }
    
    private func updateTimePitchSettings() {
        let clamped = max(3.0, min(32.0, timePitchOverlap))
        for chains in players.values {
            for chain in chains {
                chain.timePitch.overlap = clamped
                chain.timePitch.rate = 1.0
            }
        }
    }
    
    private func updatePitchBypass() {
        for chains in players.values {
            for chain in chains {
                chain.timePitch.bypass = !enablePitchVariation
            }
        }
    }
    
    private func hasActiveGraph() -> Bool {
        // We consider the graph active if there is at least one player chain configured
        return players.values.contains { !$0.isEmpty }
    }

    private func startEngineIfPossible() {
        guard !engine.isRunning else { return }
        guard hasActiveGraph() else {
            // Avoid starting the engine before any nodes are connected to the output
            return
        }
        do {
            try engine.start()
        } catch {
            AppLogger.shared.error("Failed to start AVAudioEngine: \(error)", category: .audio)
        }
    }
    
    private func convertBuffer(_ buffer: AVAudioPCMBuffer, to format: AVAudioFormat) -> AVAudioPCMBuffer? {
        guard buffer.format != format else { return buffer }
        guard let converter = AVAudioConverter(from: buffer.format, to: format) else { return nil }

        let ratio = format.sampleRate / buffer.format.sampleRate
        let outFrameCapacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio)
        guard let outBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: outFrameCapacity) else { return nil }

        var hasProvidedInput = false
        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            if hasProvidedInput {
                outStatus.pointee = .endOfStream
                return nil
            }
            hasProvidedInput = true
            outStatus.pointee = .haveData
            return buffer
        }

        var error: NSError?
        let status = converter.convert(to: outBuffer, error: &error, withInputFrom: inputBlock)
        if error != nil {
            return nil
        }
        switch status {
        case .haveData, .endOfStream, .inputRanDry:
            return outBuffer
        @unknown default:
            return nil
        }
    }
    
    func loadSound(filename: String, url: URL) {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ) else {
                AppLogger.shared.warning("Failed to create buffer for \(filename)", category: .audio)
                return
            }
            try audioFile.read(into: buffer)
            
            let mixerFormat = engine.mainMixerNode.outputFormat(forBus: 0)
            let workingBuffer: AVAudioPCMBuffer
            if buffer.format != mixerFormat, let converted = convertBuffer(buffer, to: mixerFormat) {
                workingBuffer = converted
            } else {
                workingBuffer = buffer
            }
            
            buffers[filename] = workingBuffer
            currentPlayerIndex[filename] = 0
            
            // Create player pool
            var chainArray: [PlayerChain] = []
            for _ in 0..<poolSize {
                let node = AVAudioPlayerNode()
                let timePitch = AVAudioUnitTimePitch()
                timePitch.pitch = 0 // cents
                let clampedOverlap = max(3.0, min(32.0, timePitchOverlap))
                timePitch.overlap = clampedOverlap
                timePitch.rate = 1.0
                timePitch.bypass = !enablePitchVariation

                engine.attach(node)
                engine.attach(timePitch)
                engine.connect(node, to: timePitch, format: workingBuffer.format)
                // Use nil for the connection to the main mixer to avoid unnecessary format coercion here
                engine.connect(timePitch, to: engine.mainMixerNode, format: nil)
                node.volume = masterVolume
                chainArray.append(PlayerChain(node: node, timePitch: timePitch))
            }
            players[filename] = chainArray
            updateTimePitchSettings()
            
            startEngineIfPossible()
            AppLogger.shared.info("Loaded sound: \(filename) into engine with \(poolSize) nodes", category: .audio)
        } catch {
            AppLogger.shared.error("Failed to load sound \(filename): \(error)", category: .audio)
        }
    }
    
    func playSound(_ filename: String, volume: Float = 1.0) {
        guard let chains = players[filename], let buffer = buffers[filename], !chains.isEmpty else {
            AppLogger.shared.warning("No player nodes or buffer for sound: \(filename)", category: .audio)
            return
        }
        
        let index = currentPlayerIndex[filename, default: 0]
        let chain = chains[index]
        currentPlayerIndex[filename] = (index + 1) % chains.count
        
        // Configure volume
        chain.node.volume = masterVolume * volume
        
        // Configure pitch (true pitch shift, preserves duration)
        if enablePitchVariation {
            let semitoneRange = max(0, pitchVariationAmount)
            let randomSemitones = Float.random(in: -semitoneRange...semitoneRange)
            chain.timePitch.pitch = randomSemitones * 100.0 // cents
            chain.timePitch.bypass = false
            print("🎵 Pitch (semitones): \(String(format: "%.2f", randomSemitones))")
        } else {
            chain.timePitch.pitch = 0
            chain.timePitch.bypass = true
        }
        
        // Configure spatial pan
        if enableSpatialAudio {
            let pan = Float.random(in: -spatialAudioWidth...spatialAudioWidth)
            chain.node.pan = max(-1.0, min(1.0, pan))
            print("🎧 Pan: \(String(format: "%.2f", chain.node.pan))")
        } else {
            chain.node.pan = 0.0
        }
        
        if !engine.isRunning {
            startEngineIfPossible()
        }
        
        // Ensure nodes are attached/connected (safety in case of engine reconfig)
        if chain.node.engine == nil || chain.timePitch.engine == nil {
            engine.attach(chain.node)
            engine.attach(chain.timePitch)
            engine.connect(chain.node, to: chain.timePitch, format: buffer.format)
            engine.connect(chain.timePitch, to: engine.mainMixerNode, format: nil)
            chain.timePitch.bypass = !enablePitchVariation
        }
        
        chain.node.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !chain.node.isPlaying {
            chain.node.play()
        }
    }
    
    func clearAllSounds() {
        for chains in players.values {
            for chain in chains {
                chain.node.stop()
                engine.detach(chain.node)
                engine.detach(chain.timePitch)
            }
        }
        players.removeAll()
        buffers.removeAll()
        currentPlayerIndex.removeAll()
        
        AppLogger.shared.info("Cleared all sounds from engine", category: .audio)
    }
    
    func stopAllSounds() {
        for chains in players.values {
            for chain in chains {
                chain.node.stop()
            }
        }
    }
}


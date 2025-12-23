// ============================================================================
// MARK: - Utilities/AudioProcessor.swift
// Audio file processing, normalization, and trimming utilities
// ============================================================================

import Foundation
import AVFoundation

class AudioProcessor {
    
    /// Normalize audio volume to target peak level
    static func normalizeAudio(url: URL, targetPeak: Float = 0.9) throws -> Data {
        let asset = AVURLAsset(url: url)  // ← Changed from AVAsset
        
        // This is a placeholder - full implementation would require AVAudioEngine
        // for actual audio processing and normalization
        
        return try Data(contentsOf: url)
    }
    
    /// Trim silence from start and end of audio file
    static func trimSilence(url: URL, threshold: Float = 0.01) throws -> Data {
        let asset = AVURLAsset(url: url)  // ← Changed from AVAsset
        
        // Placeholder for silence trimming logic
        // Would analyze waveform and trim below threshold
        
        return try Data(contentsOf: url)
    }
    
    /// Get audio duration in seconds
    static func getAudioDuration(url: URL) -> Double {
        let asset = AVURLAsset(url: url)  // ← Changed from AVAsset
        return CMTimeGetSeconds(asset.duration)
    }
    
    /// Extract waveform data for visualization
    static func extractWaveform(url: URL, sampleCount: Int = 100) -> [Float] {
        // Placeholder for waveform extraction
        // Would return amplitude samples for visualization
        
        return Array(repeating: 0.5, count: sampleCount)
    }
}

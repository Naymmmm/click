// ============================================================================
// MARK: - Models/KeyMapping.swift
// Key code to sound mapping structure
// ============================================================================

import Foundation

struct KeyMapping: Codable {
    var pressMap: [Int: [String]] = [:]  // keyCode: [sound filenames for variation]
    var releaseMap: [Int: [String]] = [:]
    
    // Default key groups
    static let modifierKeys = [56, 58, 59, 61, 62, 60, 55] // Shift, Option, Control, Command
    static let functionKeys = Array(122...135) // F1-F12
    static let spacebarKey = 49
    
    mutating func setSound(forKey keyCode: Int, press: String?, release: String?) {
        if let press = press {
            pressMap[keyCode] = [press]
        }
        if let release = release {
            releaseMap[keyCode] = [release]
        }
    }
    
    mutating func setSoundsForGroup(keyCodes: [Int], press: String?, release: String?) {
        for keyCode in keyCodes {
            setSound(forKey: keyCode, press: press, release: release)
        }
    }
    
    func getSoundForPress(_ keyCode: Int) -> String? {
        guard let sounds = pressMap[keyCode], !sounds.isEmpty else { return nil }
        return sounds.randomElement()
    }
    
    func getSoundForRelease(_ keyCode: Int) -> String? {
        guard let sounds = releaseMap[keyCode], !sounds.isEmpty else { return nil }
        return sounds.randomElement()
    }
}
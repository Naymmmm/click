// ============================================================================
// MARK: - Models/KeyMapping.swift
// CORRECT macOS key codes
// ============================================================================

import Foundation

struct KeyMapping: Codable {
    var pressMap: [Int: [String]] = [:]
    var releaseMap: [Int: [String]] = [:]
    
    // CORRECT macOS key codes
    static let modifierKeys = [
        56,  // Left Shift
        60,  // Right Shift
        58,  // Left Option
        61,  // Right Option
        59,  // Left Control
        62,  // Right Control
        55,  // Left Command
        54,  // Right Command
        57,  // Caps Lock
        63   // Fn
    ]
    
    static let functionKeys = [
        122, // F1
        120, // F2
        99,  // F3
        118, // F4
        96,  // F5
        97,  // F6
        98,  // F7
        100, // F8
        101, // F9
        109, // F10
        103, // F11
        111  // F12
    ]
    
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

//
//  KeySoundMapping.swift
//  KeyboardASMRApp
//
//  Created by darwinkernelpanic on 22/12/2025.
//


// ============================================================================
// MARK: - Models/EditorModels.swift
// Editor-specific data models
// ============================================================================

import Foundation

struct KeySoundMapping {
    var pressSound: String?
    var releaseSound: String?
}

struct EditorAudioFile: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
}

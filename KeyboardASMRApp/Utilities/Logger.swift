//
//  Logger.swift
//  KeyboardASMRApp
//
//  Created by darwinkernelpanic on 21/12/2025.
//

// ============================================================================
// MARK: - Utilities/Logger.swift
// Debug logging utility with categorization
// ============================================================================

import Foundation
import os.log

class AppLogger {
    
    enum Category: String {
        case keyboard = "🎹 Keyboard"
        case audio = "🔊 Audio"
        case soundPack = "📦 SoundPack"
        case settings = "⚙️ Settings"
        case permissions = "🔐 Permissions"
        case general = "ℹ️ General"
    }
    
    enum Level {
        case debug
        case info
        case warning
        case error
    }
    
    static let shared = AppLogger()
    private let subsystem = "com.keyboardasmr.app"
    
    private init() {}
    
    func log(_ message: String, category: Category = .general, level: Level = .info) {
        let logger = OSLog(subsystem: subsystem, category: category.rawValue)
        let formattedMessage = "\(category.rawValue) \(message)"
        
        switch level {
        case .debug:
            os_log("%{public}@", log: logger, type: .debug, formattedMessage)
        case .info:
            os_log("%{public}@", log: logger, type: .info, formattedMessage)
        case .warning:
            os_log("%{public}@", log: logger, type: .default, formattedMessage)
        case .error:
            os_log("%{public}@", log: logger, type: .error, formattedMessage)
        }
        
        // Also print to console in debug builds
        #if DEBUG
        print(formattedMessage)
        #endif
    }
    
    // Convenience methods
    func debug(_ message: String, category: Category = .general) {
        log(message, category: category, level: .debug)
    }
    
    func info(_ message: String, category: Category = .general) {
        log(message, category: category, level: .info)
    }
    
    func warning(_ message: String, category: Category = .general) {
        log(message, category: category, level: .warning)
    }
    
    func error(_ message: String, category: Category = .general) {
        log(message, category: category, level: .error)
    }
}

// Global convenience function
func log(_ message: String, category: AppLogger.Category = .general, level: AppLogger.Level = .info) {
    AppLogger.shared.log(message, category: category, level: level)
}

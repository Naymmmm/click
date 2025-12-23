//
//  PermissionsManager.swift
//  KeyboardASMRApp
//
//  Created by darwinkernelpanic on 21/12/2025.
//


// ============================================================================
// MARK: - Services/PermissionsManager.swift
// Handle accessibility permission requests
// ============================================================================

import Foundation
import AppKit

class PermissionsManager {
    static let shared = PermissionsManager()
    
    private init() {}
    
    func hasAccessibilityPermissions() -> Bool {
        return AXIsProcessTrusted()
    }
    
    func requestAccessibilityPermissions() {
        if !hasAccessibilityPermissions() {
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
            AXIsProcessTrustedWithOptions(options)
            
            showPermissionAlert()
        }
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Click needs accessibility permissions to monitor keyboard events system-wide.\n\nPlease enable it in System Settings > Privacy & Security > Accessibility."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}

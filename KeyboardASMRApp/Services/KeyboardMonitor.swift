//
//  KeyboardMonitor.swift
//  KeyboardASMRApp
//
//  Created by darwinkernelpanic on 21/12/2025.
//


// ============================================================================
// MARK: - Services/KeyboardMonitor.swift
// CGEvent-based keyboard monitoring with accessibility permissions
// ============================================================================

import Foundation
import CoreGraphics
import Combine

class KeyboardMonitor {
    static let shared = KeyboardMonitor()
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    var onKeyEvent: ((CGKeyCode, Bool) -> Void)?  // keyCode, isPress
    
    private init() {}
    
    func start() {
        guard PermissionsManager.shared.hasAccessibilityPermissions() else {
            print("⚠️ No accessibility permissions")
            return
        }
        
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(refcon!).takeUnretainedValue()
                
                let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
                let isPress = type == .keyDown
                
                monitor.onKeyEvent?(keyCode, isPress)
                
                return Unmanaged.passRetained(event)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        ) else {
            print("❌ Failed to create event tap")
            return
        }
        
        self.eventTap = eventTap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        
        print("✅ Keyboard monitor started")
    }
    
    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            self.eventTap = nil
            self.runLoopSource = nil
        }
        print("🛑 Keyboard monitor stopped")
    }
}
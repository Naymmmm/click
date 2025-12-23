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
    private var pressedKeys = Set<CGKeyCode>()
    
    private init() {}
    
    func start() {
        guard PermissionsManager.shared.hasAccessibilityPermissions() else {
            print("⚠️ No accessibility permissions")
            return
        }
        
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(refcon!).takeUnretainedValue()

                let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))

                switch type {
                case .keyDown:
                    // Ignore system key auto-repeat and only fire on initial press
                    let isRepeat = event.getIntegerValueField(.keyboardEventAutorepeat) != 0
                    if !isRepeat && !monitor.pressedKeys.contains(keyCode) {
                        monitor.pressedKeys.insert(keyCode)
                        monitor.onKeyEvent?(keyCode, true)
                    }
                case .keyUp:
                    monitor.pressedKeys.remove(keyCode)
                    monitor.onKeyEvent?(keyCode, false)
                case .flagsChanged:
                    // Modifier keys send flagsChanged rather than keyDown/keyUp
                    if monitor.pressedKeys.contains(keyCode) {
                        monitor.pressedKeys.remove(keyCode)
                        monitor.onKeyEvent?(keyCode, false)
                    } else {
                        monitor.pressedKeys.insert(keyCode)
                        monitor.onKeyEvent?(keyCode, true)
                    }
                default:
                    break
                }

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
            pressedKeys.removeAll()
        }
        print("🛑 Keyboard monitor stopped")
    }
}

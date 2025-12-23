// ============================================================================
// MARK: - KeyboardASMRApp.swift
// Main app entry point with menu bar integration
// ============================================================================

import SwiftUI
import AppKit

@main
struct KeyboardASMRApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var keyboardMonitor = KeyboardMonitorViewModel()
    @StateObject private var soundPackManager = SoundPackViewModel()
    @StateObject private var settings = SettingsViewModel()
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    var settingsWindow: NSWindow?
    var editorWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon and main window
        NSApp.setActivationPolicy(.accessory)
        
        // Setup menu bar
        setupMenuBar()
        
        // Request permissions
        PermissionsManager.shared.requestAccessibilityPermissions()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "Keyboard ASMR")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.contentViewController = NSHostingController(rootView: MenuBarView())
            popover.behavior = .transient
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    @objc func showSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "Keyboard ASMR Settings"
            settingsWindow?.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            settingsWindow?.setContentSize(NSSize(width: 600, height: 500))
            settingsWindow?.center()
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func showEditor() {
        if editorWindow == nil {
            let editorView = EditorView()
            let hostingController = NSHostingController(rootView: editorView)
            editorWindow = NSWindow(contentViewController: hostingController)
            editorWindow?.title = "Sound Pack Editor"
            editorWindow?.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            editorWindow?.setContentSize(NSSize(width: 900, height: 700))
            editorWindow?.center()
        }
        editorWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
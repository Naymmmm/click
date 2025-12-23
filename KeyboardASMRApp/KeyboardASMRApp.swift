// ============================================================================
// MARK: - KeyboardASMRApp.swift
// Main app entry point with menu bar integration
// ============================================================================

import SwiftUI
import AppKit

@main
struct KeyboardASMRApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var settingsWindow: NSWindow?
    var editorWindow: NSWindow?
    
    // Simplified - lazy initialization
    lazy var keyboardMonitor = KeyboardMonitorViewModel()
    lazy var soundPackManager = SoundPackViewModel()
    lazy var settings = SettingsViewModel()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 KeyboardASMR: App starting...")
        
        // STEP 1: Set activation policy immediately
        NSApp.setActivationPolicy(.accessory)
        print("✅ Set to accessory mode")
        
        // STEP 2: Create menu bar item IMMEDIATELY (don't wait for anything)
        setupMenuBar()
        
        // STEP 3: Setup notification observers
        setupNotifications()
        
        // STEP 4: Initialize other stuff in background
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.initializeApp()
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenSettings),
            name: NSNotification.Name("OpenSettings"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenEditor),
            name: NSNotification.Name("OpenEditor"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReloadSoundPacks),
            name: NSNotification.Name("ReloadSoundPacks"),
            object: nil
        )
        
        // ADD THIS NEW OBSERVER
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSoundPackChanged),
            name: NSNotification.Name("SoundPackChanged"),
            object: nil
        )
        
        print("✅ Notification observers setup")
    }

    // ADD THIS NEW METHOD
    @objc func handleSoundPackChanged(_ notification: Notification) {
        guard let pack = notification.object as? SoundPack else { return }
        print("🔄 Applying sound pack: \(pack.name)")
        keyboardMonitor.loadSoundPack(pack)
    }
    
    // ADD THIS NEW METHOD
    @objc func handleReloadSoundPacks() {
        print("🔄 Reloading sound packs...")
        soundPackManager.loadPacks()
        
        // Load the first pack if none selected
        if soundPackManager.selectedPack == nil, let firstPack = soundPackManager.availablePacks.first {
            soundPackManager.selectPack(firstPack)
            keyboardMonitor.loadSoundPack(firstPack)
        }
        
        print("✅ Sound packs reloaded: \(soundPackManager.availablePacks.count) packs")
    }
    
    func setupMenuBar() {
        print("🔧 Creating menu bar item...")
        
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let statusItem = statusItem else {
            print("❌ CRITICAL: Failed to create status item!")
            return
        }
        
        guard let button = statusItem.button else {
            print("❌ CRITICAL: Status item has no button!")
            return
        }
        
        // Set icon
        if let icon = NSImage(systemSymbolName: "waveform", accessibilityDescription: "Click") {
            button.image = icon
            print("✅ Menu bar icon set")
        } else {
            // Fallback to text if icon fails
            button.title = "⌨️"
            print("⚠️ Using fallback text icon")
        }
        
        button.action = #selector(togglePopover)
        button.target = self
        
        print("✅ Menu bar item created successfully!")
    }
    
    func initializeApp() {
        print("🔧 Initializing app components...")
        
        do {
            // Initialize view models
            _ = settings
            _ = soundPackManager
            _ = keyboardMonitor
            
            print("✅ View models initialized")
            
            // Configure monitor
            keyboardMonitor.settings = settings.settings
            
            if let firstPack = soundPackManager.availablePacks.first {
                keyboardMonitor.loadSoundPack(firstPack)
                print("✅ Loaded sound pack: \(firstPack.name)")
            } else {
                print("⚠️ No sound packs available")
            }
            
            // Start monitoring if enabled
            if settings.settings.isEnabled {
                keyboardMonitor.startMonitoring()
                print("✅ Keyboard monitoring started")
            }
            
            // Request permissions
            PermissionsManager.shared.requestAccessibilityPermissions()
            
            print("✅ App initialization complete!")
            
        } catch {
            print("❌ Error during initialization: \(error)")
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        print("🖱️ Menu bar icon clicked")
        
        guard let button = statusItem?.button else {
            print("❌ No button available")
            return
        }
        
        if let popover = popover, popover.isShown {
            popover.performClose(sender)
            self.popover = nil
            print("👋 Closed popover")
        } else {
            showPopover(relativeTo: button.bounds, of: button)
        }
    }
    
    func showPopover(relativeTo rect: NSRect, of view: NSView) {
        print("📂 Creating popover...")
        
        let newPopover = NSPopover()
        
        let menuBarView = MenuBarView()
            .environmentObject(keyboardMonitor)
            .environmentObject(soundPackManager)
            .environmentObject(settings)
        
        newPopover.contentViewController = NSHostingController(rootView: menuBarView)
        newPopover.behavior = .transient
        newPopover.show(relativeTo: rect, of: view, preferredEdge: .minY)
        
        self.popover = newPopover
        print("✅ Popover displayed")
    }
    
    @objc func handleOpenSettings() {
        print("⚙️ Opening settings window via notification...")
        
        // Close popover first
        popover?.performClose(nil)
        popover = nil
        
        // Create or show settings window
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            
            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "Click Settings"
            settingsWindow?.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            settingsWindow?.setContentSize(NSSize(width: 600, height: 500))
            settingsWindow?.center()
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print("✅ Settings window opened")
    }
    
    @objc func handleOpenEditor() {
        print("✏️ Opening editor window via notification...")
        
        // Close popover first
        popover?.performClose(nil)
        popover = nil
        
        // Create or show editor window
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
        
        print("✅ Editor window opened")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("👋 App terminating...")
        keyboardMonitor.stopMonitoring()
        AudioEngine.shared.clearAllSounds()
        NotificationCenter.default.removeObserver(self)
    }
}

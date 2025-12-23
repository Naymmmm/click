// ============================================================================
// MARK: - ViewModels/SoundPackViewModel.swift
// Sound pack management with notifications
// ============================================================================

import Foundation
import Combine
import AppKit

class SoundPackViewModel: ObservableObject {
    @Published var availablePacks: [SoundPack] = []
    @Published var selectedPack: SoundPack? {
        didSet {
            if let pack = selectedPack {
                // Notify keyboard monitor to load the new pack
                NotificationCenter.default.post(
                    name: NSNotification.Name("SoundPackChanged"),
                    object: pack
                )
                print("🔄 Sound pack changed to: \(pack.name)")
            }
        }
    }
    
    private let manager = SoundPackManager.shared
    
    init() {
        loadPacks()
    }
    
    func loadPacks() {
        availablePacks = manager.loadAllSoundPacks()
        if selectedPack == nil, let first = availablePacks.first {
            selectedPack = first
        }
    }
    
    func selectPack(_ pack: SoundPack) {
        selectedPack = pack
    }
    
    func importPack() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowedContentTypes = []
        panel.message = "Select a .soundpack folder to import"
        
        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.importPack(from: url)
            }
        }
    }
    
    func importPack(from url: URL) {
        guard url.pathExtension == "soundpack" || url.lastPathComponent.hasSuffix(".soundpack") else {
            print("❌ Not a valid sound pack")
            return
        }
        
        do {
            _ = try manager.importSoundPack(from: url)
            print("✅ Imported sound pack from: \(url.path)")
            loadPacks()
        } catch {
            print("❌ Import failed: \(error)")
        }
    }
}

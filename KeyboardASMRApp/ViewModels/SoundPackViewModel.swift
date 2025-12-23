// ============================================================================
// MARK: - ViewModels/SoundPackViewModel.swift
// Sound pack management and switching
// ============================================================================

import Foundation
import Combine

class SoundPackViewModel: ObservableObject {
    @Published var availablePacks: [SoundPack] = []
    @Published var selectedPack: SoundPack?
    
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
    
    func importPack(from url: URL) {
        if let pack = manager.loadSoundPack(from: url) {
            availablePacks.append(pack)
        }
    }
}
// ============================================================================
// MARK: - ViewModels/SettingsViewModel.swift
// Settings management with proper pack selection
// ============================================================================

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var settings = AppSettings()
    
    private let defaults = UserDefaults.standard
    private let settingsKey = "appSettings"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        
        // Auto-save when settings change
        $settings
            .dropFirst()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
    }
    
    func loadSettings() {
        if let data = defaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: settingsKey)
            print("💾 Settings saved")
        }
    }
}

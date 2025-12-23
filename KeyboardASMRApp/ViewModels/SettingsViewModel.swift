// ============================================================================
// MARK: - ViewModels/SettingsViewModel.swift
// Settings management and persistence
// ============================================================================

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var settings = AppSettings()
    
    private let defaults = UserDefaults.standard
    private let settingsKey = "appSettings"
    
    init() {
        loadSettings()
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
        }
    }
}
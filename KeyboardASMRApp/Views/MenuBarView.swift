// ============================================================================
// MARK: - Views/MenuBarView.swift
// Menu bar popover with quick controls
// ============================================================================

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var keyboardMonitor: KeyboardMonitorViewModel
    @EnvironmentObject var soundPacks: SoundPackViewModel
    @EnvironmentObject var settings: SettingsViewModel
    @AppStorage("isEnabled") private var isEnabled = true
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "waveform")
                    .font(.title2)
                Text("Keyboard ASMR")
                    .font(.headline)
                Spacer()
            }
            .padding(.bottom, 8)
            
            Divider()
            
            // Enable/Disable Toggle
            Toggle(isOn: $isEnabled) {
                Label("Enabled", systemImage: isEnabled ? "speaker.wave.3" : "speaker.slash")
            }
            .toggleStyle(.switch)
            
            // Volume Control
            VStack(alignment: .leading, spacing: 8) {
                Label("Volume", systemImage: "speaker.wave.2")
                    .font(.subheadline)
                Slider(value: $settings.settings.masterVolume, in: 0...1)
                    .onChange(of: settings.settings.masterVolume) { _, newValue in
                        AudioEngine.shared.masterVolume = Float(newValue)
                    }
            }
            
            // Sound Pack Selector
            VStack(alignment: .leading, spacing: 8) {
                Label("Sound Pack", systemImage: "music.note.list")
                    .font(.subheadline)
                
                Picker("", selection: $soundPacks.selectedPack) {
                    ForEach(soundPacks.availablePacks) { pack in
                        Text(pack.name).tag(pack as SoundPack?)
                    }
                }
                .labelsHidden()
            }
            
            Divider()
            
            // Quick Actions
            VStack(spacing: 8) {
                Button(action: openSettings) {
                    Label("Settings", systemImage: "gear")
                        .frame(maxWidth: .infinity)
                }
                
                Button(action: openEditor) {
                    Label("Sound Pack Editor", systemImage: "waveform.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                
                Button(action: quit) {
                    Label("Quit", systemImage: "power")
                        .frame(maxWidth: .infinity)
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 280)
    }
    
    func openSettings() {
        if let delegate = NSApp.delegate as? AppDelegate {
            delegate.showSettings()
        }
    }
    
    func openEditor() {
        if let delegate = NSApp.delegate as? AppDelegate {
            delegate.showEditor()
        }
    }
    
    func quit() {
        NSApp.terminate(nil)
    }
}
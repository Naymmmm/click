// ============================================================================
// MARK: - Views/MenuBarView.swift
// Menu bar popover with quick controls - NOTIFICATION VERSION
// ============================================================================

import SwiftUI
import AppKit

struct MenuBarView: View {
    @EnvironmentObject var keyboardMonitor: KeyboardMonitorViewModel
    @EnvironmentObject var soundPacks: SoundPackViewModel
    @EnvironmentObject var settings: SettingsViewModel
    @State private var isEnabled = true
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "waveform")
                    .font(.title2)
                Text("Click")
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
            .onChange(of: isEnabled) { oldValue, newValue in
                settings.settings.isEnabled = newValue
                if newValue {
                    keyboardMonitor.startMonitoring()
                } else {
                    keyboardMonitor.stopMonitoring()
                }
            }
            
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
            // Update the Sound Pack Selector section in MenuBarView.swift
            // Sound Pack Selector
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Sound Pack", systemImage: "music.note.list")
                                .font(.subheadline)
                            
                            if soundPacks.availablePacks.isEmpty {
                                Text("No available soundpacks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(6)
                            } else {
                                Picker("", selection: $soundPacks.selectedPack) {
                                    ForEach(soundPacks.availablePacks) { pack in
                                        Text(pack.name).tag(pack as SoundPack?)
                                    }
                                }
                                .labelsHidden()
                                .onChange(of: soundPacks.selectedPack) { _, newPack in
                                    if let pack = newPack {
                                        keyboardMonitor.loadSoundPack(pack)
                                    }
                                }
                            }
                        }
            
            Divider()
            
            // Quick Actions
            VStack(spacing: 8) {
                Button(action: {
                    print("⚙️ Settings button clicked - posting notification")
                    NotificationCenter.default.post(name: NSNotification.Name("OpenSettings"), object: nil)
                }) {
                    Label("Settings", systemImage: "gear")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    print("✏️ Editor button clicked - posting notification")
                    NotificationCenter.default.post(name: NSNotification.Name("OpenEditor"), object: nil)
                }) {
                    Label("Sound Pack Editor", systemImage: "waveform.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    print("👋 Quit button clicked")
                    NSApp.terminate(nil)
                }) {
                    Label("Quit", systemImage: "power")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 280)
        .onAppear {
            isEnabled = settings.settings.isEnabled
        }
    }
}

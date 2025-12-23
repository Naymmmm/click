// ============================================================================
// MARK: - Views/SettingsView.swift
// COMPLETE Settings with all tabs - FULL VERSION
// ============================================================================

import SwiftUI
import AppKit

struct SettingsView: View {
    @StateObject private var settings = SettingsViewModel()
    @StateObject private var soundPacks = SoundPackViewModel()
    
    var body: some View {
        TabView {
            GeneralSettingsTab(settings: settings, soundPacks: soundPacks)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            AudioSettingsTab(settings: settings)
                .tabItem {
                    Label("Audio", systemImage: "speaker.wave.2")
                }
            
            KeyboardSettingsTab(settings: settings)
                .tabItem {
                    Label("Keyboard", systemImage: "keyboard")
                }
            
            AdvancedSettingsTab(settings: settings)
                .tabItem {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
        }
        .frame(width: 650, height: 550)
    }
}

// ============================================================================
// MARK: - General Tab
// ============================================================================

struct GeneralSettingsTab: View {
    @ObservedObject var settings: SettingsViewModel
    @ObservedObject var soundPacks: SoundPackViewModel
    @State private var showDeleteAlert = false
    @State private var packToDelete: SoundPack?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("General Settings")
                        .font(.title2)
                        .bold()
                    
                    Text("Configure your keyboard sound experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Sound Packs Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Label("Sound Packs", systemImage: "music.note.list")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            soundPacks.importPack()
                        }) {
                            Label("Import", systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button(action: {
                            soundPacks.loadPacks()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        .buttonStyle(.borderless)
                        .help("Refresh sound packs")
                    }
                    
                    if soundPacks.availablePacks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            Text("No sound packs available")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Create a new sound pack using the Sound Pack Editor")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Open Editor") {
                                NotificationCenter.default.post(name: NSNotification.Name("OpenEditor"), object: nil)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(soundPacks.availablePacks) { pack in
                                SoundPackCard(
                                    pack: pack,
                                    isSelected: soundPacks.selectedPack?.id == pack.id,
                                    onSelect: {
                                        soundPacks.selectPack(pack)
                                    },
                                    onDelete: {
                                        packToDelete = pack
                                        showDeleteAlert = true
                                    },
                                    onShare: {
                                        shareSoundPack(pack)
                                    }
                                )
                            }
                        }
                    }
                }
                
                Divider()
                
                // Startup Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Startup", systemImage: "power")
                        .font(.headline)
                    
                    Toggle(isOn: $settings.settings.launchAtLogin) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Launch at Login")
                                .font(.body)
                            
                            Text("Automatically start Click when you log in")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .toggleStyle(.switch)
                }
            }
            .padding(24)
        }
        .alert("Delete Sound Pack?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let pack = packToDelete {
                    deleteSoundPack(pack)
                }
            }
        } message: {
            if let pack = packToDelete {
                Text("Are you sure you want to delete '\(pack.name)'? This cannot be undone.")
            }
        }
    }
    
    func deleteSoundPack(_ pack: SoundPack) {
        guard let bundlePath = pack.bundlePath else { return }
        
        do {
            try FileManager.default.removeItem(at: bundlePath)
            soundPacks.loadPacks()
            print("✅ Deleted sound pack: \(pack.name)")
            
            // If deleted pack was selected, select another
            if soundPacks.selectedPack?.id == pack.id {
                soundPacks.selectedPack = soundPacks.availablePacks.first
            }
        } catch {
            print("❌ Failed to delete sound pack: \(error)")
            showAlert(title: "Delete Failed", message: error.localizedDescription)
        }
    }
    
    func shareSoundPack(_ pack: SoundPack) {
        guard let bundlePath = pack.bundlePath else { return }
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(pack.name).soundpack"
        panel.canCreateDirectories = true
        panel.showsTagField = false
        
        panel.begin { response in
            if response == .OK, let destination = panel.url {
                do {
                    // Remove existing if present
                    try? FileManager.default.removeItem(at: destination)
                    
                    // Copy the sound pack
                    try FileManager.default.copyItem(at: bundlePath, to: destination)
                    
                    print("✅ Exported sound pack to: \(destination.path)")
                    showAlert(title: "Export Successful", message: "Sound pack exported to:\n\(destination.path)")
                } catch {
                    print("❌ Export failed: \(error)")
                    showAlert(title: "Export Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

struct SoundPackCard: View {
    let pack: SoundPack
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "waveform")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .secondary)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(pack.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(pack.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !pack.description.isEmpty {
                    Text(pack.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                }
                .buttonStyle(.borderless)
                .help("Share sound pack")
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
                .help("Delete sound pack")
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.08) : Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

// ============================================================================
// MARK: - Audio Tab
// ============================================================================

struct AudioSettingsTab: View {
    @ObservedObject var settings: SettingsViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Audio Settings")
                        .font(.title2)
                        .bold()
                    
                    Text("Adjust volume and audio behavior")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Volume Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Volume", systemImage: "speaker.wave.2")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "speaker.wave.1")
                                .foregroundColor(.secondary)
                            
                            Slider(value: $settings.settings.masterVolume, in: 0...1)
                                .onChange(of: settings.settings.masterVolume) { _, newValue in
                                    AudioEngine.shared.masterVolume = Float(newValue)
                                }
                            
                            Image(systemName: "speaker.wave.3")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Spacer()
                            Text("\(Int(settings.settings.masterVolume * 100))%")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .monospacedDigit()
                            Spacer()
                        }
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                
                Divider()
                
                // Pitch Variation Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Pitch Variation", systemImage: "waveform.path")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Pitch Variation")
                                    .font(.body)
                                
                                Text("Randomly varies pitch for natural typing sound")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $settings.settings.enablePitchVariation)
                                .labelsHidden()
                        }
                        
                        if settings.settings.enablePitchVariation {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Variation Amount")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(Int(settings.settings.pitchVariationAmount * 100))%")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        .monospacedDigit()
                                }
                                
                                Slider(value: $settings.settings.pitchVariationAmount, in: 0.05...0.3)
                                
                                HStack {
                                    Text("Subtle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("Extreme")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.leading, 20)
                        }
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                
                Divider()
                
                // Spatial Audio Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Spatial Audio", systemImage: "airpodspro")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Spatial Audio")
                                    .font(.body)
                                
                                Text("Adds stereo positioning to key sounds")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $settings.settings.enableSpatialAudio)
                                .labelsHidden()
                        }
                        
                        if settings.settings.enableSpatialAudio {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Stereo Width")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(Int(settings.settings.spatialAudioWidth * 100))%")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        .monospacedDigit()
                                }
                                
                                Slider(value: $settings.settings.spatialAudioWidth, in: 0.1...1.0)
                                
                                HStack {
                                    Text("Narrow")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("Wide")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.leading, 20)
                        }
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                
                Divider()
                
                // Behavior Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Behavior", systemImage: "sparkles")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reduce volume during rapid typing")
                                .font(.body)
                            
                            Text("Automatically lower volume when typing fast")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.settings.reduceVolumeOnRapidTyping)
                            .labelsHidden()
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
}
// ============================================================================
// MARK: - Keyboard Tab
// ============================================================================

struct KeyboardSettingsTab: View {
    @ObservedObject var settings: SettingsViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Keyboard Settings")
                        .font(.title2)
                        .bold()
                    
                    Text("Choose which keys trigger sounds")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Key Types Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Key Types", systemImage: "keyboard")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        Toggle(isOn: $settings.settings.enableModifierKeys) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Modifier Keys (Not supported, toggle will not work)")
                                    .font(.body)
                                
                                Text("Command, Option, Control, Shift")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(.switch)
                        
                        Divider()
                        
                        Toggle(isOn: $settings.settings.enableFunctionKeys) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Function Keys (Not supported, toggle will not work)")
                                    .font(.body)
                                
                                Text("F1, F2, F3... F12")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(.switch)
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
}

// ============================================================================
// MARK: - Advanced Tab
// ============================================================================

struct AdvancedSettingsTab: View {
    @ObservedObject var settings: SettingsViewModel
    @State private var showingSoundPackLocation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Advanced Settings")
                        .font(.title2)
                            .bold()
                    
                    Text("Permissions and advanced configuration")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Permissions Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Permissions", systemImage: "lock.shield")
                        .font(.headline)
                    
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Accessibility Access")
                                    .font(.body)
                                
                                Text("Required to monitor keyboard events system-wide")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Grant Permission") {
                                PermissionsManager.shared.requestAccessibilityPermissions()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(16)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                
                Divider()
                
                // File Locations Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("File Locations", systemImage: "folder")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sound Packs Directory")
                                    .font(.body)
                                
                                Text("~/Library/Application Support/KeyboardASMR/SoundPacks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Show in Finder") {
                                showSoundPacksInFinder()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                
                Divider()
                
                // About Section
                // About Section in AdvancedSettingsTab
                VStack(alignment: .leading, spacing: 16) {
                    Label("About", systemImage: "info.circle")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Version:")
                                .foregroundColor(.secondary)
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        }
                        
                        HStack {
                            Text("Build:")
                                .foregroundColor(.secondary)
                            Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                        }
                    }
                    .font(.caption)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }

                Spacer()
            }
            .padding(24)
        }
    }
    
    func showSoundPacksInFinder() {
        let soundPacksDir = SoundPackManager.shared.soundPacksDirectory
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: soundPacksDir.path)
    }
}

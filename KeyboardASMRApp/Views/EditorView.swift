// ============================================================================
// MARK: - Views/EditorView.swift
// Sound pack editor with multi-select and key info
// ============================================================================

import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @StateObject private var viewModel = EditorViewModel()
    
    var body: some View {
        HSplitView {
            // Left panel - Metadata & Audio Files
            VStack(alignment: .leading, spacing: 20) {
                Text("Sound Pack Editor")
                    .font(.title2)
                    .bold()
                
                // Metadata Section
                GroupBox(label: Label("Pack Information", systemImage: "info.circle")) {
                    VStack(spacing: 12) {
                        TextField("Pack Name", text: $viewModel.packName)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Author", text: $viewModel.author)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Description", text: $viewModel.description, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...5)
                        
                        TextField("Version", text: $viewModel.version)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(8)
                }
                
                // Audio Files Section
                GroupBox(label: Label("Audio Files (\(viewModel.audioFiles.count))", systemImage: "waveform")) {
                    VStack(spacing: 8) {
                        // Drop zone
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundColor(viewModel.isDragging ? .blue : .gray)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(viewModel.isDragging ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                                )
                            
                            VStack(spacing: 8) {
                                Image(systemName: "arrow.down.doc")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                
                                Text("Drop audio files here")
                                    .font(.headline)
                                
                                Text("or")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("Browse Files...") {
                                    viewModel.openFilePicker()
                                }
                                .buttonStyle(.bordered)
                                
                                Text("WAV, M4A, MP3, AIFF, OGG")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .frame(height: 130)
                        .onDrop(of: [.fileURL], isTargeted: $viewModel.isDragging) { providers in
                            viewModel.handleDrop(providers: providers)
                            return true
                        }
                        
                        // File list
                        if !viewModel.audioFiles.isEmpty {
                            Divider()
                            
                            ScrollView {
                                VStack(spacing: 4) {
                                    ForEach(viewModel.audioFiles) { file in
                                        AudioFileRow(file: file, onDelete: {
                                            viewModel.removeFile(file)
                                        })
                                    }
                                }
                            }
                            .frame(maxHeight: 180)
                        }
                    }
                    .padding(8)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button("Clear All") {
                        viewModel.clearAll()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Export Pack") {
                        viewModel.exportPack()
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.audioFiles.isEmpty)
                    
                    Button("Save Pack") {
                        viewModel.savePack()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.audioFiles.isEmpty)
                }
            }
            .padding(20)
            .frame(minWidth: 350, maxWidth: 400)
            
            // Right panel - Virtual Keyboard
            VStack(spacing: 16) {
                HStack {
                    Text("Virtual Keyboard")
                        .font(.headline)
                    
                    Spacer()
                    
                    if !viewModel.selectedKeys.isEmpty {
                        Text("\(viewModel.selectedKeys.count) key(s) selected")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Button("Deselect All") {
                            viewModel.selectedKeys.removeAll()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                
                KeyboardVisualizerView(viewModel: viewModel)
                
                // Key Assignment Section
                if !viewModel.selectedKeys.isEmpty {
                    GroupBox(label: Label("Sound Assignment", systemImage: "link")) {
                        VStack(spacing: 12) {
                            // Show current mapping if single key selected
                            if viewModel.selectedKeys.count == 1,
                               let key = viewModel.selectedKeys.first,
                               let mapping = viewModel.getMapping(for: key) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Current Mapping for \(KeyCodeMapper.keyName(for: key))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if let press = mapping.pressSound {
                                        HStack {
                                            Image(systemName: "arrow.down")
                                                .foregroundColor(.green)
                                            Text("Press: \(press)")
                                                .font(.caption)
                                        }
                                    }
                                    
                                    if let release = mapping.releaseSound {
                                        HStack {
                                            Image(systemName: "arrow.up")
                                                .foregroundColor(.orange)
                                            Text("Release: \(release)")
                                                .font(.caption)
                                        }
                                    }
                                    
                                    Divider()
                                }
                            }
                            
                            HStack {
                                Text("Press Sound:")
                                    .frame(width: 100, alignment: .leading)
                                
                                Picker("", selection: $viewModel.selectedPressSound) {
                                    Text("None").tag(nil as String?)
                                    ForEach(viewModel.audioFiles) { file in
                                        Text(file.name).tag(file.name as String?)
                                    }
                                }
                                .labelsHidden()
                            }
                            
                            HStack {
                                Text("Release Sound:")
                                    .frame(width: 100, alignment: .leading)
                                
                                Picker("", selection: $viewModel.selectedReleaseSound) {
                                    Text("None").tag(nil as String?)
                                    ForEach(viewModel.audioFiles) { file in
                                        Text(file.name).tag(file.name as String?)
                                    }
                                }
                                .labelsHidden()
                            }
                            
                            HStack(spacing: 8) {
                                Button("Remove Sounds") {
                                    viewModel.removeSoundsFromSelectedKeys()
                                }
                                .buttonStyle(.bordered)
                                
                                Spacer()
                                
                                Button("Apply to Selected") {
                                    viewModel.assignSoundsToSelectedKeys()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(viewModel.selectedPressSound == nil && viewModel.selectedReleaseSound == nil)
                            }
                        }
                        .padding(8)
                    }
                }
                
                Spacer()
            }
            .padding(20)
        }
        .frame(minWidth: 1000, minHeight: 700)
    }
}

struct AudioFileRow: View {
    let file: EditorAudioFile
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "waveform")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.subheadline)
                
                Text(file.url.path)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.borderless)
        }
        .padding(8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(6)
    }
}

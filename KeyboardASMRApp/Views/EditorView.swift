// ============================================================================
// MARK: - Views/EditorView.swift
// Sound pack editor interface
// ============================================================================

import SwiftUI

struct EditorView: View {
    @State private var packName = "New Sound Pack"
    @State private var author = ""
    @State private var description = ""
    @State private var selectedKey: Int?
    
    var body: some View {
        HSplitView {
            // Left panel - Metadata
            VStack(alignment: .leading, spacing: 16) {
                Text("Sound Pack Editor")
                    .font(.title2)
                    .bold()
                
                Form {
                    TextField("Pack Name", text: $packName)
                    TextField("Author", text: $author)
                    TextField("Description", text: $description)
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Audio Files")
                        .font(.headline)
                    
                    Text("Drag and drop audio files here")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                HStack {
                    Button("Export Pack") {
                        // Export functionality
                    }
                    Spacer()
                    Button("Save") {
                        // Save functionality
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(minWidth: 300)
            
            // Right panel - Virtual Keyboard
            VStack {
                Text("Virtual Keyboard")
                    .font(.headline)
                
                KeyboardVisualizerView(selectedKey: $selectedKey)
                
                if let key = selectedKey {
                    Text("Selected: Key \(key)")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .frame(minWidth: 900, minHeight: 700)
    }
}
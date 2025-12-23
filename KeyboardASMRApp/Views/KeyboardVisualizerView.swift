// ============================================================================
// MARK: - Views/KeyboardVisualizerView.swift
// Virtual keyboard for key mapping
// ============================================================================

import SwiftUI

struct KeyboardVisualizerView: View {
    @Binding var selectedKey: Int?
    
    let rows: [[String]] = [
        ["ESC", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12"],
        ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "DEL"],
        ["TAB", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\"],
        ["CAPS", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "RETURN"],
        ["SHIFT", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "SHIFT"],
        ["FN", "CTRL", "OPT", "CMD", "SPACE", "CMD", "OPT", "◀", "▲▼", "▶"]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 6) {
                    ForEach(rows[rowIndex], id: \.self) { key in
                        KeyCapView(label: key, isSelected: false)
                            .onTapGesture {
                                selectedKey = rowIndex * 100 + rows[rowIndex].firstIndex(of: key)!
                            }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct KeyCapView: View {
    let label: String
    let isSelected: Bool
    
    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .frame(minWidth: keyWidth, minHeight: 35)
            .background(isSelected ? Color.blue : Color.white)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
    }
    
    var keyWidth: CGFloat {
        switch label {
        case "TAB", "CAPS", "RETURN": return 60
        case "SHIFT": return 80
        case "SPACE": return 200
        case "DEL": return 50
        default: return 40
        }
    }
}
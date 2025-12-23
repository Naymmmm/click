// ============================================================================
// MARK: - Views/KeyboardVisualizerView.swift
// Fixed arrow keys - inverted-T layout with half-height
// ============================================================================

import SwiftUI

struct KeyboardVisualizerView: View {
    @ObservedObject var viewModel: EditorViewModel
    
    let rows: [[KeyboardKey]] = [
        // Function row
        [
            KeyboardKey(label: "esc", keyCode: 53, width: 50),
            KeyboardKey(label: "", keyCode: -1, width: 40, isSpace: true),
            KeyboardKey(label: "F1", keyCode: 122, width: 50),
            KeyboardKey(label: "F2", keyCode: 120, width: 50),
            KeyboardKey(label: "F3", keyCode: 99, width: 50),
            KeyboardKey(label: "F4", keyCode: 118, width: 50),
            KeyboardKey(label: "", keyCode: -2, width: 20, isSpace: true),
            KeyboardKey(label: "F5", keyCode: 96, width: 50),
            KeyboardKey(label: "F6", keyCode: 97, width: 50),
            KeyboardKey(label: "F7", keyCode: 98, width: 50),
            KeyboardKey(label: "F8", keyCode: 100, width: 50),
            KeyboardKey(label: "", keyCode: -3, width: 20, isSpace: true),
            KeyboardKey(label: "F9", keyCode: 101, width: 50),
            KeyboardKey(label: "F10", keyCode: 109, width: 50),
            KeyboardKey(label: "F11", keyCode: 103, width: 50),
            KeyboardKey(label: "F12", keyCode: 111, width: 50)
        ],
        // Number row
        [
            KeyboardKey(label: "`", keyCode: 50, width: 50),
            KeyboardKey(label: "1", keyCode: 18, width: 50),
            KeyboardKey(label: "2", keyCode: 19, width: 50),
            KeyboardKey(label: "3", keyCode: 20, width: 50),
            KeyboardKey(label: "4", keyCode: 21, width: 50),
            KeyboardKey(label: "5", keyCode: 23, width: 50),
            KeyboardKey(label: "6", keyCode: 22, width: 50),
            KeyboardKey(label: "7", keyCode: 26, width: 50),
            KeyboardKey(label: "8", keyCode: 28, width: 50),
            KeyboardKey(label: "9", keyCode: 25, width: 50),
            KeyboardKey(label: "0", keyCode: 29, width: 50),
            KeyboardKey(label: "-", keyCode: 27, width: 50),
            KeyboardKey(label: "=", keyCode: 24, width: 50),
            KeyboardKey(label: "delete", keyCode: 51, width: 90)
        ],
        // Top letter row
        [
            KeyboardKey(label: "tab", keyCode: 48, width: 75),
            KeyboardKey(label: "Q", keyCode: 12, width: 50),
            KeyboardKey(label: "W", keyCode: 13, width: 50),
            KeyboardKey(label: "E", keyCode: 14, width: 50),
            KeyboardKey(label: "R", keyCode: 15, width: 50),
            KeyboardKey(label: "T", keyCode: 17, width: 50),
            KeyboardKey(label: "Y", keyCode: 16, width: 50),
            KeyboardKey(label: "U", keyCode: 32, width: 50),
            KeyboardKey(label: "I", keyCode: 34, width: 50),
            KeyboardKey(label: "O", keyCode: 31, width: 50),
            KeyboardKey(label: "P", keyCode: 35, width: 50),
            KeyboardKey(label: "[", keyCode: 33, width: 50),
            KeyboardKey(label: "]", keyCode: 30, width: 50),
            KeyboardKey(label: "\\", keyCode: 42, width: 65)
        ],
        // Home row
        [
            KeyboardKey(label: "caps", keyCode: 57, width: 90),
            KeyboardKey(label: "A", keyCode: 0, width: 50),
            KeyboardKey(label: "S", keyCode: 1, width: 50),
            KeyboardKey(label: "D", keyCode: 2, width: 50),
            KeyboardKey(label: "F", keyCode: 3, width: 50),
            KeyboardKey(label: "G", keyCode: 5, width: 50),
            KeyboardKey(label: "H", keyCode: 4, width: 50),
            KeyboardKey(label: "J", keyCode: 38, width: 50),
            KeyboardKey(label: "K", keyCode: 40, width: 50),
            KeyboardKey(label: "L", keyCode: 37, width: 50),
            KeyboardKey(label: ";", keyCode: 41, width: 50),
            KeyboardKey(label: "'", keyCode: 39, width: 50),
            KeyboardKey(label: "return", keyCode: 36, width: 100)
        ],
        // Bottom letter row
        [
            KeyboardKey(label: "shift", keyCode: 56, width: 115),
            KeyboardKey(label: "Z", keyCode: 6, width: 50),
            KeyboardKey(label: "X", keyCode: 7, width: 50),
            KeyboardKey(label: "C", keyCode: 8, width: 50),
            KeyboardKey(label: "V", keyCode: 9, width: 50),
            KeyboardKey(label: "B", keyCode: 11, width: 50),
            KeyboardKey(label: "N", keyCode: 45, width: 50),
            KeyboardKey(label: "M", keyCode: 46, width: 50),
            KeyboardKey(label: ",", keyCode: 43, width: 50),
            KeyboardKey(label: ".", keyCode: 47, width: 50),
            KeyboardKey(label: "/", keyCode: 44, width: 50),
            KeyboardKey(label: "shift", keyCode: 60, width: 115)
        ],
        // Bottom row with first arrow row
        [
            KeyboardKey(label: "fn", keyCode: 63, width: 50),
            KeyboardKey(label: "control", keyCode: 59, width: 65),
            KeyboardKey(label: "option", keyCode: 58, width: 65),
            KeyboardKey(label: "command", keyCode: 55, width: 75),
            KeyboardKey(label: "space", keyCode: 49, width: 280),
            KeyboardKey(label: "command", keyCode: 54, width: 75),
            KeyboardKey(label: "option", keyCode: 61, width: 65),
            KeyboardKey(label: "", keyCode: -6, width: 85, isSpace: true),
            KeyboardKey(label: "↑", keyCode: 126, width: 50, height: 18, isArrow: true)
        ],
        // Arrow keys bottom row (inverted-T)
        [
            KeyboardKey(label: "", keyCode: -7, width: 625, isSpace: true),
            KeyboardKey(label: "←", keyCode: 123, width: 50, height: 18, isArrow: true),
            KeyboardKey(label: "↓", keyCode: 125, width: 50, height: 18, isArrow: true),
            KeyboardKey(label: "→", keyCode: 124, width: 50, height: 18, isArrow: true)
        ]
    ]
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 5) {
                    ForEach(rows[rowIndex], id: \.id) { key in
                        if key.isSpace {
                            Spacer()
                                .frame(width: key.width, height: 1)
                        } else {
                            KeyCapView(
                                key: key,
                                isSelected: viewModel.selectedKeys.contains(key.keyCode),
                                hasMapping: viewModel.hasMapping(for: key.keyCode)
                            )
                            .onTapGesture {
                                if key.keyCode >= 0 {
                                    toggleKeySelection(key.keyCode)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
    }
    
    func toggleKeySelection(_ keyCode: Int) {
        if viewModel.selectedKeys.contains(keyCode) {
            viewModel.selectedKeys.remove(keyCode)
        } else {
            viewModel.selectedKeys.insert(keyCode)
        }
    }
}

struct KeyboardKey: Identifiable {
    let id = UUID()
    let label: String
    let keyCode: Int
    var width: CGFloat = 50
    var height: CGFloat = 38
    var isSpace: Bool = false
    var isArrow: Bool = false
}

struct KeyCapView: View {
    let key: KeyboardKey
    let isSelected: Bool
    let hasMapping: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [backgroundColor, backgroundColor.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: key.width, height: key.height)
            
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(borderColor, lineWidth: isSelected ? 2 : 1)
                .frame(width: key.width, height: key.height)
            
            Text(key.label)
                .font(.system(size: key.isArrow ? 11 : (key.label.count > 4 ? 10 : 13), weight: .medium))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
        }
        .shadow(color: .black.opacity(0.15), radius: 2, y: 2)
    }
    
    var backgroundColor: Color {
        if isSelected {
            return Color.blue.opacity(0.5)
        } else if hasMapping {
            return Color.green.opacity(0.3)
        } else {
            return Color.white.opacity(0.95)
        }
    }
    
    var textColor: Color {
        if isSelected {
            return .white
        } else if hasMapping {
            return Color.green.darker()
        } else {
            return Color.black.opacity(0.85)
        }
    }
    
    var borderColor: Color {
        if isSelected {
            return .blue
        } else if hasMapping {
            return .green
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

extension Color {
    func darker() -> Color {
        return Color(NSColor(self).blended(withFraction: 0.4, of: .black) ?? NSColor(self))
    }
}

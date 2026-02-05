//
//  DesignSystem.swift
//  RecipeReady
//
//  Definitions for the RecipeReady Design System colors and fonts.
//

import SwiftUI

extension Color {
    // Primary Brand Colors
    static let primaryGreen = Color(hex: "1C5643")
    static let softBeige = Color(hex: "FDF5EC")
    static let screenBackground = Color(hex: "FFFFFF")
    
    // Text Colors
    static let textPrimary = Color(hex: "1A1A1A")
    static let textSecondary = Color(hex: "666666")
    
    // UI Elements
    static let divider = Color(hex: "E5E5E5")
    static let primaryOrange = Color(hex: "FF6B35") // Vibrant orange from screenshot
    static let inputBackground = Color(hex: "F0F4F8") // Light blue-gray for inputs
    
    // Helper init for Hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Typography Extensions
extension Font {
    static var largeTitle: Font {
        .system(size: 34, weight: .bold, design: .default)
    }

    static var heading1: Font {
        .system(size: 24, weight: .bold, design: .default)
    }
    
    static var heading2: Font {
        .system(size: 20, weight: .bold, design: .default)
    }
    
    static var heading3: Font {
        .system(size: 18, weight: .semibold, design: .default)
    }
    
    static var bodyBold: Font {
        .system(size: 16, weight: .semibold, design: .default)
    }
    
    static var bodyRegular: Font {
        .system(size: 16, weight: .regular, design: .default)
    }
    
    static var captionMeta: Font {
        .system(size: 14, weight: .regular, design: .default)
    }
}

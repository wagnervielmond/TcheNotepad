//
//  Win11Theme.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 29/09/26.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case light = "Claro"
    case dark = "Escuro"
    case system = "Usar configuração do sistema"
    
    var id: String { rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

struct Win11Colors {
    // Windows 11 Fluent Palette
    static let accent = Color(red: 0/255, green: 120/255, blue: 212/255)
    
    // Light Mode Colors (Windows 11 Fluent Light)
    struct Light {
        static let windowBackground = Color(red: 243/255, green: 243/255, blue: 243/255)
        static let tabActive = Color.white
        static let tabHover = Color.black.opacity(0.05)
        static let tabInactive = Color.clear
        static let toolbarBackground = Color.white
        static let editorBackground = Color.white
        static let statusBarBackground = Color(red: 243/255, green: 243/255, blue: 243/255)
        static let border = Color.black.opacity(0.07)
        static let textPrimary = Color(red: 26/255, green: 26/255, blue: 26/255)
        static let textSecondary = Color(red: 100/255, green: 100/255, blue: 100/255)
        static let buttonHover = Color.black.opacity(0.06)
        static let divider = Color.black.opacity(0.08)
    }
    
    // Dark Mode Colors (Windows 11 Fluent Dark)
    struct Dark {
        static let windowBackground = Color(red: 31/255, green: 31/255, blue: 31/255)
        static let tabActive = Color(red: 40/255, green: 40/255, blue: 40/255)
        static let tabHover = Color.white.opacity(0.06)
        static let tabInactive = Color.clear
        static let toolbarBackground = Color(red: 40/255, green: 40/255, blue: 40/255)
        static let editorBackground = Color(red: 32/255, green: 32/255, blue: 32/255)
        static let statusBarBackground = Color(red: 31/255, green: 31/255, blue: 31/255)
        static let border = Color.white.opacity(0.07)
        static let textPrimary = Color(red: 245/255, green: 245/255, blue: 245/255)
        static let textSecondary = Color(red: 160/255, green: 160/255, blue: 160/255)
        static let buttonHover = Color.white.opacity(0.08)
        static let divider = Color.white.opacity(0.08)
    }
    
    static func windowBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.windowBackground : Light.windowBackground
    }
    
    static func tabActive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.tabActive : Light.tabActive
    }
    
    static func tabHover(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.tabHover : Light.tabHover
    }
    
    static func toolbarBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.toolbarBackground : Light.toolbarBackground
    }
    
    static func editorBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.editorBackground : Light.editorBackground
    }
    
    static func statusBarBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.statusBarBackground : Light.statusBarBackground
    }
    
    static func border(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.border : Light.border
    }
    
    static func textPrimary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.textPrimary : Light.textPrimary
    }
    
    static func textSecondary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.textSecondary : Light.textSecondary
    }
    
    static func buttonHover(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.buttonHover : Light.buttonHover
    }
    
    static func divider(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.divider : Light.divider
    }
}

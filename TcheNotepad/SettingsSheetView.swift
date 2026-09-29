//
//  SettingsSheetView.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 29/09/26.
//

import SwiftUI

struct SettingsSheetView: View {
    @ObservedObject var viewModel: EditorViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let fontList = ["Menlo", "SF Pro", "Courier New", "Monaco", "Helvetica Neue", "Arial"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Configurações")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Win11Colors.textPrimary(for: colorScheme))
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(Win11IconButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Seção de Aparência
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Aparência")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Win11Colors.textPrimary(for: colorScheme))
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Tema do aplicativo")
                                    .font(.system(size: 13))
                                Spacer()
                                Picker("", selection: $viewModel.appTheme) {
                                    ForEach(AppTheme.allCases) { theme in
                                        Text(theme.rawValue).tag(theme)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 220)
                            }
                            .padding(12)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.02))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Win11Colors.border(for: colorScheme), lineWidth: 1)
                        )
                    }
                    
                    // Seção de Fonte e Editor
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Fonte")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Win11Colors.textPrimary(for: colorScheme))
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Família da fonte")
                                    .font(.system(size: 13))
                                Spacer()
                                Picker("", selection: $viewModel.fontFamily) {
                                    ForEach(fontList, id: \.self) { font in
                                        Text(font).tag(font)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 180)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Tamanho da fonte")
                                    .font(.system(size: 13))
                                Spacer()
                                Text("\(Int(viewModel.fontSize)) pt")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                                    .frame(width: 45, alignment: .trailing)
                                
                                Stepper("", value: $viewModel.fontSize, in: 9...36, step: 1)
                                    .labelsHidden()
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Quebra automática de linha")
                                    .font(.system(size: 13))
                                Spacer()
                                Toggle("", isOn: $viewModel.isWordWrap)
                                    .labelsHidden()
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.02))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Win11Colors.border(for: colorScheme), lineWidth: 1)
                        )
                    }
                    
                    // Sobre o Tchê Notepad
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sobre o aplicativo")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Win11Colors.textPrimary(for: colorScheme))
                        
                        VStack(alignment: .leading, spacing: 6) {
                            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1.0"
                            Text("Versão \(version) (Estilo Windows 11)")
                                .font(.system(size: 11))
                                .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                            Text("Editor de texto com abas para macOS.")
                                .font(.system(size: 11))
                                .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.02))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Win11Colors.border(for: colorScheme), lineWidth: 1)
                        )
                    }
                }
                .padding(20)
            }
        }
        .frame(width: 480, height: 440)
        .background(Win11Colors.windowBackground(for: colorScheme))
    }
}

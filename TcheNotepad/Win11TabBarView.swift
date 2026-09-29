//
//  Win11TabBarView.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 29/09/26.
//

import SwiftUI

struct Win11TabBarView: View {
    @ObservedObject var viewModel: EditorViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            // Espaçamento para os botões do macOS (traffic lights)
            Spacer()
                .frame(width: 76)
            
            // Lista de Abas em Scroll horizontal caso haja muitas abas
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(viewModel.tabs) { tab in
                        Win11TabItemView(
                            tab: tab,
                            isActive: tab.id == viewModel.activeTabId,
                            onSelect: {
                                viewModel.selectTab(id: tab.id)
                            },
                            onClose: {
                                viewModel.closeTab(id: tab.id, window: NSApplication.shared.keyWindow)
                            }
                        )
                    }
                    
                    // Botão de Nova Guia (+)
                    Button(action: {
                        viewModel.newTab()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(Win11IconButtonStyle())
                    .help("Nova Guia (⌘T)")
                    .padding(.leading, 4)
                }
                .padding(.leading, 4)
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .frame(height: 38)
        .background(Win11Colors.windowBackground(for: colorScheme))
    }
}

struct Win11TabItemView: View {
    @ObservedObject var tab: DocumentTab
    let isActive: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    @State private var isCloseHovered = false
    
    var body: some View {
        HStack(spacing: 6) {
            // Ícone do Bloco de Notas / Documento
            Image(systemName: "doc.text.fill")
                .font(.system(size: 11))
                .foregroundColor(isActive ? Win11Colors.accent : Win11Colors.textSecondary(for: colorScheme))
            
            // Título da aba
            Text(tab.title)
                .font(.system(size: 12, weight: isActive ? .medium : .regular))
                .foregroundColor(isActive ? Win11Colors.textPrimary(for: colorScheme) : Win11Colors.textSecondary(for: colorScheme))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 160, alignment: .leading)
            
            // Indicador de alteração (ponto)
            if tab.isModified {
                Circle()
                    .fill(Win11Colors.textSecondary(for: colorScheme))
                    .frame(width: 5, height: 5)
            }
            
            // Botão Fechar (x) - visível na aba ativa ou ao passar o mouse
            if isActive || isHovered {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                        .frame(width: 16, height: 16)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(isCloseHovered ? (colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)) : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .onHover { hovering in
                    isCloseHovered = hovering
                }
                .help("Fechar guia (⌘W)")
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 32)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(
                    isActive
                    ? Win11Colors.tabActive(for: colorScheme)
                    : (isHovered ? Win11Colors.tabHover(for: colorScheme) : Color.clear)
                )
                .shadow(color: isActive ? Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05) : Color.clear, radius: 2, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(
                    isActive ? Win11Colors.border(for: colorScheme) : Color.clear,
                    lineWidth: 1
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct Win11IconButtonStyle: ButtonStyle {
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .onHover { isHovered = $0 }
    }
}

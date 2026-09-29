//
//  Win11ToolbarView.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 29/09/26.
//

import SwiftUI

struct Win11ToolbarView: View {
    @ObservedObject var viewModel: EditorViewModel
    var onFormatAction: ((FormattingType) -> Void)? = nil
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 6) {
            // MARK: - Menus Inline Windows 11 (Arquivo, Editar, Exibir)
            HStack(spacing: 2) {
                // Menu Arquivo
                Menu {
                    Button("Nova Guia") { viewModel.newTab() }
                        .keyboardShortcut("t", modifiers: .command)
                    Button("Nova Janela") {
                        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                            appDelegate.novoMenuItem(NSMenuItem())
                        }
                    }
                    .keyboardShortcut("n", modifiers: .command)
                    Button("Abrir…") { viewModel.openFile(window: NSApplication.shared.keyWindow) }
                        .keyboardShortcut("o", modifiers: .command)
                    Divider()
                    Button("Salvar") { viewModel.saveCurrentTab(window: NSApplication.shared.keyWindow) }
                        .keyboardShortcut("s", modifiers: .command)
                    Button("Salvar Como…") { viewModel.saveCurrentTabAs(window: NSApplication.shared.keyWindow) }
                        .keyboardShortcut("s", modifiers: [.command, .shift])
                    Divider()
                    Button("Fechar Guia") {
                        if let tab = viewModel.activeTab {
                            viewModel.closeTab(id: tab.id, window: NSApplication.shared.keyWindow)
                        }
                    }
                    .keyboardShortcut("w", modifiers: .command)
                    Divider()
                    Button("Configurações") { viewModel.showSettings = true }
                        .keyboardShortcut(",", modifiers: .command)
                } label: {
                    Win11MenuTextLabel(title: "Arquivo")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                
                // Menu Editar
                Menu {
                    Button("Desfazer") {
                        viewModel.activeTab?.undoManager.undo()
                    }
                    .keyboardShortcut("z", modifiers: .command)
                    Button("Refazer") {
                        viewModel.activeTab?.undoManager.redo()
                    }
                    .keyboardShortcut("z", modifiers: [.command, .shift])
                    Divider()
                    Button("Recortar") {
                        NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil)
                    }
                    .keyboardShortcut("x", modifiers: .command)
                    Button("Copiar") {
                        NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
                    }
                    .keyboardShortcut("c", modifiers: .command)
                    Button("Colar") {
                        NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
                    }
                    .keyboardShortcut("v", modifiers: .command)
                    Divider()
                    Button("Selecionar Tudo") {
                        NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
                    }
                    .keyboardShortcut("a", modifiers: .command)
                    Divider()
                    Button("Localizar…") {
                        viewModel.showFindBar.toggle()
                    }
                    .keyboardShortcut("f", modifiers: .command)
                    Button("Inserir Data e Hora") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm dd/MM/yyyy"
                        let dateString = formatter.string(from: Date())
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(dateString, forType: .string)
                        NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
                    }
                } label: {
                    Win11MenuTextLabel(title: "Editar")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                
                // Menu Exibir
                Menu {
                    Button("Mais Zoom") { viewModel.zoomIn() }
                        .keyboardShortcut("+", modifiers: .command)
                    Button("Menos Zoom") { viewModel.zoomOut() }
                        .keyboardShortcut("-", modifiers: .command)
                    Button("Restaurar Zoom Padrão") { viewModel.resetZoom() }
                        .keyboardShortcut("0", modifiers: .command)
                    Divider()
                    Toggle("Quebra Automática de Linha", isOn: $viewModel.isWordWrap)
                    Toggle("Barra de Status", isOn: $viewModel.showStatusBar)
                } label: {
                    Win11MenuTextLabel(title: "Exibir")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
            }
            .padding(.leading, 8)
            
            // Separador discreto
            Rectangle()
                .fill(Win11Colors.divider(for: colorScheme))
                .frame(width: 1, height: 16)
                .padding(.horizontal, 4)
            
            // MARK: - Barra de Ferramentas de Formatação
            HStack(spacing: 2) {
                // Dropdown H1
                Menu {
                    Button("Título 1 (#)") { onFormatAction?(.heading1) }
                    Button("Título 2 (##)") { onFormatAction?(.heading2) }
                    Button("Título 3 (###)") { onFormatAction?(.heading3) }
                } label: {
                    Win11DropdownButtonLabel(title: "H1")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .help("Estilo de Título")
                
                // Dropdown Listas
                Menu {
                    Button("Lista com Marcadores (-)") { onFormatAction?(.bulletList) }
                    Button("Lista Numerada (1.)") { onFormatAction?(.numberList) }
                    Button("Lista de Tarefas (- [ ])") { onFormatAction?(.checkList) }
                } label: {
                    Win11DropdownButtonLabel(systemImage: "list.bullet")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .help("Listas")
                
                // Negrito (B)
                Win11ToolButton(label: "B", isBold: true) {
                    onFormatAction?(.bold)
                }
                .help("Negrito (**texto**)")
                
                // Itálico (I)
                Win11ToolButton(label: "I", isItalic: true) {
                    onFormatAction?(.italic)
                }
                .help("Itálico (*texto*)")
                
                // Tachado (S)
                Win11ToolButton(label: "S", isStrikethrough: true) {
                    onFormatAction?(.strikethrough)
                }
                .help("Tachado (~~texto~~)")
                
                // Link (🔗)
                Win11ToolButton(systemImage: "link") {
                    onFormatAction?(.link)
                }
                .help("Inserir Link [texto](url)")
                
                // Tabela (▦)
                Menu {
                    Button("Inserir Tabela 2x2") { onFormatAction?(.table) }
                } label: {
                    Win11DropdownButtonLabel(systemImage: "tablecells")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .help("Tabela")
                
                // Maiúsculas / Minúsculas (Ab)
                Menu {
                    Button("MAIÚSCULAS") { onFormatAction?(.uppercase) }
                    Button("minúsculas") { onFormatAction?(.lowercase) }
                    Button("Primeira Letra Maiúscula") { onFormatAction?(.capitalize) }
                } label: {
                    Win11DropdownButtonLabel(title: "Ab")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .help("Alterar Maiúsculas/Minúsculas")
            }
            
            Spacer()
            
            // MARK: - Ações no Canto Direito (Busca e Configurações)
            HStack(spacing: 2) {
                // Botão de Busca
                Button(action: {
                    viewModel.showFindBar.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                        .foregroundColor(viewModel.showFindBar ? Win11Colors.accent : Win11Colors.textSecondary(for: colorScheme))
                        .frame(width: 28, height: 26)
                        .contentShape(Rectangle())
                }
                .buttonStyle(Win11IconButtonStyle())
                .help("Localizar (⌘F)")
                
                // Botão de Configurações (⚙️)
                Button(action: {
                    viewModel.showSettings.toggle()
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 11))
                        .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                        .frame(width: 28, height: 26)
                        .contentShape(Rectangle())
                }
                .buttonStyle(Win11IconButtonStyle())
                .help("Configurações")
            }
            .padding(.trailing, 8)
        }
        .frame(height: 34)
        .background(Win11Colors.toolbarBackground(for: colorScheme))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Win11Colors.border(for: colorScheme)),
            alignment: .bottom
        )
    }
}

// MARK: - Labels Planos Estilo Windows 11

struct Win11MenuTextLabel: View {
    let title: String
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    var body: some View {
        Text(title)
            .font(.system(size: 12))
            .foregroundColor(Win11Colors.textPrimary(for: colorScheme))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovered ? Win11Colors.buttonHover(for: colorScheme) : Color.clear)
            )
            .contentShape(Rectangle())
            .onHover { isHovered = $0 }
    }
}

struct Win11DropdownButtonLabel: View {
    var title: String? = nil
    var systemImage: String? = nil
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 3) {
            if let img = systemImage {
                Image(systemName: img)
                    .font(.system(size: 11))
            }
            if let t = title {
                Text(t)
                    .font(.system(size: 11, weight: .semibold))
            }
            Image(systemName: "chevron.down")
                .font(.system(size: 7, weight: .semibold))
                .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
        }
        .foregroundColor(Win11Colors.textPrimary(for: colorScheme))
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isHovered ? Win11Colors.buttonHover(for: colorScheme) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }
}

struct Win11ToolButton: View {
    var label: String? = nil
    var systemImage: String? = nil
    var isBold: Bool = false
    var isItalic: Bool = false
    var isStrikethrough: Bool = false
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Group {
                if let img = systemImage {
                    Image(systemName: img)
                        .font(.system(size: 11))
                } else if let l = label {
                    Text(l)
                        .font(.system(size: 12, weight: isBold ? .bold : .regular))
                        .italic(isItalic)
                        .strikethrough(isStrikethrough)
                }
            }
            .foregroundColor(Win11Colors.textPrimary(for: colorScheme))
            .frame(width: 26, height: 26)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovered ? Win11Colors.buttonHover(for: colorScheme) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered = $0 }
    }
}

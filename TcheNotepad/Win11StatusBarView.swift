//
//  Win11StatusBarView.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 29/09/26.
//

import SwiftUI

struct Win11StatusBarView: View {
    @ObservedObject var viewModel: EditorViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let activeTab = viewModel.activeTab
        
        HStack(spacing: 0) {
            // MARK: - Lado Esquerdo: Linha, Coluna e Caracteres
            HStack(spacing: 16) {
                // Ln X, Col Y
                Text("Ln \(activeTab?.cursorLine ?? 1), Col \(activeTab?.cursorColumn ?? 1)")
                    .font(.system(size: 11))
                    .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                
                // Contagem de Caracteres
                if let tab = activeTab {
                    if tab.selectionLength > 0 {
                        Text("\(tab.selectionLength) selecionados de \(tab.totalCharacters) caracteres")
                            .font(.system(size: 11))
                            .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                    } else {
                        Text("\(tab.totalCharacters) caracteres")
                            .font(.system(size: 11))
                            .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                    }
                }
            }
            .padding(.leading, 14)
            
            Spacer()
            
            // MARK: - Centro: Tipo de Formatação
            Text("Texto sem formatação")
                .font(.system(size: 11))
                .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
            
            Spacer()
            
            // MARK: - Lado Direito: Zoom, Final de Linha e Codificação
            HStack(spacing: 12) {
                // Zoom com Menu rápido
                Menu {
                    Button("50%") { viewModel.zoomPercentage = 50 }
                    Button("75%") { viewModel.zoomPercentage = 75 }
                    Button("100% (Padrão)") { viewModel.zoomPercentage = 100 }
                    Button("125%") { viewModel.zoomPercentage = 125 }
                    Button("150%") { viewModel.zoomPercentage = 150 }
                    Button("200%") { viewModel.zoomPercentage = 200 }
                } label: {
                    Win11StatusItemLabel(text: "\(viewModel.zoomPercentage)%")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .help("Nível de zoom")
                
                // Fim de Linha (CRLF vs LF)
                Menu {
                    ForEach(LineEnding.allCases) { ending in
                        Button(ending.rawValue) {
                            viewModel.convertLineEnding(to: ending)
                        }
                    }
                } label: {
                    Win11StatusItemLabel(text: activeTab?.lineEnding.rawValue ?? LineEnding.crlf.rawValue)
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .help("Final de linha")
                
                // Codificação (UTF-8, etc.)
                Menu {
                    ForEach(TextEncodingOption.allCases) { enc in
                        Button(enc.rawValue) {
                            activeTab?.encoding = enc
                        }
                    }
                } label: {
                    Win11StatusItemLabel(text: activeTab?.encoding.rawValue ?? "UTF-8")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .help("Codificação do arquivo")
            }
            .padding(.trailing, 14)
        }
        .frame(height: 26)
        .background(Win11Colors.statusBarBackground(for: colorScheme))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Win11Colors.border(for: colorScheme)),
            alignment: .top
        )
    }
}

struct Win11StatusItemLabel: View {
    let text: String
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    var body: some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(isHovered ? Win11Colors.buttonHover(for: colorScheme) : Color.clear)
            )
            .contentShape(Rectangle())
            .onHover { isHovered = $0 }
    }
}

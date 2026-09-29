//
//  Win11FindBarView.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 29/09/26.
//

import SwiftUI

struct Win11FindBarView: View {
    @ObservedObject var viewModel: EditorViewModel
    var onFindNext: ((String, Bool) -> Void)? = nil
    var onFindPrevious: ((String, Bool) -> Void)? = nil
    var onReplace: ((String, String) -> Void)? = nil
    var onReplaceAll: ((String, String) -> Void)? = nil
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isReplaceExpanded = false
    
    var body: some View {
        VStack(spacing: 4) {
            // Linha de Busca
            HStack(spacing: 6) {
                // Toggle de Substituição
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isReplaceExpanded.toggle()
                    }
                }) {
                    Image(systemName: isReplaceExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Campo de Texto de Busca
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                        .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                    
                    TextField("Localizar...", text: $viewModel.findText, onCommit: {
                        onFindNext?(viewModel.findText, viewModel.isCaseSensitive)
                    })
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 12))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Win11Colors.border(for: colorScheme), lineWidth: 1)
                )
                .frame(width: 200)
                
                // Anterior (<)
                Button(action: {
                    onFindPrevious?(viewModel.findText, viewModel.isCaseSensitive)
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(Win11IconButtonStyle())
                .help("Localizar Anterior (⇧F3)")
                
                // Próximo (>)
                Button(action: {
                    onFindNext?(viewModel.findText, viewModel.isCaseSensitive)
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(Win11IconButtonStyle())
                .help("Localizar Próximo (F3)")
                
                // Diferenciar Maiúsculas/Minúsculas
                Button(action: {
                    viewModel.isCaseSensitive.toggle()
                }) {
                    Text("Aa")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(viewModel.isCaseSensitive ? Win11Colors.accent : Win11Colors.textSecondary(for: colorScheme))
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(viewModel.isCaseSensitive ? Win11Colors.accent.opacity(0.15) : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .help("Diferenciar Maiúsculas de Minúsculas")
                
                Spacer()
                
                // Botão Fechar (x)
                Button(action: {
                    viewModel.showFindBar = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(Win11IconButtonStyle())
                .help("Fechar barra de busca (Esc)")
            }
            
            // Linha de Substituição (expansível)
            if isReplaceExpanded {
                HStack(spacing: 6) {
                    Spacer().frame(width: 20)
                    
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 11))
                            .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                        
                        TextField("Substituir por...", text: $viewModel.replaceText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 12))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Win11Colors.border(for: colorScheme), lineWidth: 1)
                    )
                    .frame(width: 200)
                    
                    Button("Substituir") {
                        onReplace?(viewModel.findText, viewModel.replaceText)
                    }
                    .buttonStyle(Win11SmallButtonStyle())
                    
                    Button("Substituir Tudo") {
                        onReplaceAll?(viewModel.findText, viewModel.replaceText)
                    }
                    .buttonStyle(Win11SmallButtonStyle())
                    
                    Spacer()
                }
                .padding(.top, 2)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Win11Colors.toolbarBackground(for: colorScheme))
                .shadow(color: Color.black.opacity(0.15), radius: 6, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Win11Colors.border(for: colorScheme), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
}

struct Win11SmallButtonStyle: ButtonStyle {
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.primary.opacity(0.04))
            )
            .onHover { isHovered = $0 }
    }
}

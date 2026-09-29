//
//  Win11NotepadContainerView.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 29/09/26.
//

import SwiftUI

struct Win11NotepadContainerView: View {
    @ObservedObject var viewModel: EditorViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Barra de Abas Superior
            Win11TabBarView(viewModel: viewModel)
            
            // MARK: - Barra de Ferramentas / Menus Inline
            Win11ToolbarView(viewModel: viewModel) { formatType in
                handleFormattingAction(formatType)
            }
            
            // MARK: - Barra de Busca (Flutuante quando ativada)
            if viewModel.showFindBar {
                Win11FindBarView(
                    viewModel: viewModel,
                    onFindNext: { query, caseSensitive in
                        performFind(query: query, isForward: true, caseSensitive: caseSensitive)
                    },
                    onFindPrevious: { query, caseSensitive in
                        performFind(query: query, isForward: false, caseSensitive: caseSensitive)
                    },
                    onReplace: { target, replacement in
                        performReplace(target: target, replacement: replacement)
                    },
                    onReplaceAll: { target, replacement in
                        performReplaceAll(target: target, replacement: replacement)
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // MARK: - Editor Central (Aba Ativa)
            ZStack {
                if let activeTab = viewModel.activeTab {
                    Win11EditorView(tab: activeTab, viewModel: viewModel)
                        .id(activeTab.id) // Força troca limpa entre abas
                } else {
                    Text("Nenhum documento aberto")
                        .foregroundColor(Win11Colors.textSecondary(for: colorScheme))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Win11Colors.editorBackground(for: colorScheme))
            
            // MARK: - Barra de Status Inferior
            if viewModel.showStatusBar {
                Win11StatusBarView(viewModel: viewModel)
            }
        }
        .background(Win11Colors.windowBackground(for: colorScheme))
        .preferredColorScheme(viewModel.appTheme.colorScheme)
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsSheetView(viewModel: viewModel)
        }
    }
    
    // MARK: - Manipulação de Formatação
    
    private func handleFormattingAction(_ type: FormattingType) {
        guard viewModel.activeTab != nil else { return }
        
        // Obter textView ativo
        guard let window = NSApplication.shared.keyWindow,
              let textView = window.firstResponder as? NSTextView else {
            return
        }
        
        let range = textView.selectedRange()
        let text = textView.string as NSString
        let selectedText = range.length > 0 ? text.substring(with: range) : ""
        
        var replacement = ""
        var newSelectedRange = range
        
        switch type {
        case .heading1:
            replacement = "# \(selectedText)"
        case .heading2:
            replacement = "## \(selectedText)"
        case .heading3:
            replacement = "### \(selectedText)"
        case .bulletList:
            replacement = "- \(selectedText)"
        case .numberList:
            replacement = "1. \(selectedText)"
        case .checkList:
            replacement = "- [ ] \(selectedText)"
        case .bold:
            if selectedText.isEmpty {
                replacement = "****"
                newSelectedRange = NSRange(location: range.location + 2, length: 0)
            } else {
                replacement = "**\(selectedText)**"
                newSelectedRange = NSRange(location: range.location, length: replacement.count)
            }
        case .italic:
            if selectedText.isEmpty {
                replacement = "**"
                newSelectedRange = NSRange(location: range.location + 1, length: 0)
            } else {
                replacement = "*\(selectedText)*"
                newSelectedRange = NSRange(location: range.location, length: replacement.count)
            }
        case .strikethrough:
            if selectedText.isEmpty {
                replacement = "~~~~"
                newSelectedRange = NSRange(location: range.location + 2, length: 0)
            } else {
                replacement = "~~\(selectedText)~~"
                newSelectedRange = NSRange(location: range.location, length: replacement.count)
            }
        case .code:
            replacement = "`\(selectedText)`"
        case .link:
            let linkTitle = selectedText.isEmpty ? "link" : selectedText
            replacement = "[\(linkTitle)](https://)"
        case .table:
            replacement = "\n| Cabeçalho 1 | Cabeçalho 2 |\n|---|---|\n| Item 1 | Item 2 |\n"
        case .uppercase:
            replacement = selectedText.uppercased()
        case .lowercase:
            replacement = selectedText.lowercased()
        case .capitalize:
            replacement = selectedText.capitalized
        }
        
        if textView.shouldChangeText(in: range, replacementString: replacement) {
            textView.replaceCharacters(in: range, with: replacement)
            textView.didChangeText()
            textView.setSelectedRange(newSelectedRange)
        }
    }
    
    // MARK: - Busca e Substituição
    
    private func performFind(query: String, isForward: Bool, caseSensitive: Bool) {
        guard !query.isEmpty,
              let window = NSApplication.shared.keyWindow,
              let textView = window.firstResponder as? NSTextView ?? findFirstTextView(in: window.contentView) else {
            return
        }
        
        let fullText = textView.string
        let currentRange = textView.selectedRange()
        
        var searchRange: NSRange
        var options: NSString.CompareOptions = caseSensitive ? [] : [.caseInsensitive]
        
        if isForward {
            let start = currentRange.location + currentRange.length
            if start < (fullText as NSString).length {
                searchRange = NSRange(location: start, length: (fullText as NSString).length - start)
            } else {
                searchRange = NSRange(location: 0, length: (fullText as NSString).length)
            }
        } else {
            options.insert(.backwards)
            let end = currentRange.location
            if end > 0 {
                searchRange = NSRange(location: 0, length: end)
            } else {
                searchRange = NSRange(location: 0, length: (fullText as NSString).length)
            }
        }
        
        var foundRange = (fullText as NSString).range(of: query, options: options, range: searchRange)
        
        // Se não encontrar, faz o wrap around
        if foundRange.location == NSNotFound {
            let wrapRange = NSRange(location: 0, length: (fullText as NSString).length)
            foundRange = (fullText as NSString).range(of: query, options: options, range: wrapRange)
        }
        
        if foundRange.location != NSNotFound {
            textView.scrollRangeToVisible(foundRange)
            textView.showFindIndicator(for: foundRange)
            textView.setSelectedRange(foundRange)
        } else {
            NSSound.beep()
        }
    }
    
    private func performReplace(target: String, replacement: String) {
        guard !target.isEmpty,
              let window = NSApplication.shared.keyWindow,
              let textView = window.firstResponder as? NSTextView ?? findFirstTextView(in: window.contentView) else {
            return
        }
        
        let selectedRange = textView.selectedRange()
        let currentSelectedText = (textView.string as NSString).substring(with: selectedRange)
        
        if currentSelectedText.compare(target, options: viewModel.isCaseSensitive ? [] : .caseInsensitive) == .orderedSame {
            if textView.shouldChangeText(in: selectedRange, replacementString: replacement) {
                textView.replaceCharacters(in: selectedRange, with: replacement)
                textView.didChangeText()
            }
            performFind(query: target, isForward: true, caseSensitive: viewModel.isCaseSensitive)
        } else {
            performFind(query: target, isForward: true, caseSensitive: viewModel.isCaseSensitive)
        }
    }
    
    private func performReplaceAll(target: String, replacement: String) {
        guard !target.isEmpty, let tab = viewModel.activeTab else { return }
        let currentText = tab.text
        let newText: String
        if viewModel.isCaseSensitive {
            newText = currentText.replacingOccurrences(of: target, with: replacement)
        } else {
            newText = currentText.replacingOccurrences(of: target, with: replacement, options: .caseInsensitive)
        }
        tab.text = newText
    }
    
    private func findFirstTextView(in view: NSView?) -> NSTextView? {
        guard let view = view else { return nil }
        if let tv = view as? NSTextView { return tv }
        for sub in view.subviews {
            if let tv = findFirstTextView(in: sub) { return tv }
        }
        return nil
    }
}

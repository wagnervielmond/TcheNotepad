//
//  Win11EditorView.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 29/09/26.
//

import SwiftUI
import Cocoa

struct Win11EditorView: NSViewRepresentable {
    @ObservedObject var tab: DocumentTab
    @ObservedObject var viewModel: EditorViewModel
    
    // Referência do Coordinator para invocar ações
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = !viewModel.isWordWrap
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.allowsUndo = true
        textView.importsGraphics = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        
        // Insets semelhantes ao Windows 11 Notepad (margem suave e limpa)
        textView.textContainerInset = NSSize(width: 14, height: 12)
        
        // Configurações de Quebra de Linha
        configureWordWrap(textView: textView, isWordWrap: viewModel.isWordWrap, scrollView: scrollView)
        
        // Fonte inicial
        let scaledSize = max(8, viewModel.fontSize * CGFloat(viewModel.zoomPercentage) / 100.0)
        let font = NSFont(name: viewModel.fontFamily, size: scaledSize) ?? NSFont.monospacedSystemFont(ofSize: scaledSize, weight: .regular)
        textView.font = font
        
        // Cores
        updateAppearance(textView: textView, colorScheme: viewModel.appTheme.colorScheme)
        
        // Texto inicial
        textView.string = tab.text
        
        scrollView.documentView = textView
        context.coordinator.textView = textView
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        // Atualiza a referência de Coordinator
        context.coordinator.parent = self
        
        // Atualiza o texto apenas se houver diferença externa para evitar reset de cursor
        if textView.string != tab.text {
            let selectedRanges = textView.selectedRanges
            textView.string = tab.text
            textView.selectedRanges = selectedRanges
        }
        
        // Atualiza fonte com base no zoom e tamanho configurado
        let scaledSize = max(8, viewModel.fontSize * CGFloat(viewModel.zoomPercentage) / 100.0)
        let currentFont = textView.font
        let newFont = NSFont(name: viewModel.fontFamily, size: scaledSize) ?? NSFont.monospacedSystemFont(ofSize: scaledSize, weight: .regular)
        if currentFont?.pointSize != scaledSize || currentFont?.fontName != newFont.fontName {
            textView.font = newFont
        }
        
        // Atualiza quebra de linha
        configureWordWrap(textView: textView, isWordWrap: viewModel.isWordWrap, scrollView: scrollView)
        
        // Atualiza Cores de Fundo / Texto
        updateAppearance(textView: textView, colorScheme: viewModel.appTheme.colorScheme)
    }
    
    private func configureWordWrap(textView: NSTextView, isWordWrap: Bool, scrollView: NSScrollView) {
        if isWordWrap {
            scrollView.hasHorizontalScroller = false
            textView.isHorizontallyResizable = false
            textView.autoresizingMask = [.width]
            textView.textContainer?.widthTracksTextView = true
            textView.textContainer?.containerSize = NSSize(width: scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        } else {
            scrollView.hasHorizontalScroller = true
            textView.isHorizontallyResizable = true
            textView.autoresizingMask = [.none]
            textView.textContainer?.widthTracksTextView = false
            textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        }
    }
    
    private func updateAppearance(textView: NSTextView, colorScheme: ColorScheme?) {
        let isDark = colorScheme == .dark || (colorScheme == nil && NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua)
        
        if isDark {
            textView.backgroundColor = NSColor(calibratedRed: 32/255, green: 32/255, blue: 32/255, alpha: 1.0)
            textView.textColor = NSColor(calibratedRed: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
            textView.insertionPointColor = NSColor.white
        } else {
            textView.backgroundColor = NSColor.white
            textView.textColor = NSColor(calibratedRed: 32/255, green: 32/255, blue: 32/255, alpha: 1.0)
            textView.insertionPointColor = NSColor.black
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: Win11EditorView
        weak var textView: NSTextView?
        
        init(_ parent: Win11EditorView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let newText = textView.string
            DispatchQueue.main.async {
                self.parent.tab.text = newText
                self.updateCursorMetrics(textView: textView)
            }
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            DispatchQueue.main.async {
                self.updateCursorMetrics(textView: textView)
            }
        }
        
        private func updateCursorMetrics(textView: NSTextView) {
            let selectedRange = textView.selectedRange()
            let text = textView.string as NSString
            let location = min(selectedRange.location, text.length)
            
            // Calcula Linha e Coluna
            var lineNumber = 1
            var colNumber = 1
            
            var lineStart = 0
            while lineStart < location {
                var lineRange = NSRange()
                text.getLineStart(nil, end: &lineRange.location, contentsEnd: nil, for: NSRange(location: lineStart, length: 0))
                if lineRange.location > location {
                    break
                }
                lineNumber += 1
                lineStart = lineRange.location
            }
            colNumber = location - lineStart + 1
            
            parent.tab.cursorLine = lineNumber
            parent.tab.cursorColumn = colNumber
            parent.tab.selectionLength = selectedRange.length
            parent.tab.totalCharacters = text.length
        }
    }
}

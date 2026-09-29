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
        
        // Habilita Zoom / Magnificação nativa do macOS
        scrollView.allowsMagnification = true
        scrollView.minMagnification = 0.3
        scrollView.maxMagnification = 3.0
        scrollView.magnification = max(0.3, min(3.0, CGFloat(viewModel.zoomPercentage) / 100.0))
        
        // Notificação para quando o usuário fizer pinch-to-zoom com o trackpad
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.scrollViewDidMagnify(_:)),
            name: NSScrollView.didEndLiveMagnifyNotification,
            object: scrollView
        )
        
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isRichText = true
        textView.allowsUndo = true
        textView.importsGraphics = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        
        // Insets semelhantes ao Windows 11 Notepad
        textView.textContainerInset = NSSize(width: 14, height: 12)
        
        // Configurações de Quebra de Linha
        configureWordWrap(textView: textView, isWordWrap: viewModel.isWordWrap, scrollView: scrollView)
        
        // Cores
        updateAppearance(textView: textView, colorScheme: viewModel.appTheme.colorScheme)
        
        // Fonte inicial padrão
        let defaultFont = NSFont(name: viewModel.fontFamily, size: viewModel.fontSize) ?? NSFont.systemFont(ofSize: viewModel.fontSize)
        
        if let attr = tab.attributedText {
            textView.textStorage?.setAttributedString(attr)
        } else {
            textView.string = tab.text
            textView.font = defaultFont
        }
        
        scrollView.documentView = textView
        context.coordinator.textView = textView
        context.coordinator.scrollView = scrollView
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        // Atualiza a referência de Coordinator
        context.coordinator.parent = self
        
        // MARK: - 1. Zoom Nativo do ScrollView
        let targetMagnification = max(0.3, min(3.0, CGFloat(viewModel.zoomPercentage) / 100.0))
        if abs(scrollView.magnification - targetMagnification) > 0.01 {
            scrollView.setMagnification(targetMagnification, centeredAt: NSPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY))
        }
        
        // MARK: - 2. Atualização de Texto (apenas se não estiver digitando nem compondo acento)
        if !context.coordinator.isUserTyping && !textView.hasMarkedText() {
            if textView.string != tab.text {
                let selectedRanges = textView.selectedRanges
                if let attr = tab.attributedText {
                    textView.textStorage?.setAttributedString(attr)
                } else {
                    textView.string = tab.text
                }
                textView.selectedRanges = selectedRanges
            }
        }
        
        // MARK: - 3. Quebra de Linha
        configureWordWrap(textView: textView, isWordWrap: viewModel.isWordWrap, scrollView: scrollView)
        
        // MARK: - 4. Cores de Tema
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
        weak var scrollView: NSScrollView?
        var isUserTyping = false
        
        init(_ parent: Win11EditorView) {
            self.parent = parent
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        @objc func scrollViewDidMagnify(_ notification: Notification) {
            guard let sv = notification.object as? NSScrollView else { return }
            let percent = Int(round(sv.magnification * 100))
            if parent.viewModel.zoomPercentage != percent {
                DispatchQueue.main.async {
                    self.parent.viewModel.zoomPercentage = percent
                }
            }
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            isUserTyping = true
            let newText = textView.string
            let newAttr = NSAttributedString(attributedString: textView.attributedString())
            
            DispatchQueue.main.async {
                self.parent.tab.text = newText
                self.parent.tab.attributedText = newAttr
                self.updateCursorMetrics(textView: textView)
                self.isUserTyping = false
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

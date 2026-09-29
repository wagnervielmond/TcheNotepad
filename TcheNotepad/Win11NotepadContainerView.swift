//
//  Win11NotepadContainerView.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 29/09/26.
//

import SwiftUI
import Cocoa

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
    
    // MARK: - Formatação Visual Nativa (Negrito, Itálico, Sobretaxado, etc.)
    
    private func handleFormattingAction(_ type: FormattingType) {
        guard let window = NSApplication.shared.keyWindow,
              let textView = findMainDocumentTextView(in: window.contentView),
              let textStorage = textView.textStorage else {
            return
        }
        
        let range = textView.selectedRange()
        let fontManager = NSFontManager.shared
        
        switch type {
        case .bold:
            if range.length > 0 {
                textStorage.beginEditing()
                textStorage.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
                    let currentFont = (value as? NSFont) ?? textView.font ?? NSFont.systemFont(ofSize: 13)
                    let isBold = fontManager.traits(of: currentFont).contains(.boldFontMask)
                    let newFont = isBold ? fontManager.convert(currentFont, toNotHaveTrait: .boldFontMask)
                                         : fontManager.convert(currentFont, toHaveTrait: .boldFontMask)
                    textStorage.addAttribute(.font, value: newFont, range: subRange)
                }
                textStorage.endEditing()
                textView.didChangeText()
            } else {
                var typingAttrs = textView.typingAttributes
                let currentFont = (typingAttrs[.font] as? NSFont) ?? textView.font ?? NSFont.systemFont(ofSize: 13)
                let isBold = fontManager.traits(of: currentFont).contains(.boldFontMask)
                let newFont = isBold ? fontManager.convert(currentFont, toNotHaveTrait: .boldFontMask)
                                     : fontManager.convert(currentFont, toHaveTrait: .boldFontMask)
                typingAttrs[.font] = newFont
                textView.typingAttributes = typingAttrs
            }
            
        case .italic:
            if range.length > 0 {
                textStorage.beginEditing()
                textStorage.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
                    let currentFont = (value as? NSFont) ?? textView.font ?? NSFont.systemFont(ofSize: 13)
                    let isItalic = fontManager.traits(of: currentFont).contains(.italicFontMask)
                    let newFont = isItalic ? fontManager.convert(currentFont, toNotHaveTrait: .italicFontMask)
                                           : fontManager.convert(currentFont, toHaveTrait: .italicFontMask)
                    textStorage.addAttribute(.font, value: newFont, range: subRange)
                }
                textStorage.endEditing()
                textView.didChangeText()
            } else {
                var typingAttrs = textView.typingAttributes
                let currentFont = (typingAttrs[.font] as? NSFont) ?? textView.font ?? NSFont.systemFont(ofSize: 13)
                let isItalic = fontManager.traits(of: currentFont).contains(.italicFontMask)
                let newFont = isItalic ? fontManager.convert(currentFont, toNotHaveTrait: .italicFontMask)
                                       : fontManager.convert(currentFont, toHaveTrait: .italicFontMask)
                typingAttrs[.font] = newFont
                textView.typingAttributes = typingAttrs
            }
            
        case .strikethrough:
            if range.length > 0 {
                textStorage.beginEditing()
                let currentStyle = textStorage.attribute(.strikethroughStyle, at: range.location, effectiveRange: nil) as? Int ?? 0
                let newStyle = (currentStyle == NSUnderlineStyle.single.rawValue) ? 0 : NSUnderlineStyle.single.rawValue
                textStorage.addAttribute(.strikethroughStyle, value: newStyle, range: range)
                textStorage.endEditing()
                textView.didChangeText()
            } else {
                var typingAttrs = textView.typingAttributes
                let currentStyle = typingAttrs[.strikethroughStyle] as? Int ?? 0
                typingAttrs[.strikethroughStyle] = (currentStyle == NSUnderlineStyle.single.rawValue) ? 0 : NSUnderlineStyle.single.rawValue
                textView.typingAttributes = typingAttrs
            }
            
        case .heading1, .heading2, .heading3, .normalText:
            let targetRange: NSRange
            let fullText = textView.string as NSString
            if range.length > 0 {
                targetRange = range
            } else {
                targetRange = fullText.lineRange(for: range)
            }
            
            let headingFont: NSFont
            switch type {
            case .heading1:
                headingFont = NSFont.boldSystemFont(ofSize: 26)
            case .heading2:
                headingFont = NSFont.boldSystemFont(ofSize: 20)
            case .heading3:
                headingFont = NSFont.boldSystemFont(ofSize: 16)
            case .normalText:
                headingFont = NSFont(name: viewModel.fontFamily, size: viewModel.fontSize) ?? NSFont.systemFont(ofSize: viewModel.fontSize)
            default:
                headingFont = NSFont.systemFont(ofSize: viewModel.fontSize)
            }
            
            if targetRange.length > 0 {
                textStorage.beginEditing()
                textStorage.addAttribute(.font, value: headingFont, range: targetRange)
                if type == .normalText {
                    textStorage.removeAttribute(.underlineStyle, range: targetRange)
                    textStorage.removeAttribute(.strikethroughStyle, range: targetRange)
                }
                textStorage.endEditing()
                textView.didChangeText()
            } else {
                var typingAttrs = textView.typingAttributes
                typingAttrs[.font] = headingFont
                textView.typingAttributes = typingAttrs
            }
            
        case .bulletList:
            insertLinePrefix("- ", in: textView)
            
        case .numberList:
            insertLinePrefix("1. ", in: textView)
            
        case .checkList:
            insertLinePrefix("- [ ] ", in: textView)
            
        case .table:
            let tableTemplate = "\n| Cabeçalho 1 | Cabeçalho 2 |\n|---|---|\n| Item 1 | Item 2 |\n"
            if textView.shouldChangeText(in: range, replacementString: tableTemplate) {
                textView.replaceCharacters(in: range, with: tableTemplate)
                textView.didChangeText()
            }
            
        case .link:
            if range.length > 0 {
                textStorage.addAttribute(.link, value: "https://", range: range)
                textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                textView.didChangeText()
            } else {
                let linkTemplate = "[link](https://)"
                if textView.shouldChangeText(in: range, replacementString: linkTemplate) {
                    textView.replaceCharacters(in: range, with: linkTemplate)
                    textView.didChangeText()
                }
            }
            
        case .uppercase, .lowercase, .capitalize:
            if range.length > 0 {
                let text = (textView.string as NSString).substring(with: range)
                let replaced: String
                switch type {
                case .uppercase: replaced = text.uppercased()
                case .lowercase: replaced = text.lowercased()
                case .capitalize: replaced = text.capitalized
                default: replaced = text
                }
                if textView.shouldChangeText(in: range, replacementString: replaced) {
                    textView.replaceCharacters(in: range, with: replaced)
                    textView.didChangeText()
                    textView.setSelectedRange(NSRange(location: range.location, length: replaced.count))
                }
            }
        default:
            break
        }
        
        // Sincroniza estado no DocumentTab
        if let tab = viewModel.activeTab {
            tab.text = textView.string
            tab.attributedText = NSAttributedString(attributedString: textView.attributedString())
        }
    }
    
    private func insertLinePrefix(_ prefix: String, in textView: NSTextView) {
        let range = textView.selectedRange()
        let text = textView.string as NSString
        let lineRange = text.lineRange(for: range)
        let lineText = text.substring(with: lineRange)
        
        let lines = lineText.components(separatedBy: "\n")
        let newLines = lines.map { line -> String in
            if line.isEmpty { return line }
            if line.hasPrefix(prefix) {
                return String(line.dropFirst(prefix.count))
            } else {
                return prefix + line
            }
        }
        let replacement = newLines.joined(separator: "\n")
        
        if textView.shouldChangeText(in: lineRange, replacementString: replacement) {
            textView.replaceCharacters(in: lineRange, with: replacement)
            textView.didChangeText()
        }
    }
    
    // MARK: - Busca e Substituição
    
    private func performFind(query: String, isForward: Bool, caseSensitive: Bool) {
        guard !query.isEmpty,
              let window = NSApplication.shared.keyWindow,
              let textView = findMainDocumentTextView(in: window.contentView) else {
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
              let textView = findMainDocumentTextView(in: window.contentView) else {
            return
        }
        
        let selectedRange = textView.selectedRange()
        let fullText = textView.string as NSString
        let selectedText = selectedRange.length > 0 ? fullText.substring(with: selectedRange) : ""
        
        let isMatch = selectedText.compare(target, options: viewModel.isCaseSensitive ? [] : .caseInsensitive) == .orderedSame
        
        if isMatch {
            if textView.shouldChangeText(in: selectedRange, replacementString: replacement) {
                textView.replaceCharacters(in: selectedRange, with: replacement)
                textView.didChangeText()
                textView.setSelectedRange(NSRange(location: selectedRange.location, length: (replacement as NSString).length))
            }
            if let tab = viewModel.activeTab {
                tab.text = textView.string
                tab.attributedText = NSAttributedString(attributedString: textView.attributedString())
            }
            // Localiza a próxima ocorrência
            performFind(query: target, isForward: true, caseSensitive: viewModel.isCaseSensitive)
        } else {
            // Localiza primeiro caso a seleção atual não seja o termo
            performFind(query: target, isForward: true, caseSensitive: viewModel.isCaseSensitive)
        }
    }
    
    private func performReplaceAll(target: String, replacement: String) {
        guard !target.isEmpty,
              let window = NSApplication.shared.keyWindow,
              let textView = findMainDocumentTextView(in: window.contentView),
              let tab = viewModel.activeTab else {
            return
        }
        
        let options: NSString.CompareOptions = viewModel.isCaseSensitive ? [] : [.caseInsensitive]
        var count = 0
        var searchLocation = 0
        
        textView.undoManager?.beginUndoGrouping()
        
        while searchLocation < (textView.string as NSString).length {
            let currentFullText = textView.string as NSString
            let remainingRange = NSRange(location: searchLocation, length: currentFullText.length - searchLocation)
            let foundRange = currentFullText.range(of: target, options: options, range: remainingRange)
            
            if foundRange.location == NSNotFound {
                break
            }
            
            if textView.shouldChangeText(in: foundRange, replacementString: replacement) {
                textView.replaceCharacters(in: foundRange, with: replacement)
                count += 1
                searchLocation = foundRange.location + (replacement as NSString).length
            } else {
                break
            }
        }
        
        if count > 0 {
            textView.didChangeText()
            tab.text = textView.string
            tab.attributedText = NSAttributedString(attributedString: textView.attributedString())
        } else {
            NSSound.beep()
        }
        
        textView.undoManager?.endUndoGrouping()
    }
    
    private func findMainDocumentTextView(in view: NSView?) -> NSTextView? {
        guard let view = view else { return nil }
        if let tv = view as? NSTextView, !tv.isFieldEditor {
            return tv
        }
        for sub in view.subviews {
            if let tv = findMainDocumentTextView(in: sub) {
                return tv
            }
        }
        return nil
    }
}

//
//  EditorViewModel.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 29/09/26.
//

import SwiftUI
import Cocoa
import UniformTypeIdentifiers

enum FormattingType {
    case heading1
    case heading2
    case heading3
    case normalText
    case bulletList
    case numberList
    case checkList
    case bold
    case italic
    case strikethrough
    case code
    case link
    case table
    case uppercase
    case lowercase
    case capitalize
}

class EditorViewModel: ObservableObject {
    @Published var tabs: [DocumentTab] = []
    @Published var activeTabId: UUID
    
    // Zoom
    @Published var zoomPercentage: Int = 100
    
    // Configurações visuais
    @Published var appTheme: AppTheme = .system
    @Published var fontFamily: String = "Menlo"
    @Published var fontSize: CGFloat = 13.0
    @Published var isWordWrap: Bool = true
    @Published var showStatusBar: Bool = true
    
    // Busca e Substituição
    @Published var showFindBar: Bool = false
    @Published var findText: String = ""
    @Published var replaceText: String = ""
    @Published var isCaseSensitive: Bool = false
    
    // Configurações modal
    @Published var showSettings: Bool = false
    
    // Fechar ao salvar flag
    var pendingCloseTabId: UUID? = nil
    
    init() {
        let initialTab = DocumentTab(title: "Sem título 1")
        self.tabs = [initialTab]
        self.activeTabId = initialTab.id
    }
    
    var activeTab: DocumentTab? {
        tabs.first(where: { $0.id == activeTabId })
    }
    
    var activeTabIndex: Int? {
        tabs.firstIndex(where: { $0.id == activeTabId })
    }
    
    // MARK: - Gerenciamento de Abas
    
    func newTab(title: String? = nil, content: String = "") {
        let count = tabs.count + 1
        let tabTitle = title ?? "Sem título \(count)"
        let tab = DocumentTab(title: tabTitle, initialText: content)
        tabs.append(tab)
        activeTabId = tab.id
    }
    
    func selectTab(id: UUID) {
        activeTabId = id
    }
    
    func closeTab(id: UUID, window: NSWindow? = nil) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        let tabToClose = tabs[index]
        
        if tabToClose.isModified {
            let alert = NSAlert()
            alert.messageText = "Salvar alterações em \"\(tabToClose.title)\"?"
            alert.informativeText = "Se você não salvar, suas alterações serão perdidas."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Salvar")
            alert.addButton(withTitle: "Não Salvar")
            alert.addButton(withTitle: "Cancelar")
            
            let handleResponse: (NSApplication.ModalResponse) -> Void = { response in
                switch response {
                case .alertFirstButtonReturn: // Salvar
                    self.pendingCloseTabId = id
                    self.saveTab(tabToClose, window: window) { success in
                        if success {
                            self.forceCloseTab(at: index)
                        }
                    }
                case .alertSecondButtonReturn: // Não Salvar
                    self.forceCloseTab(at: index)
                default: // Cancelar
                    return
                }
            }
            
            if let window = window {
                alert.beginSheetModal(for: window, completionHandler: handleResponse)
            } else {
                let response = alert.runModal()
                handleResponse(response)
            }
        } else {
            forceCloseTab(at: index)
        }
    }
    
    private func forceCloseTab(at index: Int) {
        let closingId = tabs[index].id
        tabs.remove(at: index)
        
        if tabs.isEmpty {
            // Se fechou a última aba, cria uma nova limpa
            let newTab = DocumentTab(title: "Sem título 1")
            tabs = [newTab]
            activeTabId = newTab.id
        } else if activeTabId == closingId {
            // Seleciona a aba vizinha mais próxima
            let newIndex = max(0, min(index, tabs.count - 1))
            activeTabId = tabs[newIndex].id
        }
    }
    
    // MARK: - Ações de Arquivo
    
    func openFile(window: NSWindow? = nil) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.plainText, .text, .sourceCode]
        
        let processURLs: ([URL]) -> Void = { urls in
            for url in urls {
                self.openFileURL(url)
            }
        }
        
        if let window = window {
            panel.beginSheetModal(for: window) { response in
                if response == .OK {
                    processURLs(panel.urls)
                }
            }
        } else {
            if panel.runModal() == .OK {
                processURLs(panel.urls)
            }
        }
    }
    
    func openFileURL(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            var encodingUsed: String.Encoding = .utf8
            let content: String
            
            if let str = String(data: data, encoding: .utf8) {
                content = str
                encodingUsed = .utf8
            } else if let str = String(data: data, encoding: .windowsCP1252) {
                content = str
                encodingUsed = .windowsCP1252
            } else if let str = String(data: data, encoding: .isoLatin1) {
                content = str
                encodingUsed = .isoLatin1
            } else {
                content = String(decoding: data, as: UTF8.self)
            }
            
            // Se a aba ativa for única, em branco e não modificada, substitui
            if tabs.count == 1, let current = tabs.first, current.text.isEmpty && !current.isModified && current.fileURL == nil {
                current.title = url.lastPathComponent
                current.fileURL = url
                current.text = content
                current.savedContent = content
                current.isModified = false
                if encodingUsed == .windowsCP1252 { current.encoding = .windowsCP1252 }
                else if encodingUsed == .isoLatin1 { current.encoding = .isoLatin1 }
                else { current.encoding = .utf8 }
                current.updateMetrics()
                activeTabId = current.id
            } else {
                // Abre em nova aba
                let tab = DocumentTab(title: url.lastPathComponent, fileURL: url, initialText: content)
                if encodingUsed == .windowsCP1252 { tab.encoding = .windowsCP1252 }
                else if encodingUsed == .isoLatin1 { tab.encoding = .isoLatin1 }
                else { tab.encoding = .utf8 }
                tabs.append(tab)
                activeTabId = tab.id
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Erro ao abrir arquivo"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .critical
            alert.runModal()
        }
    }
    
    func saveCurrentTab(window: NSWindow? = nil, completion: ((Bool) -> Void)? = nil) {
        guard let tab = activeTab else {
            completion?(false)
            return
        }
        saveTab(tab, window: window, completion: completion)
    }
    
    func saveTab(_ tab: DocumentTab, window: NSWindow? = nil, completion: ((Bool) -> Void)? = nil) {
        if let fileURL = tab.fileURL {
            do {
                let data = tab.text.data(using: tab.encoding.stringEncoding) ?? tab.text.data(using: .utf8)!
                try data.write(to: fileURL, options: .atomic)
                tab.markAsSaved(at: fileURL)
                completion?(true)
            } catch {
                let alert = NSAlert()
                alert.messageText = "Erro ao salvar arquivo"
                alert.informativeText = error.localizedDescription
                alert.alertStyle = .critical
                alert.runModal()
                completion?(false)
            }
        } else {
            saveTabAs(tab, window: window, completion: completion)
        }
    }
    
    func saveCurrentTabAs(window: NSWindow? = nil, completion: ((Bool) -> Void)? = nil) {
        guard let tab = activeTab else {
            completion?(false)
            return
        }
        saveTabAs(tab, window: window, completion: completion)
    }
    
    func saveTabAs(_ tab: DocumentTab, window: NSWindow? = nil, completion: ((Bool) -> Void)? = nil) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = tab.fileURL?.lastPathComponent ?? "\(tab.title).txt"
        
        let saveAction: (URL?) -> Void = { targetURL in
            guard let url = targetURL else {
                completion?(false)
                return
            }
            do {
                let data = tab.text.data(using: tab.encoding.stringEncoding) ?? tab.text.data(using: .utf8)!
                try data.write(to: url, options: .atomic)
                tab.markAsSaved(at: url)
                completion?(true)
            } catch {
                let alert = NSAlert()
                alert.messageText = "Erro ao salvar arquivo"
                alert.informativeText = error.localizedDescription
                alert.alertStyle = .critical
                alert.runModal()
                completion?(false)
            }
        }
        
        if let window = window {
            panel.beginSheetModal(for: window) { response in
                if response == .OK {
                    saveAction(panel.url)
                } else {
                    completion?(false)
                }
            }
        } else {
            if panel.runModal() == .OK {
                saveAction(panel.url)
            } else {
                completion?(false)
            }
        }
    }
    
    // MARK: - Zoom Controls
    
    func zoomIn() {
        if zoomPercentage < 300 {
            zoomPercentage = min(300, zoomPercentage + 10)
        }
    }
    
    func zoomOut() {
        if zoomPercentage > 30 {
            zoomPercentage = max(30, zoomPercentage - 10)
        }
    }
    
    func resetZoom() {
        zoomPercentage = 100
    }
    
    // MARK: - Line Ending Conversion
    
    func convertLineEnding(to newEnding: LineEnding) {
        guard let tab = activeTab else { return }
        let currentText = tab.text
        let normalized = currentText.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        
        let converted: String
        switch newEnding {
        case .crlf:
            converted = normalized.replacingOccurrences(of: "\n", with: "\r\n")
        case .lf:
            converted = normalized
        case .cr:
            converted = normalized.replacingOccurrences(of: "\n", with: "\r")
        }
        
        tab.text = converted
        tab.lineEnding = newEnding
    }
}

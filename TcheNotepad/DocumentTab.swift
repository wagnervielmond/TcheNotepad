//
//  DocumentTab.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 29/09/26.
//

import Foundation
import Cocoa

enum LineEnding: String, CaseIterable, Identifiable {
    case crlf = "Windows (CRLF)"
    case lf = "Unix (LF)"
    case cr = "Mac Clássico (CR)"
    
    var id: String { rawValue }
    
    var characters: String {
        switch self {
        case .crlf: return "\r\n"
        case .lf: return "\n"
        case .cr: return "\r"
        }
    }
}

enum TextEncodingOption: String, CaseIterable, Identifiable {
    case utf8 = "UTF-8"
    case utf16 = "UTF-16"
    case isoLatin1 = "ISO Latin 1"
    case windowsCP1252 = "Windows (CP1252)"
    
    var id: String { rawValue }
    
    var stringEncoding: String.Encoding {
        switch self {
        case .utf8: return .utf8
        case .utf16: return .utf16
        case .isoLatin1: return .isoLatin1
        case .windowsCP1252: return .windowsCP1252
        }
    }
}

class DocumentTab: Identifiable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var fileURL: URL?
    @Published var text: String {
        didSet {
            isModified = (text != savedContent)
            updateMetrics()
        }
    }
    @Published var savedContent: String
    @Published var isModified: Bool = false
    
    // Status metrics
    @Published var cursorLine: Int = 1
    @Published var cursorColumn: Int = 1
    @Published var selectionLength: Int = 0
    @Published var totalCharacters: Int = 0
    
    // Configurações do arquivo
    @Published var lineEnding: LineEnding = .crlf
    @Published var encoding: TextEncodingOption = .utf8
    
    // Gerenciador de Desfazer individual por aba
    let undoManager: UndoManager
    
    init(title: String = "Sem título", fileURL: URL? = nil, initialText: String = "") {
        self.id = UUID()
        self.title = title
        self.fileURL = fileURL
        self.text = initialText
        self.savedContent = initialText
        self.isModified = false
        self.undoManager = UndoManager()
        self.undoManager.groupsByEvent = true
        
        // Detectar terminação de linha inicial
        if initialText.contains("\r\n") {
            self.lineEnding = .crlf
        } else if initialText.contains("\n") {
            self.lineEnding = .lf
        }
        
        self.updateMetrics()
    }
    
    func updateMetrics() {
        self.totalCharacters = text.count
    }
    
    func markAsSaved(at url: URL? = nil) {
        if let url = url {
            self.fileURL = url
            self.title = url.lastPathComponent
        }
        self.savedContent = text
        self.isModified = false
    }
}

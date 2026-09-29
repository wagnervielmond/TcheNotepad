//
//  ViewController.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 10/11/24.
//

import Cocoa
import SwiftUI

class ViewController: NSViewController {

    @IBOutlet weak var textView: NSTextView?
    
    let viewModel = EditorViewModel()
    private var hostingView: NSHostingView<Win11NotepadContainerView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIContainer()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        setupWindowAppearance()
    }
    
    private func setupWindowAppearance() {
        guard let window = view.window else { return }
        window.title = "Tchê Notepad"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.isMovableByWindowBackground = false
    }
    
    private func setupSwiftUIContainer() {
        textView?.enclosingScrollView?.removeFromSuperview()
        
        let container = Win11NotepadContainerView(viewModel: viewModel)
        let host = NSHostingView(rootView: container)
        host.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host)
        
        NSLayoutConstraint.activate([
            host.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.topAnchor.constraint(equalTo: view.topAnchor),
            host.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.hostingView = host
    }
    
    // MARK: - Abertura Direta (Finder / Argumentos)
    
    func abrirDiretamente(_ filename: String) {
        let url = URL(fileURLWithPath: filename)
        viewModel.openFileURL(url)
    }
    
    // MARK: - Controle de Fechamento de Janela
    
    func canCloseWindow() -> Bool {
        let modifiedTabs = viewModel.tabs.filter { $0.isModified }
        guard !modifiedTabs.isEmpty else { return true }
        
        let alert = NSAlert()
        alert.messageText = "Salvar alterações?"
        let names = modifiedTabs.map { $0.title }.joined(separator: ", ")
        alert.informativeText = "Existem guias com alterações não salvas (\(names)). Deseja salvá-las antes de fechar?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Salvar Tudo")
        alert.addButton(withTitle: "Não Salvar")
        alert.addButton(withTitle: "Cancelar")
        
        guard let window = view.window else { return true }
        
        alert.beginSheetModal(for: window) { response in
            switch response {
            case .alertFirstButtonReturn: // Salvar Tudo
                self.salvarTodasEFechar(modifiedTabs: modifiedTabs)
            case .alertSecondButtonReturn: // Não Salvar
                window.close()
                NSApp.terminate(self)
            default: // Cancelar
                return
            }
        }
        return false
    }
    
    private func salvarTodasEFechar(modifiedTabs: [DocumentTab]) {
        var tabsToSave = modifiedTabs
        func saveNext() {
            guard let next = tabsToSave.popLast() else {
                self.view.window?.close()
                NSApp.terminate(self)
                return
            }
            self.viewModel.saveTab(next, window: self.view.window) { success in
                if success {
                    saveNext()
                }
            }
        }
        saveNext()
    }
    
    func windowClose(_ sender: Any) {
        if canCloseWindow() {
            view.window?.close()
            NSApp.terminate(self)
        }
    }
    
    // MARK: - IBActions integradas aos Menus e AppDelegate
    
    @IBAction func fechar(_ sender: Any) {
        if let activeTab = viewModel.activeTab {
            viewModel.closeTab(id: activeTab.id, window: view.window)
        }
    }
    
    @IBAction func salvar(_ sender: Any) {
        viewModel.saveCurrentTab(window: view.window)
    }
    
    @IBAction func salvarComo(_ sender: Any) {
        viewModel.saveCurrentTabAs(window: view.window)
    }
    
    @IBAction func abrir(_ sender: Any) {
        viewModel.openFile(window: view.window)
    }
    
    @IBAction func novo(_ sender: Any) {
        viewModel.newTab()
    }
    
    func abrirNovaJanela(conteudo: String = "") {
        let novaJanela = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "NovaJanela") as! NSWindowController
        novaJanela.showWindow(nil)
        if let vc = novaJanela.contentViewController as? ViewController, !conteudo.isEmpty {
            vc.viewModel.tabs.first?.text = conteudo
        }
    }

    @IBAction func selecionarTudo(_ sender: Any) {
        NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
    }
    
    @IBAction func imprimir(_ sender: Any) {
        if let window = view.window,
           let currentTextView = window.firstResponder as? NSTextView ?? findFirstTextView(in: view) {
            let printOperation = NSPrintOperation(view: currentTextView)
            printOperation.run()
        }
    }

    @IBAction func recortar(_ sender: Any) {
        NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil)
    }

    @IBAction func copiar(_ sender: Any) {
        NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
    }

    @IBAction func colar(_ sender: Any) {
        NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
    }
    
    @IBAction func encontrar(_ sender: Any) {
        viewModel.showFindBar.toggle()
    }
    
    @IBAction func desfazer(_ sender: Any) {
        viewModel.activeTab?.undoManager.undo()
    }

    @IBAction func refazer(_ sender: Any) {
        viewModel.activeTab?.undoManager.redo()
    }
    
    private func findFirstTextView(in view: NSView?) -> NSTextView? {
        guard let view = view else { return nil }
        if let tv = view as? NSTextView, !tv.isFieldEditor { return tv }
        for sub in view.subviews {
            if let tv = findFirstTextView(in: sub) { return tv }
        }
        return nil
    }
}

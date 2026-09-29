//
//  AppDelegate.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 10/11/24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        if let filename = filenames.first {
            let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
            viewController?.abrirDiretamente(filename)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let mainWindow = NSApplication.shared.windows.first {
            mainWindow.delegate = self
        }
        
        NSApp.setActivationPolicy(.regular)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {
       return true
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        print("windowShouldClose")
        if let viewController = sender.contentViewController as? ViewController {
            viewController.windowClose(self)
        }
        return false
    }
    
    @IBAction func abrirMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.abrir(sender)
    }

    @IBAction func salvarMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.salvar(sender)
    }
    
    @IBAction func salvarComoMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.salvarComo(sender)
    }
    
    @IBAction func selecionarTudoMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.selecionarTudo(sender)
    }
    
    @IBAction func fecharMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.fechar(sender)
    }
    
    @IBAction func novoMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.novo(sender)
    }    
    
    @IBAction func imprimirMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.imprimir(sender)
    }
   
    @IBAction func recortarMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.recortar(sender)
    }
   
    @IBAction func copiarMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.copiar(sender)
    }
   
    @IBAction func colarMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.colar(sender)
    }
    
    @IBAction func encontrarMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.encontrar(sender)
    }
    
    @IBAction func undoMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.desfazer(sender)
    }
    
    @IBAction func redoMenuItem(_ sender: NSMenuItem) {
        // Encontre o ViewController e chame a ação correspondente
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
        viewController?.refazer(sender)
    }

}


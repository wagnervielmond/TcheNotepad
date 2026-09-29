//
//  ViewController.swift
//  TcheNotepad
//
//  Created by Wagner Campos on 10/11/24.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var textView: NSTextView!
    
    var textoOriginal: String = ""
    var fileURL: URL?
    var fecharAposSalvar = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textoOriginal = textView.string
        textView.allowsUndo = true
        textView.undoManager?.groupsByEvent = true
    }
    
    // abrir
    func abrirDiretamente(_ filename: String) {
        fileURL = URL(fileURLWithPath: filename) // Adicione essa linha
        
        if textoEditado() {
            abrirNovaJanela(conteudo: lerArquivo(caminho: filename))
        } else {
            textView.string = lerArquivo(caminho: filename)
            textoOriginal = textView.string
        }
    }
    
    func windowClose(_ sender: Any) {
        print("windowShouldClose foi chamado")
        if textoEditado() {
            let alerta = NSAlert()
            alerta.messageText = "Salvar alterações?"
            alerta.informativeText = "Você fez alterações no texto. Deseja salvá-las antes de fechar?"
            alerta.alertStyle = .warning
            alerta.addButton(withTitle: "Sim")
            alerta.addButton(withTitle: "Não")
            alerta.addButton(withTitle: "Cancelar")
            
            alerta.beginSheetModal(for: self.view.window!) { resposta in
                switch resposta {
                case .alertFirstButtonReturn: // Sim
                    self.fecharAposSalvar = true
                    self.salvarEFechar()
                case .alertSecondButtonReturn: // Não
                    NSApp.terminate(self)
                default: // Cancelar
                    return
                }
            }
        } else {
            NSApp.terminate(self)
        }
    }
    
    @IBAction func fechar(_ sender: Any) {
        if textoEditado() {
            let alerta = NSAlert()
            alerta.messageText = "Salvar alterações?"
            alerta.informativeText = "Você fez alterações no texto. Deseja salvá-las antes de fechar?"
            alerta.alertStyle = .warning
            alerta.addButton(withTitle: "Sim")
            alerta.addButton(withTitle: "Não")
            alerta.addButton(withTitle: "Cancelar")
            
            alerta.beginSheetModal(for: self.view.window!) { resposta in
                switch resposta {
                case .alertFirstButtonReturn: // Sim
                    self.fecharAposSalvar = true
                    self.salvarEFechar()
                case .alertSecondButtonReturn: // Não
                    NSApp.terminate(self)
                default: // Cancelar
                    return
                }
            }
        } else {
            NSApp.terminate(self)
        }
    }
    
    func salvarEFechar() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.begin { (result) in
            if result == .OK {
                if let fileURL = panel.url, !self.textView.string.isEmpty {
                    do {
                        try self.textView.string.write(to: fileURL, atomically: true, encoding: .utf8)
                        NSApp.terminate(self)
                    } catch {
                        print("Erro ao salvar arquivo: \(error.localizedDescription)")
                    }
                } else {
                    print("Texto vazio")
                }
            }
        }
    }

    @IBAction func salvar(_ sender: Any) {
        if let fileURL = fileURL {
            do {
                let texto = textView.string
                try texto.write(to: fileURL, atomically: true, encoding: .utf8)
                print("Fechar após salvar:", fecharAposSalvar) // Verificar valor
                if fecharAposSalvar {
                    NSApp.terminate(self)
                    fecharAposSalvar = false // Resetar a variável
                }
            } catch {
                print("Erro ao salvar arquivo: \(error.localizedDescription)")
            }
        } else {
            salvarComo(sender)
        }
    }
    
    // abrir
    @IBAction func abrir(_ sender: Any) {
        let abrirPanel = NSOpenPanel()
        abrirPanel.canChooseDirectories = false
        abrirPanel.canChooseFiles = true
        abrirPanel.allowsMultipleSelection = false
        
        if abrirPanel.runModal() == .OK {
            guard let filePath = abrirPanel.url?.path else { return }
            fileURL = URL(fileURLWithPath: filePath) // Adicione essa linha
            
            if textoEditado() {
                abrirNovaJanela(conteudo: lerArquivo(caminho: filePath))
            } else {
                textView.string = lerArquivo(caminho: filePath)
                textoOriginal = textView.string
            }
        }
    }
    
    func lerArquivo(caminho: String) -> String {
        do {
            return try String(contentsOfFile: caminho, encoding: .utf8)
        } catch {
            print("Erro ao ler arquivo: \(error)")
            return ""
        }
    }

    func abrirNovaJanela(conteudo: String) {
        let novaJanela = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "NovaJanela") as! NSWindowController
        novaJanela.showWindow(nil)
        
        // Configura o conteúdo da nova janela
        let viewController = novaJanela.contentViewController as! ViewController
        viewController.textView.string = conteudo
    }

    func textoEditado() -> Bool {
        return textView.string != textoOriginal
    }
    
    // Salvar Como
    @IBAction func salvarComo(_ sender: Any) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.begin { (result) in
            if result == .OK {
                if let fileURL = panel.url, !self.textView.string.isEmpty {
                    do {
                        try self.textView.string.write(to: fileURL, atomically: true, encoding: .utf8)
                        self.fileURL = fileURL // Atualize o fileURL
                    } catch {
                        print("Erro ao salvar arquivo: \(error.localizedDescription)")
                    }
                } else {
                    print("Texto vazio")
                }
            }
        }
    }
    
    @IBAction func novo(_ sender: Any) {
        let novaJanela = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "NovaJanela") as! NSWindowController
        print("Nova janela instanciada: \(novaJanela)")
        novaJanela.showWindow(nil)
    }

    @IBAction func selecionarTudo(_ sender: Any) {
        textView.selectAll(sender)
    }
    
    // Imprimir
    @IBAction func imprimir(_ sender: Any) {
        let printOperation = NSPrintOperation(view: self.textView)
        printOperation.run()
    }

    // Recortar
    @IBAction func recortar(_ sender: Any) {
        textView.cut(nil)
    }

    // Copiar
    @IBAction func copiar(_ sender: Any) {
        textView.copy(nil)
    }

    // Colar
    @IBAction func colar(_ sender: Any) {
        textView.paste(nil)
    }
    
    // Encontrar
    @IBAction func encontrar(_ sender: Any) {
        let encontrarPanel = NSAlert.init()
        encontrarPanel.messageText = "Pesquisar"
        encontrarPanel.informativeText = "Digite o texto desejado"
        
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        encontrarPanel.accessoryView = textField
        
        encontrarPanel.addButton(withTitle: "OK") // Adiciona botão OK
        encontrarPanel.addButton(withTitle: "Cancelar") // Adiciona botão Cancelar
        
        encontrarPanel.beginSheetModal(for: self.view.window!) { resposta in
            if resposta == .alertFirstButtonReturn { // Verifica se o botão OK foi pressionado
                print("resposta: \(resposta)")
                let palavra = textField.stringValue
                print("palavra: \(palavra)")
                if !palavra.isEmpty {
                    self.encontrarPalavra(palavra)
                } else {
                    print("Digite uma palavra para buscar")
                }
            }
        }
    }
    
    func encontrarPalavra(_ palavra: String) {
        DispatchQueue.main.async {
            let texto = self.textView.string
            if let range = texto.range(of: palavra, options: .caseInsensitive) {
                let nsRange = NSRange(range, in: texto)
                self.textView.scrollRangeToVisible(nsRange)
                self.textView.selectedRange = nsRange
                
                print("nsRange: \(nsRange)")
            } else {
                let alerta = NSAlert()
                alerta.messageText = "Palavra não encontrada"
                alerta.informativeText = "A palavra '\(palavra)' não foi encontrada no texto"
                alerta.alertStyle = .warning
                alerta.beginSheetModal(for: self.view.window!)
            }
        }
    }
    
    // Desfazer
    @IBAction func desfazer(_ sender: Any) {
        print("Desfazer chamado")
        self.textView.undoManager?.undo()
    }

    // Refazer
    @IBAction func refazer(_ sender: Any) {
        print("Refazer chamado")
        self.textView.undoManager?.redo()
    }
    
}

class LineNumberTextView: NSTextView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Ajusta o inset do texto para evitar sobreposição com a numeração
        self.textContainerInset = NSMakeSize(15, self.textContainerInset.height)
    }

    override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)

        // Configuração da fonte e cor da numeração
        let font = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        let color = NSColor.gray
        let lineHeight: CGFloat = 14.0

        // Calcula o número de linhas com base na altura do texto
        let numberOfLines = Int((self.bounds.height - self.textContainerInset.height) / lineHeight)

        // Desenha a numeração das linhas
        for i in 0..<numberOfLines {
            let lineNumberString = "\(i + 1)"
            let attribString = NSAttributedString(string: lineNumberString, attributes: [.font: font, .foregroundColor: color])
            
            // Calcula a posição y para desenhar a numeração das linhas
            let yPosition = self.textContainerInset.height + CGFloat(i) * lineHeight
            
            // Desenha a numeração das linhas
            attribString.draw(in: NSRect(x: 0, y: Int(yPosition), width: 30, height: Int(lineHeight)))
        }
    }
}

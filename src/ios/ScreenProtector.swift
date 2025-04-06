import Foundation
import UIKit

// Tag para facilitar logs
let pluginTag = "ScreenProtector"

// A anotação @available garante que só funcione no iOS 13 ou superior
@available(iOS 13.0, *)
@objc(ScreenProtector) class ScreenProtector: CDVPlugin {
    private var protectionWindow: UIWindow?
    private var isProtecting = false
    private var eventCallbacks: [String: String] = [:]
    private var isInitialized = false

    override func pluginInitialize() {
        print("[\(pluginTag)] Plugin inicializado")

        // Valida versão do iOS
        guard #available(iOS 13.0, *) else {
            print("[\(pluginTag)] Erro: iOS 13.0 ou superior é necessário")
            return
        }

        // Registra observers
        do {
            try registerObservers()
            isInitialized = true
            print("[\(pluginTag)] Status inicial: isProtecting=\(isProtecting)")
        } catch {
            print("[\(pluginTag)] Erro ao registrar observers: \(error.localizedDescription)")
        }

        // Verifica estado inicial da gravação
        checkInitialRecordingState()
    }

    private func registerObservers() throws {
        // Observer para screenshots
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
        print("[\(pluginTag)] Observer de screenshot registrado")

        // Observer para gravação de tela
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCaptureChanged),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
        print("[\(pluginTag)] Observer de screen recording registrado")
    }

    private func checkInitialRecordingState() {
        DispatchQueue.main.async { [weak self] in
            let isCaptured = UIScreen.main.isCaptured
            print("[\(pluginTag)] Verificação inicial de gravação: isCaptured=\(isCaptured)")

            if isCaptured {
                print("[\(pluginTag)] Gravação de tela detectada durante inicialização")
                self?.enableProtection(reason: "screen_recording")

                // Notifica os ouvintes JavaScript sobre o estado inicial
                if let callbackId = self?.eventCallbacks["protectionStarted"] {
                    let result = CDVPluginResult(
                        status: CDVCommandStatus_OK,
                        messageAs: ["event": "protectionStarted", "reason": "screen_recording"]
                    )
                    result?.setKeepCallbackAs(true)
                    self?.commandDelegate?.send(result, callbackId: callbackId)
                    print("[\(pluginTag)] Evento inicial protectionStarted enviado para JS")
                } else {
                    print("[\(pluginTag)] Nenhum ouvinte JS registrado ainda para protectionStarted")
                }
            }
        }
    }

    private func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let size: CGFloat = 80
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)

        if let context = UIGraphicsGetCurrentContext() {
            // Desenha o círculo laranja
            let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size, height: size))
            UIColor(red: 253/255, green: 100/255, blue: 1/255, alpha: 1.0).setFill()
            circlePath.fill()

            // Adiciona o ícone da câmera
            if let bundlePath = Bundle.main.path(forResource: "camera", ofType: "png"),
               let cameraImage = UIImage(contentsOfFile: bundlePath) {
                let imageSize = size * 0.6 // 60% do tamanho do círculo
                let imageRect = CGRect(
                    x: (size - imageSize) / 2,
                    y: (size - imageSize) / 2,
                    width: imageSize,
                    height: imageSize
                )
                cameraImage.draw(in: imageRect, blendMode: .normal, alpha: 1.0)
            } else {
                print("[\(pluginTag)] Erro: Não foi possível carregar a imagem da câmera")
            }
        }

        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Configura o tamanho do imageView
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size),
            imageView.heightAnchor.constraint(equalToConstant: size)
        ])

        return imageView
    }

    private func createProtectionWindow() -> UIWindow {
        let window: UIWindow
            if let windowScene = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first {
            window = UIWindow(windowScene: windowScene)
                print("[\(pluginTag)] Janela de proteção criada com windowScene")
            } else {
            window = UIWindow(frame: UIScreen.main.bounds)
                print("[\(pluginTag)] Janela de proteção criada com bounds padrão")
            }

        window.windowLevel = .init(rawValue: CGFloat.greatestFiniteMagnitude)
        window.backgroundColor = .systemBackground // Cor de fundo dinâmica

        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBackground // Cor de fundo dinâmica
        window.rootViewController = viewController

        return window
    }

    private func showProtectionWithMessage(reason: String) {
        // Cria a janela se necessário
        if protectionWindow == nil {
            protectionWindow = createProtectionWindow()
        }

        guard let window = protectionWindow,
              let viewController = window.rootViewController else {
            print("[\(pluginTag)] Erro: Componentes não inicializados corretamente")
            return
        }

        // Configura o fundo em cinza escuro
        viewController.view.backgroundColor = .black

        // Remove views anteriores
        viewController.view.subviews.forEach { $0.removeFromSuperview() }

        // Cria a stack view principal
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(stackView)

        // Adiciona o ícone
        let iconView = createIconImageView()
        stackView.addArrangedSubview(iconView)

        // Cria e configura o título
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        // Cria e configura a descrição
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .lightGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0

        // Configura o texto baseado no motivo
        switch reason {
        case "screenshot":
            titleLabel.text = "Captura de tela bloqueada"
            descriptionLabel.text = "Por questões de privacidade, a captura de tela foi bloqueada."
        case "screen_recording":
            titleLabel.text = "Gravação de tela bloqueada"
            descriptionLabel.text = "Por questões de privacidade, a gravação de tela foi bloqueada."
        case "screen_sharing":
            titleLabel.text = "Compartilhamento bloqueado"
            descriptionLabel.text = "Por questões de privacidade, o compartilhamento de tela foi bloqueado."
        default:
            titleLabel.text = "Conteúdo protegido"
            descriptionLabel.text = "Por questões de privacidade, este conteúdo está protegido."
        }

        // Adiciona os labels à stack
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)

        // Configura as constraints
        NSLayoutConstraint.activate([
            // Stack View
            stackView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: viewController.view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: viewController.view.trailingAnchor, constant: -32)
        ])

        // Força a janela a ser visível e ativa
        window.makeKeyAndVisible()
        window.isHidden = false

        print("[\(pluginTag)] Proteção ativada com texto para: \(reason)")
    }

    @objc func enable(_ command: CDVInvokedUrlCommand) {
        print("[\(pluginTag)] Plugin habilitado")
        let result = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate?.send(result, callbackId: command.callbackId)
    }

    private func enableProtection(reason: String) {
        guard !isProtecting else {
            print("[\(pluginTag)] Proteção já está ativa, ignorando chamada")
            return
        }

        print("[\(pluginTag)] Ativando proteção: reason=\(reason)")
        isProtecting = true

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.showProtectionWithMessage(reason: reason)

            // Notifica o evento protectionStarted
            if let callbackId = self.eventCallbacks["protectionStarted"] {
                let result = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: ["event": "protectionStarted", "reason": reason]
                )
                result?.setKeepCallbackAs(true)
                self.commandDelegate?.send(result, callbackId: callbackId)
                print("[\(pluginTag)] Evento protectionStarted enviado para JS")
            }
        }
    }

    private func disableProtection() {
        guard isProtecting else {
            print("[\(pluginTag)] Proteção já está desativada, ignorando chamada")
            return
        }

        print("[\(pluginTag)] Desativando proteção")
        isProtecting = false

        DispatchQueue.main.async { [weak self] in
            self?.protectionWindow?.isHidden = true

            if let callbackId = self?.eventCallbacks["protectionStopped"] {
                let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
                    messageAs: ["event": "protectionStopped"]
                )
                result?.setKeepCallbackAs(true)
                self?.commandDelegate?.send(result, callbackId: callbackId)
                print("[\(pluginTag)] Evento protectionStopped enviado para JS")
            }
        }
    }

    @objc func addEventListener(_ command: CDVInvokedUrlCommand) {
        guard let eventName = command.arguments[0] as? String else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Event name is required")
            self.commandDelegate?.send(result, callbackId: command.callbackId)
            return
        }

        print("[\(pluginTag)] Registrando listener para evento: \(eventName)")
        eventCallbacks[eventName] = command.callbackId

        let result = CDVPluginResult(status: CDVCommandStatus_OK)
        result?.setKeepCallbackAs(true)
        self.commandDelegate?.send(result, callbackId: command.callbackId)
    }

    @objc func userDidTakeScreenshot() {
        print("[\(pluginTag)] Screenshot detectado!")

        // Se já estiver protegendo por gravação/compartilhamento, apenas notifica sobre o screenshot
        if isProtecting && UIScreen.main.isCaptured {
            print("[\(pluginTag)] Mantendo proteção ativa devido à gravação/compartilhamento")

            // Notifica os ouvintes JavaScript sobre o screenshot
            if let callbackId = eventCallbacks["protectionStarted"] {
                let result = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: ["event": "protectionStarted", "reason": "screenshot", "isRecording": true]
                )
                result?.setKeepCallbackAs(true)
                commandDelegate?.send(result, callbackId: callbackId)
                print("[\(pluginTag)] Evento de screenshot durante gravação enviado para JS")
            }
            return
        }

        // Caso contrário, ativa a proteção temporária para o screenshot
        enableProtection(reason: "screenshot")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }

            // Só desativa se não estiver gravando/compartilhando
            if !UIScreen.main.isCaptured {
                self.disableProtection()
            } else {
                print("[\(pluginTag)] Proteção mantida após screenshot devido à gravação ativa")
            }
        }
    }

    @objc func screenCaptureChanged() {
        print("[\(pluginTag)] screenCaptureChanged chamado")

        let captured = UIScreen.main.isCaptured
        print("[\(pluginTag)] Status de gravação: isCaptured=\(captured)")

        if captured {
            enableProtection(reason: "screen_recording")
        } else {
            disableProtection()
        }
    }

    @objc func getStatus(_ command: CDVInvokedUrlCommand) {
        let status: [String: Any] = [
            "isInitialized": isInitialized,
            "isProtecting": isProtecting,
            "isScreenBeingCaptured": UIScreen.main.isCaptured,
            "iosVersion": UIDevice.current.systemVersion,
            "isIOS13OrHigher": ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0))
        ]

        let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: status
        )

        self.commandDelegate?.send(result, callbackId: command.callbackId)
    }

    @objc func validateSetup(_ command: CDVInvokedUrlCommand) {
        var issues: [String] = []

        // Verifica versão do iOS
        if !ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)) {
            issues.append("iOS 13.0 ou superior é necessário")
        }

        // Verifica se o plugin foi inicializado
        if !isInitialized {
            issues.append("Plugin não foi inicializado corretamente")
        }

        // Verifica se os observers estão ativos
        let center = NotificationCenter.default
        let hasScreenshotObserver = center.observationInfo != nil
        let hasRecordingObserver = center.observationInfo != nil

        if !hasScreenshotObserver {
            issues.append("Observer de screenshot não está ativo")
        }
        if !hasRecordingObserver {
            issues.append("Observer de gravação não está ativo")
        }

        let status = CDVCommandStatus_OK
        let message: [String: Any] = [
            "isValid": issues.isEmpty,
            "issues": issues
        ]

        let result = CDVPluginResult(
            status: status,
            messageAs: message
        )

        self.commandDelegate?.send(result, callbackId: command.callbackId)
    }

    @objc func testProtection(_ command: CDVInvokedUrlCommand) {
        guard let reason = command.arguments.first as? String else {
            let result = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: "Razão não especificada"
            )
            self.commandDelegate?.send(result, callbackId: command.callbackId)
            return
        }

        // Simula a proteção
        enableProtection(reason: reason)

        // Agenda a remoção da proteção após 3 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.disableProtection()
        }

        let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: ["status": "Protection test started"]
        )
        self.commandDelegate?.send(result, callbackId: command.callbackId)
    }

    deinit {
        print("[\(pluginTag)] Plugin sendo destruído")
        NotificationCenter.default.removeObserver(self)
    }
}

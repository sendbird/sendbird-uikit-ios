//
//  CustomWebView_ChatBotWidgetController.swift
//  QuickStart
//
//  Created by Damon Park on 8/6/24.
//

import UIKit
import WebKit

class CustomWebView_ChatBotWidgetController: UIViewController {
    private let widgetView = ChatBotWidgetView()
    private let widgetButton = ChatBotWidgetButton()
    private let keyboardHandler = KeyboardLayoutHandler()
    
    private var keyboardHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDefaults()
        self.setupKeyboardLayouts()
        self.widgetDisplays()
    }
    
    func setupDefaults() {
        self.view.backgroundColor = .lightGray
        self.view.addSubview(self.widgetView)
        self.view.addSubview(self.widgetButton)
        
        self.widgetView.translatesAutoresizingMaskIntoConstraints = false
        self.widgetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.widgetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.widgetView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            self.widgetView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        
        NSLayoutConstraint.activate([
            self.widgetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            self.widgetButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            self.widgetButton.widthAnchor.constraint(equalToConstant: 40),
            self.widgetButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    func setupKeyboardLayouts() {
        self.keyboardHeightConstraint = self.widgetView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -70 // button + padding
        )
        self.keyboardHeightConstraint?.priority = .defaultLow
        self.keyboardHeightConstraint?.isActive = true
        
        self.keyboardHandler.updateHandler = { [weak self] result in
            self?.keyboardHeightConstraint?.constant = -(max(result.height, 70))
            
            UIView.animate(
                withDuration: result.duration,
                animations: { self?.view?.layoutIfNeeded() }
            )
        }
    }
    
    func widgetDisplays() {
        self.widgetButton.onClickHandler = { [weak self] appear in
            self?.widgetView.toggleDisplay(appear: appear)
        }
        
        self.widgetView.onCloseHandler = { [weak self] in
            self?.widgetView.toggleDisplay(appear: false)
            self?.widgetButton.toggleDisplay(appear: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyboardHandler.setupKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.keyboardHandler.clearKeyboardObservers()
    }
}

class ChatBotWidgetView: UIView {
    // NOTE: Setup please, application-id & bot-id.
    private let applicationId = "FEA2129A-EA73-4EB9-9E0B-EC738E7EB768"
    private let botId = "MXpw5QUgQshDaTHB0sZz2"
    private let showCloseIcon = true
    
    public var onCloseHandler: (() -> ())?
    
    private var busy = false
    
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: self.config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        webView.layer.cornerRadius = 20
        webView.clipsToBounds = true
        return webView
    }()
    
    lazy var config: WKWebViewConfiguration = {
        let contentController = WKUserContentController()
        contentController.add(self, name: "bridgeHandler")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        return config
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.loadHTML()
        self.toggleDisplay(appear: false, duration: 0)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.loadHTML()
        self.toggleDisplay(appear: false, duration: 0)
    }
    
    private func loadHTML() {
        let html = widgetHTML(
            applicationId: self.applicationId,
            botId: self.botId,
            showCloseIcon: self.showCloseIcon
        )
        
        // NOTE: `baseURL` is for caching web local storage.
        let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        self.webView.loadHTMLString(html, baseURL: baseURL)
    }
    
    private func setupView() {
        self.addSubview(self.webView)
        self.backgroundColor = .clear

        NSLayoutConstraint.activate([
            self.webView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.webView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.webView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            self.webView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.webView.scrollView.setContentOffset(.zero, animated: true)
        }
    }
}

// NOTE: webview delegate methods
extension ChatBotWidgetView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // did load widget
    }
    
    // Methods called when an error occurs
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(error)
    }
    
    // Methods called on page load failure
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleError(error)
    }
    
    // handle error
    private func handleError(_ error: Error) {
        debugPrint("\(error.localizedDescription)")
    }
}

extension ChatBotWidgetView: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "bridgeHandler" else { return }
        guard let messageBody = message.body as? String else { return }
        self.handleJavaScriptMessage(messageBody)
      }
      
      func handleJavaScriptMessage(_ message: String) {
          guard message == "closeChatBot" else { return }
          self.onCloseHandler?()
      }
}

// NOTE: transform animation methods
extension ChatBotWidgetView {
    public func toggleDisplay(appear: Bool, duration: TimeInterval = 0.2) {
        if self.busy == true { return }
        
        self.busy = true
        
        // Get default value from isHidden value.
        let appear = appear ?? self.webView.isHidden
        self.webView.isHidden = false
        
        // Set transform before animation
        self.setTransform(appear: !appear)
        
        UIView.animate(
            withDuration: duration,
            animations: {
                // Change transform
                self.setTransform(appear: appear)
            },
            completion: { _ in
                self.webView.isHidden = !appear
                self.busy = false
            }
        )
    }
            
    private func setTransform(appear: Bool) {
        if appear {
            self.webView.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
        } else {
            self.webView.transform = CGAffineTransform(translationX: self.bounds.width / 2, y: self.bounds.height / 2).scaledBy(x: 0.01, y: 0.01)
        }
    }
}

extension ChatBotWidgetView {
    func widgetHTML(
        applicationId: String,
        botId: String,
        showCloseIcon: Bool
    ) -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <meta http-equiv="X-UA-Compatible" content="ie=edge">
            <title>Chatbot</title>
        
            <!-- Load React and ReactDOM libraries -->
            <script crossorigin src="https://unpkg.com/react@18.2.0/umd/react.development.js"></script>
            <script crossorigin src="https://unpkg.com/react-dom@18.2.0/umd/react-dom.development.js"></script>
        
            <!-- Load chat-ai-widget script and set process.env to prevent it from being undefined -->
            <script>process = { env: { NODE_ENV: '' } }</script>
            <script crossorigin src="https://unpkg.com/@sendbird/chat-ai-widget@latest/dist/index.umd.js"></script>
            <link href="https://unpkg.com/@sendbird/chat-ai-widget@latest/dist/style.css" rel="stylesheet" />
        
            <!-- Optional; to enable JSX syntax -->
            <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
            <style>
                html, body { height: 100%; margin: 0; }
                \(showCloseIcon == true ? "" : "#aichatbot-widget-close-icon { display: none }")
            </style>
          </head>
          <body>
            <!-- div element for chat-ai-widget container -->
            <div id="root"></div>
        
            <!-- Initialize chat-ai-widget and render the widget component -->
            <script type="text/babel">
              const { ChatWindow } = window.ChatAiWidget;
              const App = () => {
                return (
                  <ChatWindow
                    applicationId="\(applicationId)"
                    botId="\(botId)"
                  />
                );
              };
              ReactDOM.createRoot(document.querySelector('#root')).render(<App />);
            </script>
            <script>
                // Attach click event to the close icon after the chat widget is loaded
                window.onload = function() {
                  setTimeout(() => {
                    const closeIcon = document.querySelector('#aichatbot-widget-close-icon');
                    closeIcon?.addEventListener('click', () => window.webkit?.messageHandlers?.bridgeHandler?.postMessage?.("closeChatBot"));
                  }, 1000); // delay to ensure the element is loaded
                };
            </script>
          </body>
        </html>
        """
    }
}

class ChatBotWidgetButton: UIView {
    public var onClickHandler: ((Bool) -> ())?
   
    private var busy = false
    
    private lazy var openButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "logoSendbird"), for: .normal)
        button.addTarget(self, action: #selector(onClickButton), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "iconClose"), for: .normal)
        button.addTarget(self, action: #selector(onClickButton), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.toggleDisplay(appear: false, duration: 0)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.toggleDisplay(appear: false, duration: 0)
    }
    
    private func setupView() {
        self.addSubview(self.openButton)
        self.addSubview(self.closeButton)
        self.backgroundColor = .white
        self.layer.cornerRadius = 20

        NSLayoutConstraint.activate([
            self.openButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.openButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            self.openButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            self.openButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            
            self.closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.closeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            self.closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            self.closeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
        ])
    }
    
    @objc func onClickButton() {
        let willAppear = self.closeButton.alpha == 0.0
        
        self.onClickHandler?(willAppear)
        self.toggleDisplay(appear: willAppear)
    }
    
    private func setTransform(appear: Bool, closing: Bool = false) {
        let scaledValue = closing ? 0.001 : 1.0
        
        if appear {
            self.openButton.transform = CGAffineTransform(rotationAngle: .pi * 3).scaledBy(x: scaledValue, y: scaledValue)
            self.closeButton.transform = CGAffineTransform(rotationAngle: .pi * 2).scaledBy(x: scaledValue, y: scaledValue)
        } else {
            self.openButton.transform = CGAffineTransform(rotationAngle: .pi * 2).scaledBy(x: scaledValue, y: scaledValue)
            self.closeButton.transform = CGAffineTransform(rotationAngle: .pi * 3).scaledBy(x: scaledValue, y: scaledValue)
        }
    }
    
    public func toggleDisplay(appear: Bool, duration: TimeInterval = 0.2) {
        if self.busy == true { return }
        
        self.busy = true
        
        // Set transform before animation
        self.setTransform(appear: appear)
        
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45) {
                    // Change transform
                    self.setTransform(appear: !appear, closing: true)
                    if appear {
                        self.openButton.alpha = 0.0
                    } else {
                        self.closeButton.alpha = 0.0
                    }
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                    // Change transform
                    self.setTransform(appear: appear)
                    if appear {
                        self.closeButton.alpha = 1.0
                    } else {
                        self.openButton.alpha = 1.0
                    }
                }
            }, 
            completion: { _ in
                self.busy = false
            }
        )
    }
}

class KeyboardLayoutHandler {
    var updateHandler: ((KeyboardLayoutHandler.Result) -> ())?
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func clearKeyboardObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        adjustForKeyboard(notification: notification, showing: true)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        adjustForKeyboard(notification: notification, showing: false)
    }
    
    private func adjustForKeyboard(notification: NSNotification, showing: Bool) {
        guard let userInfo = notification.userInfo else { return }
        
        let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.3
        
        self.updateHandler?(
            Result(
                height: showing ? height : 0,
                duration: duration
            )
        )
    }
    
    struct Result {
        let height: CGFloat
        let duration: TimeInterval
    }
    
}

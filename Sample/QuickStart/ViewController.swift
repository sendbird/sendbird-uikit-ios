import UIKit
import SendbirdChatSDK

enum ButtonType: Int {
    case signIn
}

class ViewController: UIViewController, UserEventDelegate, ConnectionDelegate {
    // MARK: - Properties
    
    @IBOutlet weak var logoStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInStackView: UIStackView!
    
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            loadingIndicator.stopAnimating()
        }
    }

    let duration: TimeInterval = 0.4

    enum CornerRadius: CGFloat {
        case small = 4.0
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SBUTheme.set(theme: .light)
//        GlobalSetCustomManager.setDefault()
        
        nicknameTextField.text = UserDefaults.loadNickname()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.tag = ButtonType.signIn.rawValue
        userIdTextField.delegate = self
        nicknameTextField.delegate = self
        
        SendbirdChat.addUserEventDelegate(self, identifier: self.description)
        SendbirdChat.addConnectionDelegate(self, identifier: self.description)
        
        userIdTextField.text = UserDefaults.loadUserID()
        nicknameTextField.text = UserDefaults.loadNickname()
        
        if let userId = userIdTextField.text,
           let nickname = nicknameTextField.text,
           !userId.isEmpty, !nickname.isEmpty {
            signinAction()
        }
    }
    
    deinit {
        SendbirdChat.removeUserEventDelegate(forIdentifier: self.description)
        SendbirdChat.removeConnectionDelegate(forIdentifier: self.description)
    }
    
    // MARK: - Actions
    @IBAction func onTapButton(_ sender: UIButton) {
        if sender.tag == ButtonType.signIn.rawValue {
            self.signinAction()
        }
    }

    func signinAction() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        guard let userID = userIdTextField.text, !userID.isEmpty else {
            userIdTextField.shake()
            userIdTextField.becomeFirstResponder()
            loadingIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
            return
        }
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            nicknameTextField.shake()
            nicknameTextField.becomeFirstResponder()
            loadingIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
            return
        }
        
        SBUGlobals.currentUser = SBUUser(userId: userID, nickname: nickname)
        SendbirdUI.connect { [weak self] user, error in
            self?.loadingIndicator.stopAnimating()
            self?.view.isUserInteractionEnabled = true
            
            if let user = user {
                UserDefaults.saveUserID(userID)
                UserDefaults.saveNickname(nickname)
                
                print("SendbirdUIKit.connect: \(user)")
                
                let mainVC = SBUGroupChannelListViewController()
                let naviVC = UINavigationController(rootViewController: mainVC)
                naviVC.modalPresentationStyle = .fullScreen
                self?.present(naviVC, animated: true)
            }
        }
    }
}

extension ViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

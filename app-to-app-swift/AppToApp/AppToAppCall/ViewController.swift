import UIKit
import VonageClientSDKVoice

class ViewController: UIViewController {
    
    let loginAliceButton = UIButton(type: .system)
    let loginBobButton = UIButton(type: .system)
    let connectionStatusLabel = UILabel()
    
    var client = VGVoiceClient()
    
    var user: User? {
        didSet {
            login()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loginAliceButton.setTitle("Log in as Alice", for: .normal)
        loginAliceButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginAliceButton)
        
        loginBobButton.setTitle("Log in as Bob", for: .normal)
        loginBobButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginBobButton)
        
        connectionStatusLabel.text = ""
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(connectionStatusLabel)
        
        NSLayoutConstraint.activate([
            loginAliceButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginAliceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginAliceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginAliceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            loginBobButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginBobButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginBobButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginBobButton.topAnchor.constraint(equalTo: loginAliceButton.bottomAnchor, constant: 20),
            
            connectionStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectionStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            connectionStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            connectionStatusLabel.topAnchor.constraint(equalTo: loginBobButton.bottomAnchor, constant: 20)
        ])
        
        loginAliceButton.addTarget(self, action: #selector(setUserAsAlice), for: .touchUpInside)
        loginBobButton.addTarget(self, action: #selector(setUserAsBob), for: .touchUpInside)
    }
    
    func login() {
        guard let user = self.user else { return }
        let config = VGClientConfig(region: .US)
        client.setConfig(config)
        client.createSession(user.jwt, sessionId: nil) { error, sessionId in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if error == nil {
                    let navigationController = UINavigationController(rootViewController: CallViewController(user: user, client: self.client))
                    navigationController.modalPresentationStyle = .overFullScreen
                    self.present(navigationController, animated: true, completion: nil)
                } else {
                    self.connectionStatusLabel.text = error?.localizedDescription
                }
            }
        }
    }
    
    @objc func setUserAsAlice() {
        self.user = User.Alice
    }
    
    @objc func setUserAsBob() {
        self.user = User.Bob
    }
}

struct User {
    let name: String
    let jwt: String
    let callPartnerName: String
    
    static let Alice = User(name: "Alice",
                            jwt:"ALICE_JWT",
                            callPartnerName: "Bob")
    static let Bob = User(name: "Bob",
                          jwt:"BOB_JWT",
                          callPartnerName: "Alice")
}

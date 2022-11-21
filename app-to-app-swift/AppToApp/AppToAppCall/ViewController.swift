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
                            jwt:"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2Njg2OTYzMzcsImp0aSI6IjgwMTk1Y2IwLTY2ODYtMTFlZC1hMjUyLTZiMThkMWQ0M2VhMSIsImFwcGxpY2F0aW9uX2lkIjoiZjY5YzZmN2MtNmU2MC00NzFjLTgxYzItYjY5MTZjODVlNTI3Iiwic3ViIjoiQWxpY2UiLCJleHAiOjE2Njg2OTYzNTk1MTQsImFjbCI6eyJwYXRocyI6eyIvKi91c2Vycy8qKiI6e30sIi8qL2NvbnZlcnNhdGlvbnMvKioiOnt9LCIvKi9zZXNzaW9ucy8qKiI6e30sIi8qL2RldmljZXMvKioiOnt9LCIvKi9pbWFnZS8qKiI6e30sIi8qL21lZGlhLyoqIjp7fSwiLyovYXBwbGljYXRpb25zLyoqIjp7fSwiLyovcHVzaC8qKiI6e30sIi8qL2tub2NraW5nLyoqIjp7fSwiLyovbGVncy8qKiI6e319fX0.cjPf_vTDbtn9Uvk1u8s88ZMDiPfJlrgkfWHmdy4TWUiweT6G9Kmh0m0xvlqUI1wQZDx0h-b__9IjfAzGHrYdldOuNu00K8KvMt3ah9UzIddC4Ojm8V_iJoKD_bpkRlrlpjjYpGGUoMtRN-owuiIQCa3wunF_C9odPmyeuoExPSfkW5jzXIDac5S08UB7MW3AqJ5pvKKc-BApQkHlnGLKemDrw649ECMWjsPWpvIS0Erq8KVKJ3H28ykl0ErjzykbsFU2lb5vgeNCKJoeSj_0Fn0aVtJq_9dH2MyXrr03UY_1rQ9ayWPidph1Ir-6G_u_n_tIyM7tPW83xBI1lTFZww",
                            callPartnerName: "Bob")
    static let Bob = User(name: "Bob",
                          jwt:"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2Njg2OTYzNDYsImp0aSI6Ijg1NTFiYTEwLTY2ODYtMTFlZC05YjNlLTlmNjNjMmYyYmQwYyIsImFwcGxpY2F0aW9uX2lkIjoiZjY5YzZmN2MtNmU2MC00NzFjLTgxYzItYjY5MTZjODVlNTI3Iiwic3ViIjoiQm9iIiwiZXhwIjoxNjY4Njk2MzY4MjczLCJhY2wiOnsicGF0aHMiOnsiLyovdXNlcnMvKioiOnt9LCIvKi9jb252ZXJzYXRpb25zLyoqIjp7fSwiLyovc2Vzc2lvbnMvKioiOnt9LCIvKi9kZXZpY2VzLyoqIjp7fSwiLyovaW1hZ2UvKioiOnt9LCIvKi9tZWRpYS8qKiI6e30sIi8qL2FwcGxpY2F0aW9ucy8qKiI6e30sIi8qL3B1c2gvKioiOnt9LCIvKi9rbm9ja2luZy8qKiI6e30sIi8qL2xlZ3MvKioiOnt9fX19.BXLvHvdDbp03dkf6icX6zbR66o4p-iHVoNT6uxaD9Pwi_TILI39V1fQ7-y4-bxvDFwllpJ1rnge74twCUMnTP0-eWY1E6YwIFceHJBcis0KQ4bO8wwz5MAsqq9CaSiyzhb8NT8lua4bpUo5KswMfCGEcaSOsh-5Rrvm-Eh3p3VBRa2akP0PavfyVg0SywH-gTMReBHUGwJiH1hjhp2ehwjryI5A7WXEIjJ6CMnWHZX9-SwWuUUM4LFS-btXLGUXlIyzOX4Oq-OG-Zqd7Yiw5qUCPLHUJWPfHHtnYM1pUPb7HFh8BiV1FZVs1vZnOig_aq7liU5Rw4DEcUOC3LgaRDQ",
                          callPartnerName: "Alice")
}

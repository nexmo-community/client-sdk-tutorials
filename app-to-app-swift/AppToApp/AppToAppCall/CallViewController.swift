import UIKit
import VonageClientSDKVoice

class CallViewController: UIViewController {
    
    let callButton = UIButton(type: .system)
    let hangUpButton = UIButton(type: .system)
    let statusLabel = UILabel()
    
    let user: User
    let client: VGVoiceClient
    
    var call: VGVoiceCall?
    
    init(user: User, client: VGVoiceClient) {
        self.user = user
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        callButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(callButton)
        
        hangUpButton.setTitle("Hang up", for: .normal)
        hangUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        setHangUpButtonHidden(true)
        view.addSubview(hangUpButton)
        
        setStatusLabelText("Ready to receive call...")
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            callButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            callButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            callButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            hangUpButton.topAnchor.constraint(equalTo: callButton.bottomAnchor, constant: 20),
            hangUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hangUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hangUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: hangUpButton.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(self.logout))
        callButton.setTitle("Call \(user.callPartnerName)", for: .normal)
        
        
        hangUpButton.addTarget(self, action: #selector(endCall), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(makeCall), for: .touchUpInside)
        
        self.client.delegate = self
    }
    
    @objc private func makeCall() {
        setStatusLabelText("Calling \(user.callPartnerName)")
        
        client.serverCall(["callee": user.callPartnerName]) { error, call in
            if error == nil {
                self.setHangUpButtonHidden(false)
                self.call = call
            } else {
                self.setStatusLabelText(error?.localizedDescription)
            }
        }
    }
    
    func displayIncomingCallAlert(callInvite: VGVoiceInvite) {
        let from = callInvite.from.id ?? "Unknown"
        
        let alert = UIAlertController(title: "Incoming call from", message: from, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Answer", style: .default, handler: { _ in
            callInvite.answer { error, call in
                if error == nil {
                    self.setHangUpButtonHidden(false)
                    self.setStatusLabelText("On a call with \(from)")
                    self.call = call
                } else {
                    self.setStatusLabelText(error?.localizedDescription)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { _ in
            callInvite.reject { error in
                if let error {
                    self.setStatusLabelText(error.localizedDescription)
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func endCall() {
        call?.hangup({ error in
            if error == nil {
                self.call = nil
                self.setHangUpButtonHidden(true)
                self.setStatusLabelText("Ready to receive call...")
            }
        })
    }
    
    @objc func logout() {
        client.deleteSession { error in
            if error == nil {
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func setHangUpButtonHidden(_ isHidden: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.hangUpButton.isHidden = isHidden
            self.callButton.isHidden = !self.hangUpButton.isHidden
        }
    }
    
    private func setStatusLabelText(_ text: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.statusLabel.text = text
        }
    }
}

extension CallViewController: VGVoiceClientDelegate {
    func voiceClient(_ client: VGVoiceClient, didReceive invite: VGVoiceInvite) {
        DispatchQueue.main.async { [weak self] in
            self?.displayIncomingCallAlert(callInvite: invite)
        }
    }
    
    func voiceClient(_ client: VGVoiceClient, didReceiveHangupFor call: VGVoiceCall, withLegId legId: String, andQuality callQuality: VGRTCQuality) {
        self.call = nil
        self.setHangUpButtonHidden(true)
        self.setStatusLabelText("Ready to receive call...")
    }
    
    // TODO: should be an enum
    func client(_ client: VGBaseClient, didReceiveSessionErrorWithReason reason: String) {
        self.setStatusLabelText(reason)
    }
}

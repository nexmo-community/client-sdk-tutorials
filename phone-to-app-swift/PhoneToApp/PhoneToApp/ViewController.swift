import UIKit
import VonageClientSDKVoice

class ViewController: UIViewController {
    
    let connectionStatusLabel = UILabel()
    let client = VGVoiceClient()
    var call: VGVoiceCall?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        connectionStatusLabel.text = "Disconnected"
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(connectionStatusLabel)
        
        NSLayoutConstraint.activate([
            connectionStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectionStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let config = VGClientConfig(region: .US)
        client.setConfig(config)
        client.delegate = self
        
        client.createSession("ALICE_JWT", sessionId: nil) { error, sessionId in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if error == nil {
                    self.connectionStatusLabel.text = "Connected"
                } else {
                    self.connectionStatusLabel.text = error?.localizedDescription
                }
            }
        }
    }
    
    func displayIncomingCallAlert(callInvite: VGVoiceInvite) {
        let from = callInvite.from.id ?? "Unknown"
        
        let alert = UIAlertController(title: "Incoming call from", message: from, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Answer", style: .default, handler: { _ in
            callInvite.answer { error, call in
                if error == nil {
                    self.call = call
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { _ in
            callInvite.reject { error in
                if let error {
                    self.connectionStatusLabel.text = error.localizedDescription
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: VGVoiceClientDelegate {
    
    func voiceClient(_ client: VGVoiceClient, didReceive invite: VGVoiceInvite) {
        DispatchQueue.main.async { [weak self] in
            self?.displayIncomingCallAlert(callInvite: invite)
        }
    }
    
    func voiceClient(_ client: VGVoiceClient, didReceiveHangupFor call: VGVoiceCall, withLegId legId: String, andQuality callQuality: VGRTCQuality) {
        DispatchQueue.main.async { [weak self] in
            self?.call = nil
            self?.connectionStatusLabel.text = "Call Ended"
        }
    }
    
    // TODO: should be an enum
    func client(_ client: VGBaseClient, didReceiveSessionErrorWithReason reason: String) {
        DispatchQueue.main.async { [weak self] in
            self?.connectionStatusLabel.text = reason
        }
    }
}

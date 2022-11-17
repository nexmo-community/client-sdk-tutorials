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
        // TODO: No caller info
        let from = "Unknown"
        
        let alert = UIAlertController(title: "Incoming call from", message: from, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Answer", style: .default, handler: { _ in
            callInvite.answer { error, call in
                if error == nil {
                    self.call = call
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Reject", style: .default, handler: { _ in
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
    
    func client(_ client: VGBaseClient, didReceiveSessionErrorWithReason reason: String) {
        DispatchQueue.main.async { [weak self] in
            self?.connectionStatusLabel.text = reason
        }
    }
    
    // TODO: Some (if not most) of these should be optional!
    func clientWillReconnect(_ client: VGBaseClient) {}
    func clientDidReconnect(_ client: VGBaseClient) {}
    func voiceClient(_ client: VGVoiceClient, didReceiveCallTransferFor call: VGVoiceCall, withNewConversation newConversation: VGConversation, andPrevConversation prevConversation: VGConversation) {}
    func voiceClient(_ client: VGVoiceClient, didReceiveMuteFor call: VGVoiceCall, withLegId legId: String, andStatus isMuted: Bool) {}
    func voiceClient(_ client: VGVoiceClient, didReceiveEarmuffFor call: VGVoiceCall, withLegId legId: String, andStatus earmuffStatus: Bool) {}
    func voiceClient(_ client: VGVoiceClient, didReceiveDTMFFor call: VGVoiceCall, withLegId legId: String, andDigits digits: String) {}
}

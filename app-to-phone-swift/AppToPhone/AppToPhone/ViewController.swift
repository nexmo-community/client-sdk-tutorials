import UIKit
import VonageClientSDKVoice

class ViewController: UIViewController {
    
    var connectionStatusLabel = UILabel()
    var callButton = UIButton(type: .roundedRect)
    let client = VGVoiceClient()
    var call: VGVoiceCall?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        connectionStatusLabel.text = "Disconnected"
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(connectionStatusLabel)

        callButton.setTitle("Call", for: .normal)
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.alpha = 0
        callButton.addTarget(self, action: #selector(callButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(callButton)
        
        NSLayoutConstraint.activate([
            connectionStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectionStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            callButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callButton.topAnchor.constraint(equalTo: connectionStatusLabel.bottomAnchor, constant: 24)
        ])
        
        let config = VGClientConfig(region: .US)
        client.setConfig(config)
        
        client.createSession("ALICE_JWT", sessionId: nil) { error, sessionId in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if error == nil {
                    self.callButton.alpha = 1
                    self.connectionStatusLabel.text = "Connected"
                } else {
                    self.connectionStatusLabel.text = error?.localizedDescription
                }
            }
        }
    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        if call == nil {
            placeCall()
        } else {
            endCall()
        }
    }
    
    func placeCall() {
        callButton.setTitle("End Call", for: .normal)
        client.serverCall(["callee": "PHONE_NUMBER"]) { error, call in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if error == nil {
                    self.call = call
                } else {
                    self.callButton.setTitle("Call", for: .normal)
                    self.connectionStatusLabel.text = error?.localizedDescription
                }
            }
        }
    }
    
    func endCall() {
        call?.hangup({ error in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if error == nil {
                    self.call = nil
                    self.callButton.setTitle("Call", for: .normal)
                }
            }
        })
    }
}

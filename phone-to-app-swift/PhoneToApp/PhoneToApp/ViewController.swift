import UIKit
import NexmoClient

class ViewController: UIViewController {
    
    let connectionStatusLabel = UILabel()
    let client = NXMClient.shared
    var call: NXMCall?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        connectionStatusLabel.text = "Unknown"
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(connectionStatusLabel)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[label]-20-|",
                                                           options: [], metrics: nil, views: ["label" : connectionStatusLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[label(20)]",
                                                           options: [], metrics: nil, views: ["label" : connectionStatusLabel]))
        
        client.setDelegate(self)
        client.login(withAuthToken: "ALICE_JWT")
    }
    
    func displayIncomingCallAlert(call: NXMCall) {
        let from = call.myMember?.channel?.from.data ?? "Unknown"
        
        let alert = UIAlertController(title: "Incoming call from", message: from, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Answer", style: .default, handler: { _ in
            self.call = call
            call.answer(nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Reject", style: .default, handler: { _ in
            call.reject(nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: NXMClientDelegate {
    
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        DispatchQueue.main.async { [weak self] in
            switch status {
            case .connected:
                self?.connectionStatusLabel.text = "Connected"
            case .disconnected:
                self?.connectionStatusLabel.text = "Disconnected"
            case .connecting:
                self?.connectionStatusLabel.text = "Connecting"
            @unknown default:
                self?.connectionStatusLabel.text = "Unknown"
            }
        }
    }
    
    func client(_ client: NXMClient, didReceiveError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.connectionStatusLabel.text = error.localizedDescription
        }
    }
    
    func client(_ client: NXMClient, didReceive call: NXMCall) {
        DispatchQueue.main.async { [weak self] in
            self?.displayIncomingCallAlert(call: call)
        }
    }
}

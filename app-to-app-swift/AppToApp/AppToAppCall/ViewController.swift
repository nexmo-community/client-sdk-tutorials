//
//  ViewController.swift
//  AppToAppCall
//
//  Created by Abdulhakim Ajetunmobi on 28/07/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

import UIKit
import NexmoClient

class ViewController: UIViewController {
    
    let loginAliceButton = UIButton(type: .system)
    let loginBobButton = UIButton(type: .system)
    let statusLabel = UILabel()
    
    let client = NXMClient.shared
    let nc = NotificationCenter.default
    
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
        
        statusLabel.text = ""
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            loginAliceButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginAliceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginAliceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginAliceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            loginBobButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginBobButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginBobButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginBobButton.topAnchor.constraint(equalTo: loginAliceButton.bottomAnchor, constant: 20),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusLabel.topAnchor.constraint(equalTo: loginBobButton.bottomAnchor, constant: 20)
        ])
        
        loginAliceButton.addTarget(self, action: #selector(setUserAsAlice), for: .touchUpInside)
        loginBobButton.addTarget(self, action: #selector(setUserAsBob), for: .touchUpInside)
    }
    
    @objc func setUserAsAlice() {
        self.user = User.Alice
    }
    
    @objc func setUserAsBob() {
        self.user = User.Bob
    }
    
    func login() {
        guard let user = self.user else { return }
        client.login(withAuthToken: user.jwt)
        client.setDelegate(self)
    }
    
}

extension ViewController: NXMClientDelegate {
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        DispatchQueue.main.async {
            guard let user = self.user else { return }
            
            switch status {
            case .connected:
                self.statusLabel.text = "Connected"
                let navigationController = UINavigationController(rootViewController: CallViewController(user: user))
                navigationController.modalPresentationStyle = .overFullScreen
                self.present(navigationController, animated: true, completion: nil)
            case .disconnected:
                self.statusLabel.text = "Disconnected"
            case .connecting:
                self.statusLabel.text = "Connecting"
            @unknown default:
                self.statusLabel.text = ""
            }
        }
    }
    
    func client(_ client: NXMClient, didReceiveError error: Error) {
        DispatchQueue.main.async {
            self.statusLabel.text = error.localizedDescription
        }
    }
    
    func client(_ client: NXMClient, didReceive call: NXMCall) {
        nc.post(name: .call, object: call)
    }
}

extension Notification.Name {
    static var call: Notification.Name {
        return .init(rawValue: "NXMClient.incomingCall")
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



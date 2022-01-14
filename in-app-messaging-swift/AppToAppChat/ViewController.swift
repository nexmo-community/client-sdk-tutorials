//
//  ViewController.swift
//  AppToAppChat
//
//  Created by Abdulhakim Ajetunmobi on 20/07/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

import UIKit
import NexmoClient

class ViewController: UIViewController {
    
    let loginAliceButton = UIButton(type: .system)
    let loginBobButton = UIButton(type: .system)
    let statusLabel = UILabel()
    
    let client = NXMClient.shared
    
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
        loginAliceButton.addTarget(self, action: #selector(setUserAsAlice), for: .touchUpInside)
        view.addSubview(loginAliceButton)
        
        loginBobButton.setTitle("Log in as Bob", for: .normal)
        loginBobButton.translatesAutoresizingMaskIntoConstraints = false
        loginBobButton.addTarget(self, action: #selector(setUserAsBob), for: .touchUpInside)
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
    }

    @objc func setUserAsAlice() {
        self.user = User.Alice
    }
    
    @objc func setUserAsBob() {
        self.user = User.Bob
    }
    
    func login() {
        guard let user = self.user else { return }
        
        client.setDelegate(self)
        client.login(withAuthToken: user.jwt)
    }

}

extension ViewController: NXMClientDelegate {
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        guard let user = self.user else { return }
        
        switch status {
        case .connected:
            setStatusLabel("Connected")
            
            let navigationController = UINavigationController(rootViewController: ChatViewController(user: user))
            navigationController.modalPresentationStyle = .overFullScreen
            present(navigationController, animated: true, completion: nil)
        case .disconnected:
            setStatusLabel("Disconnected")
        case .connecting:
            setStatusLabel("Connecting")
        @unknown default:
            setStatusLabel("")
        }
    }
    
    func client(_ client: NXMClient, didReceiveError error: Error) {
        setStatusLabel(error.localizedDescription)
    }
    
    func setStatusLabel(_ newStatus: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.statusLabel.text = newStatus
        }
    }
}

struct User {
    let name: String
    let jwt: String
    let chatPartnerName: String
    let conversationId = "CONVERSATION_ID"
    
    static let Alice = User(name: "Alice",
                            jwt:"ALICE_JWT",
                            chatPartnerName: "Bob")
    static let Bob = User(name: "Bob",
                          jwt:"BOB_JWT",
                          chatPartnerName: "Alice")
}


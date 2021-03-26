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
                            jwt:"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2MTY3NjA0NDMsImp0aSI6ImQyZWIwZTUwLThlMmItMTFlYi1hNDM3LTM3YjlkZTYxZjllNCIsImV4cCI6MTYxNjc4MjA0MiwiYWNsIjp7InBhdGhzIjp7Ii8qL3VzZXJzLyoqIjp7fSwiLyovY29udmVyc2F0aW9ucy8qKiI6e30sIi8qL3Nlc3Npb25zLyoqIjp7fSwiLyovZGV2aWNlcy8qKiI6e30sIi8qL2ltYWdlLyoqIjp7fSwiLyovbWVkaWEvKioiOnt9LCIvKi9hcHBsaWNhdGlvbnMvKioiOnt9LCIvKi9wdXNoLyoqIjp7fSwiLyova25vY2tpbmcvKioiOnt9LCIvKi9sZWdzLyoqIjp7fX19LCJzdWIiOiJBbGljZSIsImFwcGxpY2F0aW9uX2lkIjoiOThmMjFmNDUtZjhhYy00MTA1LTk3MDYtZTliOTA4Y2VhMjEzIn0.yQLBVPxktM7d5xeHGaxUat6YyU6hjn76O6-3ysYHnQdVm-ZG1ny1Enbt2w0ESFaNlIFJDxrfkAw41z_j3hPKKrVgtO87Djve9nhCXWTbd75MLUSRnkNXHmYFJEM1HDfVjqnnveCDyeWt_hjULcl2rJbGlbGIXwt7NCi-wOC_2MQLjCXlRdZz-rynBFPrPQvBZhrSfZXrgENyyCbVFNI3RBDh6uE-ws_6Zt9OIp2V4dfcCzDG1mDRx1kOEKaKwz_vkjSGg0PqFyyn5l6G7jaeVUEf5uZZ3v3WIb8yuUcxE2Wfj8HVyyqw6XIx-NHV2hAQhAn1QPbF01kRjpDDaQ3czA",
                            callPartnerName: "Bob")
    static let Bob = User(name: "Bob",
                          jwt:"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2MTY3NjU5NjksImp0aSI6ImIwMmYxMzQwLThlMzgtMTFlYi1iZGZiLTU3Y2NjOGViMDM2MCIsImV4cCI6MTYxNjc4NzU2OCwiYWNsIjp7InBhdGhzIjp7Ii8qL3VzZXJzLyoqIjp7fSwiLyovY29udmVyc2F0aW9ucy8qKiI6e30sIi8qL3Nlc3Npb25zLyoqIjp7fSwiLyovZGV2aWNlcy8qKiI6e30sIi8qL2ltYWdlLyoqIjp7fSwiLyovbWVkaWEvKioiOnt9LCIvKi9hcHBsaWNhdGlvbnMvKioiOnt9LCIvKi9wdXNoLyoqIjp7fSwiLyova25vY2tpbmcvKioiOnt9LCIvKi9sZWdzLyoqIjp7fX19LCJzdWIiOiJCb2IiLCJhcHBsaWNhdGlvbl9pZCI6Ijk4ZjIxZjQ1LWY4YWMtNDEwNS05NzA2LWU5YjkwOGNlYTIxMyJ9.yOAuAbrCCZIK2UgwUo8eTSLWQ3SRZVnXtlZ6O9pc4qL2WLhFBYDvQO6PpCWcQbLacgiYzPK4GBo0Yf8YsCk5E9siZNSRiuT1OHol7DJ5DwQH64ZCY4IW6LdYWCjf-2dPhYqxk7wE4fAgDm0i5kWZAv8ygod32z3u_sYT6C1oMJJlkqi1W67fP3DD8yQTZKZe0Sec8Sqfgsi4H8qN6qYibRda0_uXW3eEa4VHbjWJqm6itRpCM7fVw_XO7KIvhSlpzUChLBIlQMgwoJaTBdt5RHX7nD5jVEhxDWzoORxsIqgTrW2bU8EQUv5z2JdyOaInif_qb7jjjEnwomGRu-JzbQ",
                          callPartnerName: "Alice")
}



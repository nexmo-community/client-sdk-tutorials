//
//  CallViewController.swift
//  AppToAppCall
//
//  Created by Abdulhakim Ajetunmobi on 28/07/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

import UIKit
import NexmoClient

class CallViewController: UIViewController {
    
    let user: User
    let client = NXMClient.shared
    let nc = NotificationCenter.default
    
    var call: NXMCall?
    
    let callButton = UIButton(type: .system)
    let hangUpButton = UIButton(type: .system)
    let statusLabel = UILabel()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        callButton.setTitle("Call \(user.callPartnerName)", for: .normal)
        callButton.translatesAutoresizingMaskIntoConstraints = false
        if user.name == "Alice" {
            callButton.alpha = 0
        }
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
        nc.addObserver(self, selector: #selector(didReceiveCall), name: .call, object: nil)
        
        hangUpButton.addTarget(self, action: #selector(endCall), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(makeCall), for: .touchUpInside)
    }
    
    @objc private func logout() {
        client.logout()
        dismiss(animated: true, completion: nil)
    }

    @objc private func didReceiveCall(_ notification: Notification) {
        guard let call = notification.object as? NXMCall else { return }
        DispatchQueue.main.async { [weak self] in
            self?.displayIncomingCallAlert(call: call)
        }
    }
    
    private func displayIncomingCallAlert(call: NXMCall) {
        var from = "Unknown"
        if let otherParty = call.otherCallMembers.firstObject as? NXMCallMember {
            from = otherParty.user.name
        }

        let alert = UIAlertController(title: "Incoming call from", message: from, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Answer", style: .default, handler: { _ in
            call.answer { error in
                if error != nil {
                    self.setStatusLabelText(error?.localizedDescription)
                    return
                }
                call.setDelegate(self)
                self.setHangUpButtonHidden(false)
                self.setStatusLabelText("On a call with \(from)")
                self.call = call
            }
        }))

        alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { _ in
            call.reject(nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func endCall() {
        call?.hangup()
        self.setHangUpButtonHidden(true)
        self.setStatusLabelText("Ready to receive call...")
    }

    @objc private func makeCall() {
        setStatusLabelText("Calling \(user.callPartnerName)")

        client.call(user.callPartnerName, callHandler: .server) { error, call in
            if error != nil {
                self.setStatusLabelText(error?.localizedDescription)
                return
            }
            call?.setDelegate(self)
            self.setHangUpButtonHidden(false)
            self.call = call
        }
    }

    
    private func setHangUpButtonHidden(_ isHidden: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hangUpButton.isHidden = isHidden
            self.callButton.isHidden = !self.hangUpButton.isHidden
        }
    }
    
    private func setStatusLabelText(_ text: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.statusLabel.text = text
        }
    }
}

extension CallViewController: NXMCallDelegate {
    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, with status: NXMCallMemberStatus) {
        switch status {
        case .answered:
            guard callMember.user.name != self.user.name else { return }
            setStatusLabelText("On a call with \(callMember.user.name)")
        case .completed:
            setStatusLabelText("Call ended")
            setHangUpButtonHidden(true)
            self.call = nil
        default:
            break
        }
    }

    func call(_ call: NXMCall, didReceive error: Error) {
        setStatusLabelText(error.localizedDescription)
    }

    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, isMuted muted: Bool) {}
}


//
//  ViewController.m
//  AppToPhone
//
//  Created by Abdulhakim Ajetunmobi on 19/08/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

#import "ViewController.h"
#import <NexmoClient/NexmoClient.h>

@interface ViewController () <NXMClientDelegate>
@property UIButton *callButton;
@property UILabel *connectionStatusLabel;
@property NXMClient *client;
@property NXMCall * call;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.connectionStatusLabel = [[UILabel alloc] init];
    self.connectionStatusLabel.text = @"Unknown";
    self.connectionStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.connectionStatusLabel];
    
    self.callButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.callButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.callButton setAlpha:0];
    [self.callButton addTarget:self action:@selector(callButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
    [self.view addSubview:self.callButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.connectionStatusLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.connectionStatusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.connectionStatusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [self.callButton.topAnchor constraintEqualToAnchor:self.connectionStatusLabel.bottomAnchor constant:40],
        [self.callButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.callButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
    
    self.client = NXMClient.shared;
    [self.client setDelegate:self];
    [self.client loginWithAuthToken:@"ALICE_JWT"];
}

- (void)callButtonPressed {
    if (!self.call) {
        [self placeCall];
    } else {
        [self endCall];
    }
}

- (void)placeCall {
    [self.client call:@"PHONE_NUMBER" callHandler:NXMCallHandlerServer completionHandler:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        if (error) {
            self.connectionStatusLabel.text = error.localizedDescription;
            return;
        }
        
        self.call = call;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.callButton setTitle:@"End call" forState:UIControlStateNormal];
        });
    }];
}

- (void)endCall {
    [self.call hangup];
    self.call = nil;
    [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
}

- (void)client:(nonnull NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (status) {
            case NXMConnectionStatusConnected:
                [self.callButton setAlpha:1];
                self.connectionStatusLabel.text = @"Connected";
                break;
            case NXMConnectionStatusConnecting:
                self.connectionStatusLabel.text = @"Connecting";
                break;
            case NXMConnectionStatusDisconnected:
                self.connectionStatusLabel.text = @"Disconnected";
                break;
        }
    });
}

- (void)client:(nonnull NXMClient *)client didReceiveError:(nonnull NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectionStatusLabel.text = error.localizedDescription;
        [self.callButton setAlpha:0];
    });
}


@end

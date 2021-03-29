//
//  ViewController.m
//  PhoneToApp
//
//  Created by Abdulhakim Ajetunmobi on 21/08/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

#import "ViewController.h"
#import <NexmoClient/NexmoClient.h>

@interface ViewController () <NXMClientDelegate>
@property UILabel *connectionStatusLabel;
@property NXMClient *client;
@property NXMCall *call;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.connectionStatusLabel = [[UILabel alloc] init];
    self.connectionStatusLabel.text = @"Unknown";
    self.connectionStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.connectionStatusLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.connectionStatusLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.connectionStatusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.connectionStatusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
    
    self.client = NXMClient.shared;
    [self.client setDelegate:self];
    [self.client loginWithAuthToken:@"ALICE_JWT"];
}

- (void)displayIncomingCallAlert:(NXMCall *)call {
    NSString *from = call.otherCallMembers.firstObject.channel.from.data;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incoming call from" message:from preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.call = call;
        [call answer:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [call reject:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)client:(nonnull NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (status) {
            case NXMConnectionStatusConnected:
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
    });
}

- (void)client:(NXMClient *)client didReceiveCall:(NXMCall *)call {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayIncomingCallAlert:call];
    });
}

@end

#import "ViewController.h"
#import "User.h"
#import <NexmoClient/NexmoClient.h>
#import "CallViewController.h"

@interface ViewController () <NXMClientDelegate>
@property UIButton *loginAliceButton;
@property UIButton *loginBobButton;
@property UILabel *statusLabel;
@property NXMClient *client;
@property User *user;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginAliceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginAliceButton setTitle:@"Log in as Alice" forState:UIControlStateNormal];
    self.loginAliceButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loginAliceButton];
    
    self.loginBobButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginBobButton setTitle:@"Log in as Bob" forState:UIControlStateNormal];
    self.loginBobButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loginBobButton];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.loginAliceButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.loginAliceButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loginAliceButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.loginAliceButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        
        [self.loginBobButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loginBobButton.topAnchor constraintEqualToAnchor:self.loginAliceButton.bottomAnchor constant:20.0],
        [self.loginBobButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.loginBobButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.loginBobButton.bottomAnchor constant:20.0],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0]
    ]];
    
    [self.loginAliceButton addTarget:self action:@selector(setUserAsAlice) forControlEvents:UIControlEventTouchUpInside];
    [self.loginBobButton addTarget:self action:@selector(setUserAsBob) forControlEvents:UIControlEventTouchUpInside];
}

- (void)login {
    self.client = NXMClient.shared;
    [self.client setDelegate:self];
    [self.client loginWithAuthToken:self.user.jwt];
}

- (void)setUserAsAlice {
    self.user = User.Alice;
    [self login];
}

- (void)setUserAsBob {
    self.user = User.Bob;
    [self login];
}

- (void)client:(NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (status) {
            case NXMConnectionStatusConnected: {
                self.statusLabel.text = @"Connected";
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[CallViewController alloc] initWithUser:self.user]];
                navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [self presentViewController:navigationController animated:YES completion:nil];
                break;
            }
            case NXMConnectionStatusConnecting:
                self.statusLabel.text = @"Connecting";
                break;
            case NXMConnectionStatusDisconnected:
                self.statusLabel.text = @"Disconnected";
                break;
        }
    });
}

- (void)client:(NXMClient *)client didReceiveError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = error.localizedDescription;
    });
}

- (void)client:(NXMClient *)client didReceiveCall:(NXMCall *)call {
    [NSNotificationCenter.defaultCenter postNotificationName:@"NXMClient.incomingCall" object:call];
}

@end

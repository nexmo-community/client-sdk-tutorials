#import "User.h"
#import "CallViewController.h"
#import <VonageClientSDKVoice/VonageClientSDKVoice.h>

@interface CallViewController () <VGVoiceClientDelegate>
@property UIButton *callButton;
@property UIButton *hangUpButton;
@property UILabel *statusLabel;
@property User *user;
@property VGVoiceClient *client;
@property (nullable) VGVoiceCall *call;
@end

@implementation CallViewController

- (instancetype)initWithUser:(User *)user client:(VGVoiceClient *)client {
    if (self = [super init])
    {
        _user = user;
        _client = client;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    
    self.callButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.callButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.callButton setTitle:[NSString stringWithFormat:@"Call %@", self.user.callPartnerName] forState:UIControlStateNormal];
    [self.callButton addTarget:self action:@selector(makeCall) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.callButton];
    
    self.hangUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.hangUpButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.hangUpButton setTitle:@"Hang up" forState:UIControlStateNormal];
    [self setHangUpButtonHidden:YES];
    [self.hangUpButton addTarget:self action:@selector(endCall) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hangUpButton];
    
    self.statusLabel = [[UILabel alloc] init];
    [self setStatusLabelText:@"Ready to receive call..."];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.callButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.callButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.callButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.callButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        
        [self.hangUpButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.hangUpButton.topAnchor constraintEqualToAnchor:self.callButton.bottomAnchor constant:20.0],
        [self.hangUpButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.hangUpButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.hangUpButton.bottomAnchor constant:20.0],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0]
    ]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout)];
    
    self.client.delegate = self;
    
}

- (void)makeCall {
    [self setStatusLabelText:[NSString stringWithFormat:@"Calling %@", self.user.callPartnerName]];
    
    [self.client serverCall:@{@"callee": self.user.callPartnerName} callback:^(NSError * _Nullable error, VGVoiceCall * _Nullable call) {
        if (error == nil) {
            [self setHangUpButtonHidden:NO];
            self.call = call;
        } else {
            [self setStatusLabelText:error.localizedDescription];
        }
    }];
}

- (void)displayIncomingCallAlert:(VGVoiceInvite *)invite {
    NSString *from = invite.from.id;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incoming call from" message:from preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [invite answer:^(NSError * _Nullable error, VGVoiceCall * _Nullable call) {
            if (error == nil) {
                [self setHangUpButtonHidden:NO];
                [self setStatusLabelText:[NSString stringWithFormat:@"On a call with %@", from]];
                self.call = call;
            } else {
                [self setStatusLabelText:error.localizedDescription];
            }
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [invite reject:^(NSError * _Nullable error) {
            if (error) {
                [self setStatusLabelText:error.localizedDescription];
            }
        }];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)endCall {
    [self.call hangup:^(NSError * _Nullable error) {
        if (error == nil) {
            self.call = nil;
            [self setHangUpButtonHidden:YES];
            [self setStatusLabelText:@"Ready to receive call..."];
        } else {
            [self setStatusLabelText:error.localizedDescription];
        }
    }];
}

- (void)logout {
    [self.client deleteSession:^(NSError * _Nullable error) {
        if (error == nil) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)setHangUpButtonHidden:(BOOL)isHidden {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hangUpButton setHidden:isHidden];
        [self.callButton setHidden:!self.hangUpButton.isHidden];
    });
}

- (void)setStatusLabelText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = text;
    });
}

- (void)voiceClient:(nonnull VGVoiceClient *)client didReceiveInvite:(nonnull VGVoiceInvite *)invite {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayIncomingCallAlert:invite];
    });
}

- (void)voiceClient:(nonnull VGVoiceClient *)client didReceiveHangupForCall:(nonnull VGVoiceCall *)call withLegId:(nonnull NSString *)legId andQuality:(nonnull VGRTCQuality *)callQuality {
    self.call = nil;
    [self setHangUpButtonHidden:YES];
    [self setStatusLabelText:@"Ready to receive call..."];
}


// TODO: should be an enum
- (void)client:(nonnull VGBaseClient *)client didReceiveSessionErrorWithReason:(nonnull NSString *)reason {
    [self setStatusLabelText:reason];
}

@end

#import "ViewController.h"
#import <VonageClientSDKVoice/VonageClientSDKVoice.h>

@interface ViewController () <VGVoiceClientDelegate>
@property UILabel *connectionStatusLabel;
@property VGVoiceClient *client;
@property VGVoiceCall *call;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.connectionStatusLabel = [[UILabel alloc] init];
    self.connectionStatusLabel.text = @"Disconnected";
    self.connectionStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.connectionStatusLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.connectionStatusLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.connectionStatusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.connectionStatusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
    
    VGClientConfig *config = [[VGClientConfig alloc] initWithRegion:VGConfigRegionUS];
    self.client = [[VGVoiceClient alloc] init];
    [self.client setConfig:config];
    self.client.delegate = self;
    
    [self.client createSession:@"ALICE_JWT" sessionId:nil callback:^(NSError * _Nullable error, NSString * _Nullable sessionId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                self.connectionStatusLabel.text = @"Connected";
            } else {
                self.connectionStatusLabel.text = error.localizedDescription;
            }
        });
    }];
}

- (void)displayIncomingCallAlert:(VGVoiceInvite *)invite {
    NSString *from = invite.from.id;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incoming call from" message:from preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [invite answer:^(NSError * _Nullable error, VGVoiceCall * _Nullable call) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil) {
                    self.connectionStatusLabel.text = [NSString stringWithFormat:@"On a call with %@", from];
                    self.call = call;
                } else {
                    self.connectionStatusLabel.text = error.localizedDescription;
                }
            });
        }];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [invite reject:^(NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    self.connectionStatusLabel.text = error.localizedDescription;
                }
            });
        }];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

// MARK: - VGBaseClientDelegate -

// TODO: should be an enum
- (void)client:(nonnull VGBaseClient *)client didReceiveSessionErrorWithReason:(nonnull NSString *)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectionStatusLabel.text = reason;
    });
}

// MARK: - VGVoiceClientDelegate -

- (void)voiceClient:(nonnull VGVoiceClient *)client didReceiveInvite:(nonnull VGVoiceInvite *)invite {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayIncomingCallAlert:invite];
    });
}

- (void)voiceClient:(nonnull VGVoiceClient *)client didReceiveHangupForCall:(nonnull VGVoiceCall *)call withLegId:(nonnull NSString *)legId andQuality:(nonnull VGRTCQuality *)callQuality {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectionStatusLabel.text = @"Connected";
        self.call = nil;
    });
}

@end

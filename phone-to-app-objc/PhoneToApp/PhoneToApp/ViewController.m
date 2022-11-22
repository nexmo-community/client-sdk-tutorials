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
    [self.client createSession:@"ALICE_JWT" sessionId:nil callback:^(NSError * _Nullable, NSString * _Nullable) {
        // TODO: callback params not named
        dispatch_async(dispatch_get_main_queue(), ^{
            self.connectionStatusLabel.text = @"Connected";
        });
    }];
}

- (void)displayIncomingCallAlert:(VGVoiceInvite *)invite {
    // TODO: No caller info
    NSString *from = @"Unknown";

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incoming call from" message:from preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [invite answer:^(NSError * _Nullable, VGVoiceCall * _Nullable) {
            dispatch_async(dispatch_get_main_queue(), ^{
//            if (error == nil) {
                self.connectionStatusLabel.text = [NSString stringWithFormat:@"On a call with %@", from];
//                self.call = call;
//            } else {
//                [self setStatusLabelText:error.localizedDescription];
//            }
            });
        }];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [invite reject:^(NSError * _Nullable) {
            // TODO: callback params not named
//            dispatch_async(dispatch_get_main_queue(), ^{
    //            if (error) {
    //                self.connectionStatusLabel.text = error.localizedDescription;
    //            }
//            });
        }];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}


- (void)voiceClient:(nonnull VGVoiceClient *)client didReceiveInvite:(nonnull VGVoiceInvite *)invite {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayIncomingCallAlert:invite];
    });
}

// TODO: should be an enum
- (void)client:(nonnull VGBaseClient *)client didReceiveSessionErrorWithReason:(nonnull NSString *)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectionStatusLabel.text = reason;
    });
}

// TODO: optional
- (void)clientDidReconnect:(nonnull VGBaseClient *)client {}
- (void)clientWillReconnect:(nonnull VGBaseClient *)client {}
- (void)voiceClient:(nonnull VGVoiceClient *)client didReceiveCallTransferForCall:(nonnull VGVoiceCall *)call withNewConversation:(nonnull VGConversation *)newConversation andPrevConversation:(nonnull VGConversation *)prevConversation {}
- (void)voiceClient:(nonnull VGVoiceClient *)client didReceiveDTMFForCall:(nonnull VGVoiceCall *)call withLegId:(nonnull NSString *)legId andDigits:(nonnull NSString *)digits {}
- (void)voiceClient:(nonnull VGVoiceClient *)client didReceiveEarmuffForCall:(nonnull VGVoiceCall *)call withLegId:(nonnull NSString *)legId andStatus:(Boolean)earmuffStatus {}
- (void)voiceClient:(nonnull VGVoiceClient *)client didReceiveMuteForCall:(nonnull VGVoiceCall *)call withLegId:(nonnull NSString *)legId andStatus:(Boolean)isMuted {}

@end

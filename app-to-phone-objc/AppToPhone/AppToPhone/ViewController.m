#import "ViewController.h"
#import <VonageClientSDKVoice/VonageClientSDKVoice.h>

@interface ViewController ()
@property UIButton *callButton;
@property UILabel *connectionStatusLabel;
@property VGVoiceClient *client;
@property VGVoiceCall * call;
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
    
    VGClientConfig *config = [[VGClientConfig alloc] initWithRegion:VGConfigRegionUS];
    self.client = [[VGVoiceClient alloc] init];
    [self.client setConfig:config];
    [self.client createSession:@"ALICE_JWT" sessionId:nil callback:^(NSError * _Nullable, NSString * _Nullable) {
        // TODO: callback params not named
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.callButton setAlpha:1];
            self.connectionStatusLabel.text = @"Connected";
        });
    }];
}

- (void)callButtonPressed {
    if (!self.call) {
        [self placeCall];
    } else {
        [self endCall];
    }
}

- (void)placeCall {
    [self.client serverCall:@{@"callee": @"PHONE_NUMBER"} callback:^(NSError * _Nullable error, VGVoiceCall * _Nullable call) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                self.call = call;
                [self.callButton setTitle:@"End call" forState:UIControlStateNormal];
            } else {
                self.connectionStatusLabel.text = error.localizedDescription;
            }
        });
    }];
}

- (void)endCall {
    // TODO: callback params not named
    [self.call hangup:^(NSError * _Nullable) {
        self.call = nil;
        [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
    }];
}

@end

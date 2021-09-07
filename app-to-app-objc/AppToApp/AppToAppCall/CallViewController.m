#import "User.h"
#import "CallViewController.h"
#import <NexmoClient/NexmoClient.h>

@interface CallViewController () <NXMCallDelegate>
@property UIButton *callButton;
@property UIButton *hangUpButton;
@property UILabel *statusLabel;
@property User *user;
@property NXMClient *client;
@property (nullable) NXMCall *call;
@end

@implementation CallViewController

- (instancetype)initWithUser:(User *)user {
    if (self = [super init])
    {
        _user = user;
        _client = NXMClient.shared;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    
    self.callButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.callButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.callButton];
    
    self.hangUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.hangUpButton setTitle:@"Hang up" forState:UIControlStateNormal];
    self.hangUpButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self setHangUpButtonHidden:YES];
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
    [self.callButton setTitle:[NSString stringWithFormat:@"Call %@", self.user.callPartnerName] forState:UIControlStateNormal];
    
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didReceiveCall:) name:@"NXMClient.incomingCall" object:nil];
    
    [self.hangUpButton addTarget:self action:@selector(endCall) forControlEvents:UIControlEventTouchUpInside];
    [self.callButton addTarget:self action:@selector(makeCall) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeCall {
    [self setStatusLabelText:[NSString stringWithFormat:@"Calling %@", self.user.callPartnerName]];
    
    [self.client serverCallWithCallee:self.user.callPartnerName customData:nil completionHandler:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        if (error) {
            [self setStatusLabelText:error.localizedDescription];
            return;
        }
        
        [call setDelegate:self];
        [self setHangUpButtonHidden:NO];
        self.call = call;
    }];
}

- (void)didReceiveCall:(NSNotification *)notification {
    NXMCall *call = (NXMCall *)notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayIncomingCallAlert:call];
    });
}

- (void)displayIncomingCallAlert:(NXMCall *)call {
    NSString *from = call.myMember.channel.from.data;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incoming call from" message:from preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.call = call;
        [self setHangUpButtonHidden:NO];
        [self setStatusLabelText:[NSString stringWithFormat:@"On a call with %@", from]];
        [call answer:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [call reject:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)endCall {
    [self.call hangup];
    [self setHangUpButtonHidden:YES];
    [self setStatusLabelText:@"Ready to receive call..."];
}

- (void)logout {
    [self.client logout];
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)call:(NXMCall *)call didUpdate:(NXMMember *)callMember withStatus:(NXMCallMemberStatus)status {
    switch (status) {
        case NXMCallMemberStatusAnswered:
            if (![callMember.user.name isEqualToString:self.user.name]) {
                [self setStatusLabelText:[NSString stringWithFormat:@"On a call with %@", callMember.user.name]];
            }
            break;
        case NXMCallMemberStatusCompleted:
            [self setStatusLabelText:@"Call ended"];
            [self setHangUpButtonHidden:YES];
            self.call = nil;
            break;
        default:
            break;
    }
}

- (void)call:(NXMCall *)call didReceive:(NSError *)error {
    [self setStatusLabelText:error.localizedDescription];
}

- (void)call:(NXMCall *)call didUpdate:(NXMMember *)callMember isMuted:(BOOL)muted {}

@end

//
//  ChatViewController.m
//  AppToAppChat
//
//  Created by Abdulhakim Ajetunmobi on 24/07/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

#import "ChatViewController.h"
#import "User.h"
#import <NexmoClient/NexmoClient.h>

@interface ChatViewController () <UITextFieldDelegate, NXMConversationDelegate>
@property UITextView *conversationTextView;
@property UITextField *inputField;
@property User *user;
@property NXMClient *client;
@property NXMConversation *conversation;
@property NSMutableArray<NXMEvent *> *events;
@end

@implementation ChatViewController

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
    
    self.conversationTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.conversationTextView.text = @"";
    self.conversationTextView.backgroundColor = UIColor.lightGrayColor;
    [self.conversationTextView setUserInteractionEnabled:NO];
    self.conversationTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.conversationTextView];
    
    self.inputField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.inputField.delegate = self;
    self.inputField.returnKeyType = UIReturnKeySend;
    self.inputField.layer.borderWidth = 1.0;
    self.inputField.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.inputField.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:self.inputField];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.conversationTextView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.conversationTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.conversationTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.conversationTextView.bottomAnchor constraintEqualToAnchor:self.inputField.topAnchor constant:-20.0],

        [self.inputField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.inputField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        [self.inputField.heightAnchor constraintEqualToConstant:40.0],
        [self.inputField.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor constant:-20.0]
    ]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout)];
    self.title = [NSString stringWithFormat:@"Conversation with %@", self.user.chatPartnerName];

    [self getConversation];
}

- (void)getConversation {
    [self.client getConversationWithUuid:self.user.conversationId completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
        self.conversation = conversation;
        if (conversation) {
            [self getEvents];
        }
        conversation.delegate = self;
    }];
}

- (void)getEvents {
    if (self.conversation) {
        [self.conversation getEventsPageWithSize:100 order:NXMPageOrderAsc completionHandler:^(NSError * _Nullable error, NXMEventsPage * _Nullable events) {
            self.events = [NSMutableArray arrayWithArray:events.events];
            [self processEvents];
        }];
    }
}

- (void)processEvents {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.conversationTextView.text = @"";
        for (NXMEvent *event in self.events) {
            if ([event isMemberOfClass:[NXMMemberEvent class]]) {
                [self showMemberEvent:(NXMMemberEvent *)event];
            } else if ([event isMemberOfClass:[NXMMessageEvent class]]) {
                [self showTextEvent:(NXMMessageEvent *)event];
            }
        }
    });
}

- (void)showMemberEvent:(NXMMemberEvent *)event {
    switch (event.state) {
        case NXMMemberStateInvited:
            [self addConversationLine:[NSString stringWithFormat:@"%@ was invited", event.embeddedInfo.user.name]];
            break;
        case NXMMemberStateJoined:
            [self addConversationLine:[NSString stringWithFormat:@"%@ joined", event.embeddedInfo.user.name]];
            break;
        case NXMMemberStateLeft:
            [self addConversationLine:[NSString stringWithFormat:@"%@ left", event.embeddedInfo.user.name]];
            break;
        case NXMMemberStateUnknown:
            [NSException raise:@"UnknownMemberState" format:@"Member state is unknown"];
            break;
    }
}

- (void)showTextEvent:(NXMMessageEvent *)event {
    NSString *message = [NSString stringWithFormat:@"%@ said %@", event.embeddedInfo.user.name, event.text];
    [self addConversationLine:message];
}

- (void)addConversationLine:(NSString *)line {
    NSString *currentText = self.conversationTextView.text;
    
    if (currentText.length > 0) {
        self.conversationTextView.text = [NSString stringWithFormat:@"%@\n%@", currentText, line];
    } else {
        self.conversationTextView.text = line;
    }
}

- (void)sendMessage:(NSString *)message {
    [self.inputField setUserInteractionEnabled:NO];
    [self.conversation sendMessage: [[NXMMessage alloc] initWithText:message] completionHandler:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.inputField setUserInteractionEnabled:YES];
        });
    }];
}

- (void)logout {
    [self.client logout];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary *keyboardInfo = notification.userInfo;
    
    if (keyboardInfo) {
        CGSize kbSize = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        self.view.layoutMargins = UIEdgeInsetsMake(0, 0, kbSize.height - 20.0, 0);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.view.layoutMargins = UIEdgeInsetsZero;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *text = self.inputField.text;
    
    if (text) {
        [self sendMessage:text];
    }
    self.inputField.text = @"";
    [self.inputField resignFirstResponder];
    return YES;
}

- (void)conversation:(NXMConversation *)conversation didReceiveMessageEvent:(NXMMessageEvent *)event {
    [self.events addObject:event];
    [self processEvents];
}

- (void)conversation:(NXMConversation *)conversation didReceiveMemberEvent:(NXMMemberEvent *)event {
    [self.events addObject:event];
    [self processEvents];
}

- (void)conversation:(NXMConversation *)conversation didReceive:(NSError *)error {
    NSLog(@"Conversation error: %@", error.localizedDescription);
}

@end

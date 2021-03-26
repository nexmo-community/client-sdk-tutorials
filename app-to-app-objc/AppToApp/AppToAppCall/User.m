//
//  User.m
//  AppToAppChat
//
//  Created by Abdulhakim Ajetunmobi on 24/07/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithName:(NSString *)name jwt:(NSString *)jwt callPartnerName:(NSString *)callPartnerName {
    if (self = [super init])
    {
        _name = name;
        _jwt = jwt;
        _callPartnerName = callPartnerName;
    }
    return self;
}

+ (instancetype)Alice {
    return [[User alloc] initWithName:@"Alice" jwt:@"ALICE_JWT" callPartnerName:@"Bob"];
}

+ (instancetype)Bob {
    return [[User alloc] initWithName:@"Bob" jwt:@"BOB_JWT" callPartnerName:@"Alice"];
}

@end

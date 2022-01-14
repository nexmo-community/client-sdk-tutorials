//
//  User.h
//  AppToAppChat
//
//  Created by Abdulhakim Ajetunmobi on 24/07/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property NSString *name;
@property NSString *jwt;
@property NSString *chatPartnerName;
@property NSString *conversationId;

-(instancetype)initWithName:(NSString *)name jwt:(NSString *)jwt chatPartnerName:(NSString *)chatPartnerName;

+(instancetype)Alice;
+(instancetype)Bob;

@end

NS_ASSUME_NONNULL_END

//
//  ChatViewController.h
//  AppToAppChat
//
//  Created by Abdulhakim Ajetunmobi on 24/07/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : UIViewController

-(instancetype)initWithUser:(User *)user;

@end

NS_ASSUME_NONNULL_END

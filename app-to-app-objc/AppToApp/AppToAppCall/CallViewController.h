//
//  CallViewController.h
//  AppToAppCall
//
//  Created by Abdulhakim Ajetunmobi on 25/08/2020.
//  Copyright © 2020 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface CallViewController : UIViewController

-(instancetype)initWithUser:(User *)user;

@end

NS_ASSUME_NONNULL_END

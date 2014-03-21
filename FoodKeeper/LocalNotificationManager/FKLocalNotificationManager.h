//
//  FKLocalNotificationManager.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/21/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKLocalNotificationManager : NSObject

+ (FKLocalNotificationManager *)sharedInstance;

- (void)updateNotifications;

@end

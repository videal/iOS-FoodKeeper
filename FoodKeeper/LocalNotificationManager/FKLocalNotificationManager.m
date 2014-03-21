//
//  FKLocalNotificationManager.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/21/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "FKLocalNotificationManager.h"
#import "FKDataManager.h"

#define kLimitNotification 3

#pragma mark -

@implementation FKLocalNotificationManager

+ (FKLocalNotificationManager *)sharedInstance{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedInstance = [self new]; });
    
    return _sharedInstance;
}

#pragma mark -

- (void)cancelAllNotifications {
    UIApplication *app = [UIApplication sharedApplication];
    
    NSArray *oldNotifications = [app scheduledLocalNotifications];
    
    for (UILocalNotification *notification in oldNotifications) {
        [app cancelLocalNotification:notification];
    }
}

- (void)createLocalNotificationWithBody:(NSString *)body date:(NSDate *)date {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.timeZone    = [NSTimeZone systemTimeZone];
    notification.fireDate    = date;
    notification.alertAction = @"Expiry date";
    notification.alertBody   = body;
    notification.soundName   = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)updateNotifications {
    NSArray *notifications = [[FKDataManager sharedInstance] allProductsWithBestBeforeDay:kLimitNotification];
    
    if (notifications.count == 0) {
        return;
    }
    
    [self cancelAllNotifications];
    
    for (NSArray *products in notifications) {
        NSMutableString *body = [NSMutableString new];
        
        Product *product = [products firstObject];
        
        if (products.count == 1) {
            [body appendFormat:@"Expiry date of product \"%@\" will expire tomorrow", product.productDescription.name];
        } else {
            [body appendFormat:@"Expiry date of product \"%@\" and %d others will expire tomorrow", product.productDescription.name, products.count];
        }
        
        NSDate *dateBeforeExpireDay = [product.expireDate addedDays:-1];
        [self createLocalNotificationWithBody:body date:[dateBeforeExpireDay beginningOfDay]];
    }
}

@end

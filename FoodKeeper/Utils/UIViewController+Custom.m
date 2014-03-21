//
//  UIViewController+Custom.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "UIViewController+Custom.h"

@implementation UIViewController (Custom)

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        UINavigationController *navController = self.navigationController;
        
        if ([navController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
            [navController.navigationBar setBarTintColor:kBrandTintColor];
        } else if ([navController.navigationBar respondsToSelector:@selector(setTintColor:)]) {
            [navController.navigationBar setTintColor:kBrandTintColor];
        }
    }
    
    self.navigationController.navigationBar.translucent = NO;
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

@end

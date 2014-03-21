//
//  FKNavigationController.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/20/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "FKNavigationController.h"

@interface FKNavigationController ()

@end

@implementation FKNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {        
        if ([self.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
            [self.navigationBar setBarTintColor:kBrandTintColor];
        } else if ([self.navigationBar respondsToSelector:@selector(setTintColor:)]) {
            [self.navigationBar setTintColor:kBrandTintColor];
        }
    }
    
    self.navigationController.navigationBar.translucent = NO;
}

@end

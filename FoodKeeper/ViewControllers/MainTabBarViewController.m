//
//  MainTabBarViewController.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UINavigationController *viewController in self.viewControllers) {
        if ([viewController.restorationIdentifier isEqualToString:@"FridgeNavController"]) {
            self.fridgeNavController = viewController;
        } else if ([viewController.restorationIdentifier isEqualToString:@"CupboardNavController"]) {
            self.cupboardNavController = viewController;
        } else if ([viewController.restorationIdentifier isEqualToString:@"BasketNavController"]) {
            self.basketNavController = viewController;
        }
    }
}

@end

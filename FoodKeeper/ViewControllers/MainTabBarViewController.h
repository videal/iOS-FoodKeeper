//
//  MainTabBarViewController.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//



@interface MainTabBarViewController : UITabBarController

@property (weak, nonatomic) UINavigationController *fridgeNavController;
@property (weak, nonatomic) UINavigationController *cupboardNavController;
@property (weak, nonatomic) UINavigationController *basketNavController;

@end

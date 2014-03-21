//
//  MenuTableViewCellRowModel.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuTableViewCellRowModel : NSObject

@property (readonly, strong, nonatomic) NSString *icon;
@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic) UIViewController *controller;

- (instancetype)initWithTitle:(NSString *)aTitle icon:(NSString *)aIcon controller:(UINavigationController *)aController;

@end

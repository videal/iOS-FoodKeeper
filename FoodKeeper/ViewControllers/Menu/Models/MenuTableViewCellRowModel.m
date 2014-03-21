//
//  MenuTableViewCellRowModel.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "MenuTableViewCellRowModel.h"

@implementation MenuTableViewCellRowModel

- (instancetype)initWithTitle:(NSString *)aTitle icon:(NSString *)aIcon controller:(UINavigationController *)aController {
    self = [super init];
    
    if (self) {
        _title = aTitle;
        _icon = aIcon;
        _controller = aController;
    }
    
    return self;
}

@end

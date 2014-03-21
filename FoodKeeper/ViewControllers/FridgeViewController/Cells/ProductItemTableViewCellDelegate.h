//
//  ProductItemTableViewCellDelegate.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/20/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProductItemTableViewCellDelegate <NSObject>

- (void)productItemTableViewCellDidChangeQuantity:(UITableViewCell *)cell quantityDiff:(NSInteger)quantityDiff;

@end

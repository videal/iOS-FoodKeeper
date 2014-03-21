//
//  AddFoodViewController.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FKDataManager.h"

@interface AddFoodViewController : UIViewController

@property (assign, nonatomic) ProductStorageType storageType;
@property (strong, nonatomic) Product *product;

@end

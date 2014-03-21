//
//  FridgeViewController.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKDataManager.h"

@interface FridgeViewController : UIViewController <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UISearchBar *contentSearchBar;

@property (strong, nonatomic) NSArray *dataSource;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (assign, nonatomic) ProductStorageType storageType;

- (UITableViewCell *)cellForStorage;

@end

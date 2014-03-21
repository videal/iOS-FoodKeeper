//
//  CupboardViewController.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "CupboardViewController.h"

#import "SidePanelController.h"
#import <JASidePanels/UIViewController+JASidePanel.h>
#import "CupboardItemTableViewCell.h"
#import "FKDataManager.h"

@interface CupboardViewController ()

@end

#pragma mark -

@implementation CupboardViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.storageType = ProductStorageTypeCupboard;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Main Menu Button
    self.navigationItem.title = @"Cupboard";
    
    self.contentTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cupboard_bgr2"]];
    
    NSString *fileName = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? @"navigation_bar1_2" : @"navigation_bar";
    UIImage *image = [UIImage imageNamed:fileName];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.contentSearchBar.tintColor = [UIColor blackColor];
    } else {
        self.contentSearchBar.backgroundImage = image;
    }
}

- (UITableViewCell *)cellForStorage {
    return [self.contentTableView dequeueReusableCellWithIdentifier:NSStringFromClass([CupboardItemTableViewCell class])];
}


@end

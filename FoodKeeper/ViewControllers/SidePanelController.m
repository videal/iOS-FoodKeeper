//
//  SidePanelController.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "SidePanelController.h"
#import "AddFoodViewController.h"
#import "MainTabBarViewController.h"
#import "FridgeViewController.h"
#import "CupboardViewController.h"
#import "ShoppingBascketViewController.h"
#import "FKNavigationController.h"

@interface SidePanelController ()

@end

#pragma mark -

@implementation SidePanelController

- (void) awakeFromNib {
    [super awakeFromNib];
        
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"Menu"]];
    [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

+ (UIImage *)defaultImage {
	static UIImage *defaultImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 13.f), NO, 0.0f);
				
		[[UIColor whiteColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 1, 20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 6,  20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 11, 20, 2)] fill];
		
		defaultImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        
	});
    return defaultImage;
}

- (UIBarButtonItem *)rightButtonForCenterPanel {
    
    UIButton *addFoodItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addFoodItemButton.frame = CGRectMake(0, 6, 24, 24);
    [addFoodItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addFoodItemButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [addFoodItemButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [addFoodItemButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:addFoodItemButton];
}

- (UIBarButtonItem *)leftButtonForCenterPanel {
    UIButton *addFoodItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addFoodItemButton.frame = CGRectMake(0, 6, 24, 24);
    [addFoodItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addFoodItemButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [addFoodItemButton setImage:[[self class] defaultImage] forState:UIControlStateNormal];
    [addFoodItemButton addTarget:self action:@selector(toggleLeftPanel:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:addFoodItemButton];
}

- (void)toggleLeftPanel:(__unused id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationToggleLeftPanel object:nil];
    
    [super toggleLeftPanel:sender];
}

- (void)addButtonClicked:(id)sender {
    MainTabBarViewController *mainTabBarViewController = (MainTabBarViewController *)self.centerPanel;
    ProductStorageType storageType = ProductStorageTypeFridge;
    
    if ([mainTabBarViewController.selectedViewController isEqual:mainTabBarViewController.cupboardNavController]) {
        storageType = ProductStorageTypeCupboard;
    }
    
    [self showAddProductViewWithProduct:nil storageType:storageType];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)styleContainer:(UIView *)container animate:(BOOL)animate duration:(NSTimeInterval)duration {
    // Overridden to get rid of Shadow
}

- (void)stylePanel:(UIView *)panel {
    // Overridden to get rid of rounded corners of center panel
    panel.clipsToBounds = YES;
}

- (void)showAddProductViewWithProduct:(Product *)product storageType:(ProductStorageType)storageType {
    AddFoodViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddFoodViewController"];
    vc.product = product;
    vc.storageType = storageType;
    
    FKNavigationController *navController = [[FKNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

@end

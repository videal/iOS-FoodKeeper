//
//  CategoryPickerViewController.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryPickerViewController;

@protocol CategoryPickerViewControllerDelegate <NSObject>

- (void)dismissCategoryPicker:(CategoryPickerViewController *)categoryPickerViewController categoryName:(NSString *)categoryName;

@end

@interface CategoryPickerViewController : UITableViewController

@property (weak, nonatomic) id<CategoryPickerViewControllerDelegate> delegate;

@end

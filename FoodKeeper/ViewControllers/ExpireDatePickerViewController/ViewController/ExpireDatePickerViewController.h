//
//  ExpireDatePickerViewController.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExpireDatePickerViewController;

@protocol ExpireDatePickerViewControllerDelegate <NSObject>

- (void)dismissExpireDatePicker:(ExpireDatePickerViewController *)expireDatePickerController expireDate:(NSDate *)expireDate;

@end

@interface ExpireDatePickerViewController : UIViewController

@property (weak, nonatomic) id<ExpireDatePickerViewControllerDelegate> delegate;

@property (strong, nonatomic) NSDate *expireDate;

@end

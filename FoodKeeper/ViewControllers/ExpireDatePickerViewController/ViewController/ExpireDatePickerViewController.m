//
//  ExpireDatePickerViewController.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "ExpireDatePickerViewController.h"
#import <FXBlurView.h>
#import <QuartzCore/QuartzCore.h>

@interface ExpireDatePickerViewController ()

@property (weak, nonatomic) IBOutlet FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIView *panelView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)dateValueChanged:(UIDatePicker *)sender;

@end

#pragma mark -

@implementation ExpireDatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.doneButton.layer.cornerRadius = 6.0;
    
    self.blurView.dynamic = NO;
    self.blurView.blurRadius = 30.0;
    self.blurView.tintColor = [UIColor blackColor];
    
    self.panelView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.panelView.layer.shadowOffset = CGSizeMake(0, 0);
    self.panelView.layer.shadowOpacity = 0.1;
    self.panelView.layer.shadowRadius = 6.0;
    self.panelView.clipsToBounds = NO;
    
    if (!self.expireDate) {
        self.expireDate = [NSDate date];
    }
    
    self.datePicker.minimumDate = [NSDate date];
    self.datePicker.date = self.expireDate;
}

#pragma mark - Actions

- (IBAction)doneButtonClicked:(id)sender {
    [self.delegate dismissExpireDatePicker:self expireDate:self.expireDate];
}

- (IBAction)dateValueChanged:(UIDatePicker *)sender {
    self.expireDate = sender.date;
}

@end

//
//  CupboardItemTableViewCell.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "CupboardItemTableViewCell.h"

@interface CupboardItemTableViewCell ()

- (IBAction)quantityIncreaseButtonClicked:(id)sender;
- (IBAction)quantityDecreaseButtonClicked:(id)sender;

@end

@implementation CupboardItemTableViewCell

- (IBAction)quantityIncreaseButtonClicked:(id)sender {
    [self.delegate productItemTableViewCellDidChangeQuantity:self quantityDiff:1];
}

- (IBAction)quantityDecreaseButtonClicked:(id)sender {
    [self.delegate productItemTableViewCellDidChangeQuantity:self quantityDiff:-1];
}

@end

//
//  ShoppingBasketItemTableViewCell.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/17/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingBasketItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coloredImageView;

@end

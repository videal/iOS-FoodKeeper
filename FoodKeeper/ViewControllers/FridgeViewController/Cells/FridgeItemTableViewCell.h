//
//  FridgeItemTableViewCell.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductItemTableViewCellDelegate.h"

@interface FridgeItemTableViewCell : UITableViewCell

@property (weak, nonatomic) id<ProductItemTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *expireDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coloredImageView;

@end

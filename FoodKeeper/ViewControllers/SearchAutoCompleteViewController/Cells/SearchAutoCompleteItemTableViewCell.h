//
//  SearchAutoCompleteItemTableViewCell.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchAutoCompleteItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;

@end

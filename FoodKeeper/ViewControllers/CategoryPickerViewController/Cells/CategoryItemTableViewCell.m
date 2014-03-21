//
//  CategoryItemTableViewCell.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "CategoryItemTableViewCell.h"

@implementation CategoryItemTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

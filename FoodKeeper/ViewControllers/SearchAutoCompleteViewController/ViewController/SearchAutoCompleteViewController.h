//
//  SearchAutoCompleteViewController.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKDataManager.h"

@class SearchAutoCompleteViewController;
@class ProductDescription;

@protocol SearchAutoCompleteViewControllerDelegate <NSObject>

- (void)searchAutoCompleteViewControllerDidSelectedProductDescription:(SearchAutoCompleteViewController *)searchAutoCompleteViewController productDescription:(ProductDescription *)productDescription;

@end

@interface SearchAutoCompleteViewController : UIViewController

@property (weak, nonatomic) id<SearchAutoCompleteViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITableView *contentTableView;

@property (strong, nonatomic) NSString *searchKey;
@property (assign, nonatomic) SearchType searchType;

- (void)reloadContentWithSearchKey:(NSString *)searchKey;

@end

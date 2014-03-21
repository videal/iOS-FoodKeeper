//
//  SearchAutoCompleteViewController.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "SearchAutoCompleteViewController.h"
#import "SearchAutoCompleteItemTableViewCell.h"
#import "FKDataManager.h"

@interface SearchAutoCompleteViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation SearchAutoCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0, 0);
    self.view.layer.shadowOpacity = 0.4;
    self.view.layer.shadowRadius = 6.0;
    self.view.clipsToBounds = NO;
    
    self.view.alpha = 0.0;
    
    [self loadContent];
}

- (void)loadContent {
    self.dataSource = @[];
    
    if (self.searchType == SearchTypeName) {
        self.dataSource = [[FKDataManager sharedInstance] allProductDescriptionsWithKeyword:self.searchKey searchType:SearchTypeName];
    } else if (self.searchType == SearchTypeBarcode) {
        self.dataSource = [[FKDataManager sharedInstance] allProductDescriptionsWithKeyword:self.searchKey searchType:SearchTypeBarcode];
    }
    
    self.view.hidden = self.dataSource.count == 0;
    [self.contentTableView reloadData];
}

- (void)reloadContentWithSearchKey:(NSString *)searchKey {
    self.searchKey = searchKey;
    
    [self loadContent];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchAutoCompleteItemTableViewCell *cell = (SearchAutoCompleteItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SearchAutoCompleteItemTableViewCell class])];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductDescription *productDesc = self.dataSource[indexPath.row];
    [self.delegate searchAutoCompleteViewControllerDidSelectedProductDescription:self productDescription:productDesc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchAutoCompleteItemTableViewCell *cell = (SearchAutoCompleteItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SearchAutoCompleteItemTableViewCell class])];
    
    ProductDescription *productDescription = self.dataSource[indexPath.row];
    cell.nameLabel.text = productDescription.name;
    cell.barcodeLabel.text = productDescription.barcode;
    
    return cell;
}

@end

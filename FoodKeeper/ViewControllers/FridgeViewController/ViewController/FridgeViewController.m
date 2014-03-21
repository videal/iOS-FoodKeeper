//
//  FridgeViewController.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "FridgeViewController.h"
#import "ProductDescription.h"

#import "SidePanelController.h"
#import <JASidePanels/UIViewController+JASidePanel.h>
#import "FridgeItemTableViewCell.h"
#import "FKDataManager.h"

@interface FridgeViewController () <ProductItemTableViewCellDelegate>

@end

#pragma mark -

@implementation FridgeViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.storageType = ProductStorageTypeFridge;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"yyyy.MM.dd"
                                                             options:0
                                                              locale:[NSLocale currentLocale]];
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:formatString];
    
    // Main Menu Button
    SidePanelController *sidePanelController = (SidePanelController *)self.sidePanelController;
    self.navigationItem.title = @"Fridge";
    self.navigationItem.leftBarButtonItem = sidePanelController.leftButtonForCenterPanel;
    self.navigationItem.rightBarButtonItem = [sidePanelController rightButtonForCenterPanel];
    
    self.contentTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fridge_bgr"]];
    
    NSString *fileName = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? @"navigation_bar2_2" : @"navigation_bar2";
    UIImage *image = [UIImage imageNamed:fileName];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.contentSearchBar.tintColor = [UIColor blackColor];
    } else {
        self.contentSearchBar.backgroundImage = image;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleLeftPanel:) name:kNotificationToggleLeftPanel object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Load content
    [self loadContent];
}

- (void)loadContent {
    FKDataManager *dataManager = [FKDataManager sharedInstance];
    self.dataSource = [dataManager productsInStorage:(self.storageType == ProductStorageTypeCupboard ? CUPBOARD : FRIDGE)
                                           keyword:[self.contentSearchBar.text lowercaseString]];
    
    self.emptyView.hidden = (self.dataSource.count != 0);
    
    [self.contentTableView reloadData];
}

- (UITableViewCell *)cellForStorage {
    return [self.contentTableView dequeueReusableCellWithIdentifier:NSStringFromClass([FridgeItemTableViewCell class])];
}

#pragma mark - Notifications

- (void)toggleLeftPanel:(NSNotification *)notification {
    [self.contentSearchBar resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect frame = self.contentTableView.frame;
    self.contentTableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 372 - kbSize.height);
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    CGRect frame = self.contentTableView.frame;
    self.contentTableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 372);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self cellForStorage];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FridgeItemTableViewCell *cell = (FridgeItemTableViewCell *)[self cellForStorage];
    cell.delegate = self;
    
    Product *product = self.dataSource[indexPath.row];
    
    cell.nameLabel.text = product.productDescription.name;
    cell.categoryLabel.text = product.productDescription.category;
    cell.expireDateLabel.text = [self.dateFormatter stringFromDate:product.expireDate];
    cell.quantityLabel.text = [NSString stringWithFormat:@"%@", product.quantity];
    
    NSDate *dateAfterOneDay = [[NSDate date] addedDays:1];
    NSDate *dateAfterThreeDay = [[NSDate date] addedDays:3];
    NSDate *endOfAfterThreeDay = [dateAfterThreeDay endOfDay];
    NSDate *endOfAfterOneDay = [dateAfterOneDay endOfDay];
    
    BOOL isExpiredAfterOneDay = [product.expireDate timeIntervalSinceDate:endOfAfterOneDay] <= 0;
    BOOL isExpiredAfterTreeDay = [product.expireDate timeIntervalSinceDate:endOfAfterThreeDay] <= 0;
    
    UIColor *color = nil;
        
    if (isExpiredAfterOneDay) {
        color = kTableViewCellRedColor;
    } else if (isExpiredAfterTreeDay) {
        color = kTableViewCellYellowColor;
    } else {
        color = kTableViewCellGreenColor;
    }
    
    cell.coloredImageView.backgroundColor = color;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Product *product = self.dataSource[indexPath.row];
        [[FKDataManager sharedInstance] changeProductQuantity:product quantity:@(-[product.quantity intValue])];
        [self loadContent];
    }
}

#pragma mark - ProductItemTableViewCellDelegate

- (void)productItemTableViewCellDidChangeQuantity:(UITableViewCell *)cell quantityDiff:(NSInteger)quantityDiff {
    NSIndexPath *indexPath = [self.contentTableView indexPathForCell:cell];
    
    Product *product = self.dataSource[indexPath.row];
    [[FKDataManager sharedInstance] changeProductQuantity:product quantity:@(quantityDiff)];
    
    ((FridgeItemTableViewCell *)cell).quantityLabel.text = [NSString stringWithFormat:@"%@", product.quantity];
    
    if ([product.quantity intValue] == 0) {
        [self loadContent];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self loadContent];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self loadContent];
}

@end

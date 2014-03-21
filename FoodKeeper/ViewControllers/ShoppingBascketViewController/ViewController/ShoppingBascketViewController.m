//
//  ShoppingBascketViewController.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "ShoppingBascketViewController.h"

#import "SidePanelController.h"
#import <JASidePanels/UIViewController+JASidePanel.h>
#import "ShoppingBasketItemTableViewCell.h"
#import "FKNavigationController.h"
#import "AddFoodViewController.h"

@interface ShoppingBascketViewController () <UISearchBarDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UISearchBar *contentSearchBar;

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) Product *productForDelete;

@end

#pragma mark -

@implementation ShoppingBascketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Main Menu Button
    SidePanelController *sidePanelController = (SidePanelController *)self.sidePanelController;
    self.navigationItem.title = @"Shopping Bascket";
    self.navigationItem.leftBarButtonItem = sidePanelController.leftButtonForCenterPanel;
    self.navigationItem.rightBarButtonItem = [sidePanelController rightButtonForCenterPanel];
    
    self.contentSearchBar.backgroundColor = RGB(0, 175, 255);
    
    if ([self.contentSearchBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.contentSearchBar.barTintColor = RGB(0, 175, 255);
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.contentSearchBar.tintColor = [UIColor blackColor];
    } else {
        self.contentSearchBar.backgroundImage = [UIImage imageNamed:@"shopping_basket_search_bar_bgr"];
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
    self.dataSource = [dataManager allProductsInCartWithKeyword:self.contentSearchBar.text];
    
    self.contentTableView.hidden = (self.dataSource.count == 0);
    self.emptyView.hidden = (self.dataSource.count != 0);
    
    [self.contentTableView reloadData];
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
    Product *product = self.dataSource[indexPath.row];
    NSDate *endOfDay = [[NSDate date] endOfDay];
    BOOL isExpired = ([product.expireDate timeIntervalSinceDate:endOfDay] <= 0) || ([product.quantity intValue] == 0);
    
    return isExpired ? 48 : 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShoppingBasketItemTableViewCell *cell = (ShoppingBasketItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ShoppingBasketItemTableViewCell class])];
    
    Product *product = self.dataSource[indexPath.row];
    
    cell.nameLabel.text = product.productDescription.name;
    cell.categoryLabel.text = product.productDescription.category;
    cell.quantityLabel.text = [NSString stringWithFormat:@"%@", product.quantity];

    NSDate *endOfDay = [[NSDate date] endOfDay];
    BOOL isExpired = [product.expireDate timeIntervalSinceDate:endOfDay] <= 0 || [product.quantity intValue] == 0;
    UIColor *color = nil;
    
    if (isExpired) {
        color = kTableViewCellRedColor;
    } else {
        color = kTableViewCellYellowColor;
    }
    
    cell.coloredImageView.backgroundColor = color;
    
    cell.quantityLabel.hidden = isExpired;
    cell.quantityTitleLabel.hidden = isExpired;
        
    cell.coloredImageView.frame = CGRectMake(0, 0, 8, (isExpired ? 48 : 70) - 1);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Product *product = self.dataSource[indexPath.row];
    
    [(SidePanelController *)self.sidePanelController showAddProductViewWithProduct:product storageType:ProductStorageTypeFridge];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.productForDelete = self.dataSource[indexPath.row];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you really want to delete this product?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        av.tag = 1;
        [av show];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1 && buttonIndex == 1) {
        [[FKDataManager sharedInstance] deleteProduct:self.productForDelete];
        [self loadContent];
    }
    
    self.productForDelete = nil;
}

@end

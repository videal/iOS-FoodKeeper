//
//  MenuViewController.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "MenuViewController.h"
#import "SidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "MenuHeaderCell.h"
#import "MenuCell.h"
#import "MainTabBarViewController.h"
#import "MenuTableViewCellRowModel.h"

#define kMenuHeaderCellIdentifier @"MenuHeaderCell"
#define kMenuCellIdentifier @"MenuCell"

@interface MenuViewController ()

@property (strong, nonatomic) NSArray *dataSource;

@end

#pragma mark -

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MenuHeaderCell *tableHeaderView = (MenuHeaderCell *)[self.tableView dequeueReusableCellWithIdentifier:kMenuHeaderCellIdentifier];
    tableHeaderView.textLabel.text = @"Food Keeper";
    self.tableView.tableHeaderView = tableHeaderView;
    
    MainTabBarViewController *mainTabBarViewController = (MainTabBarViewController *) self.sidePanelController.centerPanel;
    
    self.dataSource = @[
                        [[MenuTableViewCellRowModel alloc] initWithTitle:@"Fridge" icon:@"fridge" controller:mainTabBarViewController.fridgeNavController],
                        [[MenuTableViewCellRowModel alloc] initWithTitle:@"Cupboard" icon:@"cupboard" controller:mainTabBarViewController.cupboardNavController],
                        [[MenuTableViewCellRowModel alloc] initWithTitle:@"Shopping Bascket" icon:@"basket" controller:mainTabBarViewController.basketNavController]
                        ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Default selected row = 0
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier:kMenuCellIdentifier];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier:kMenuCellIdentifier forIndexPath:indexPath];
    
    MenuTableViewCellRowModel *rowModel = self.dataSource[indexPath.row];
    
    cell.icon.image = [UIImage imageNamed:rowModel.icon];
    cell.titleLabel.text = rowModel.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuTableViewCellRowModel *rowModel = self.dataSource[indexPath.row];
    MainTabBarViewController *mainTabBarViewController = (MainTabBarViewController *) self.sidePanelController.centerPanel;
    mainTabBarViewController.selectedViewController = rowModel.controller;
    [self.sidePanelController showCenterPanelAnimated:YES];
}

@end

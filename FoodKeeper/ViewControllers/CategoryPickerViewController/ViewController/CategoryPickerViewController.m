//
//  CategoryPickerViewController.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "CategoryPickerViewController.h"
#import "CategoryItemTableViewCell.h"
#import <FXBlurView.h>
#import <QuartzCore/QuartzCore.h>

@interface CategoryPickerViewController () <UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSArray *categories;

@end

#pragma mark -

@implementation CategoryPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *cancelItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelItemButton.frame = CGRectMake(0, 0, 46, 24);
    [cancelItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelItemButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelItemButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelItemButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelItemButton];
    
    self.navigationItem.title = @"Select Food Category";
    
    self.searchBar.backgroundColor = RGB(242, 242, 242);
   
    if ([self.searchBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.searchBar.barTintColor = RGB(242, 242, 242);
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.searchBar.tintColor = [UIColor blackColor];
    } else {
        self.searchBar.backgroundImage = [UIImage imageNamed:@"shopping_basket_search_bar_bgr"];
    }
    
    [self loadContent];
}

- (void)loadContent {
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"food_categories" ofType:@"plist"];
    self.categories = [NSArray arrayWithContentsOfFile:fileName];
    self.dataSource = [NSMutableArray arrayWithArray:self.categories];
}

- (NSMutableArray *)filteringCategory:(NSArray *)categories keyword:(NSString *)keyword {
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSString *name in categories) {
        NSRange range = [[name lowercaseString] rangeOfString:keyword];
        
        if (range.location != NSNotFound) {
            [results addObject:name];
        }
    }
    
    return results;
}

#pragma mark - Actions

- (IBAction)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryItemTableViewCell *cell = (CategoryItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CategoryItemTableViewCell class])];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryItemTableViewCell *cell = (CategoryItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CategoryItemTableViewCell class])];
    cell.categoryNameLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate dismissCategoryPicker:self categoryName:self.dataSource[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.dataSource = [self filteringCategory:self.categories keyword:[searchText lowercaseString]];
    [self.tableView reloadData];
}

@end

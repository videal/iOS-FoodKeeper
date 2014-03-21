//
//  AddFoodViewController.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "AddFoodViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "SidePanelController.h"
#import <JASidePanels/UIViewController+JASidePanel.h>

#import "CategoryPickerViewController.h"
#import "ExpireDatePickerViewController.h"
#import "SearchAutoCompleteViewController.h"

#import <ZBarSDK/ZBarSDK.h>

@interface AddFoodViewController () <ExpireDatePickerViewControllerDelegate, CategoryPickerViewControllerDelegate, UITextFieldDelegate, ZBarReaderDelegate, SearchAutoCompleteViewControllerDelegate> {
    NSInteger quantity;
}

@property (strong, nonatomic) NSString *barcodeValue;
@property (strong, nonatomic) NSString *categoryName;
@property (strong, nonatomic) NSDate *expireDate;

@property (nonatomic, strong) ExpireDatePickerViewController *expireDatePickerController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) SearchAutoCompleteViewController *searchAutoCompleteViewController;

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIButton *fridgeButton;
@property (weak, nonatomic) IBOutlet UIButton *cupboardButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *barcodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UIButton *quantityIncreaseButton;
@property (weak, nonatomic) IBOutlet UIButton *quantityDecreaseButton;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;

@property (weak, nonatomic) UIResponder *firstResponder;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)addButtonClicked:(id)sender;
- (IBAction)fridgeButtonClicked:(id)sender;
- (IBAction)cupboardButtonClicked:(id)sender;
- (IBAction)scanButtonClicked:(id)sender;
- (IBAction)quantityIncreaseButtonClicked:(id)sender;
- (IBAction)quantityDecreaseButtonClicked:(id)sender;
- (IBAction)categoryButtonClicked:(id)sender;
- (IBAction)dateButtonClicked:(id)sender;
- (IBAction)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer;

@end

#pragma mark -

@implementation AddFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"yyyy.MM.dd"
                                                             options:0
                                                              locale:[NSLocale currentLocale]];
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:formatString];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.nameTextField.tintColor = [UIColor blackColor];
        self.barcodeTextField.tintColor = [UIColor blackColor];
    }
    
    [self createCustomNavigationBarButton];
    
    self.scanButton.layer.cornerRadius = 6.0;
    self.categoryButton.layer.cornerRadius = 6.0;
    self.dateButton.layer.cornerRadius = 6.0;
    
    self.expireDate = nil;
    
    [self setQuantity:MAX([self.product.quantity intValue], 1)];
    self.barcodeValue = self.product.productDescription.barcode;
    self.barcodeTextField.text = self.product.productDescription.barcode;
    self.nameTextField.text = self.product.productDescription.name;
    [self setCategoryName:self.product.productDescription.category];
    
    [self updateStorageButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createCustomNavigationBarButton {
    UIButton *addItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addItemButton.frame = CGRectMake(0, 0, 36, 24);
    [addItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addItemButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [addItemButton setTitle:@"Add" forState:UIControlStateNormal];
    [addItemButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addItemButton];
    
    UIButton *cancelItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelItemButton.frame = CGRectMake(0, 0, 46, 24);
    [cancelItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelItemButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelItemButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelItemButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelItemButton];
}

- (void)updateStorageButton {
    [self.fridgeButton setImage:[UIImage imageNamed:self.storageType == ProductStorageTypeFridge ? @"radio_button_checked" : @"radio_button"] forState:UIControlStateNormal];
    [self.cupboardButton setImage:[UIImage imageNamed:self.storageType == ProductStorageTypeCupboard ? @"radio_button_checked" : @"radio_button"] forState:UIControlStateNormal];
}

- (void)setQuantity:(NSInteger)count {
    quantity = count;
    
    self.quantityLabel.text = [NSString stringWithFormat:@"%ld", (long)quantity];
}

- (void)setExpireDate:(NSDate *)expireDate {
    _expireDate = expireDate;
    
    [self.dateButton setTitle:expireDate ? ([NSString stringWithFormat:@"Expire date:%@", [self.dateFormatter stringFromDate:self.expireDate]]) : @"Select expire date" forState:UIControlStateNormal];
}

- (void)setCategoryName:(NSString *)categoryName {
    _categoryName = categoryName;
    
    [self.categoryButton setTitle:categoryName ? categoryName : @"Choose food category" forState:UIControlStateNormal];
}

- (void)hideKeyboard {
    [self.firstResponder resignFirstResponder];
    self.firstResponder = nil;
}

#pragma mark - UIKeyboard Notification

- (void)scrollContentScrollViewTo:(CGFloat)posY {
    CGFloat startPoint = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        startPoint = -64;
    }
    
    self.contentScrollView.contentOffset = CGPointMake(0, startPoint + posY);
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.contentScrollView.frame = CGRectMake(self.contentScrollView.frame.origin.x, self.contentScrollView.frame.origin.y, self.contentScrollView.frame.size.width, 504 - kbSize.height);
    self.contentScrollView.contentSize = CGSizeMake(320, 504);
    
    if ([self.firstResponder isEqual:self.nameTextField]) {
        [self scrollContentScrollViewTo:5];
    } else if ([self.firstResponder isEqual:self.barcodeTextField]) {
        [self scrollContentScrollViewTo:55];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    self.contentScrollView.frame = CGRectMake(self.contentScrollView.frame.origin.x, self.contentScrollView.frame.origin.y, self.contentScrollView.frame.size.width, 504);
    
    if ([self.firstResponder isEqual:self.nameTextField]) {
        [self scrollContentScrollViewTo:0];
    } else if ([self.firstResponder isEqual:self.barcodeTextField]) {
        [self scrollContentScrollViewTo:0];
    }
}

#pragma mark - Actions

- (IBAction)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer {
    [self hideKeyboard];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self hideKeyboard];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addButtonClicked:(id)sender {
    [self hideKeyboard];
    
    if (!self.nameTextField.text) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter product's name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    if (!self.barcodeValue) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter product's barcode" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    if (!self.expireDate) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please select product's expire date" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    if (!self.categoryName) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please choose product's category" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
            
    FKDataManager *dataManager = [FKDataManager sharedInstance];
    [dataManager insertProductWithName:self.nameTextField.text
                              quantity:@(quantity)
                            expireDate:self.expireDate
                           storageName:self.storageType == ProductStorageTypeCupboard ? CUPBOARD : FRIDGE
                              category:self.categoryName
                         barcodeString:self.barcodeValue
                       optimalQuantity:@(1)];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)fridgeButtonClicked:(id)sender {
    [self hideKeyboard];
    self.storageType = ProductStorageTypeFridge;
    [self updateStorageButton];
}

- (IBAction)cupboardButtonClicked:(id)sender {
    [self hideKeyboard];
    self.storageType = ProductStorageTypeCupboard;
    [self updateStorageButton];
}

- (IBAction)quantityIncreaseButtonClicked:(id)sender {
    [self hideKeyboard];
    [self setQuantity:quantity + 1];
}

- (IBAction)quantityDecreaseButtonClicked:(id)sender {
    [self hideKeyboard];
    
    if (quantity == 1) {
        return;
    }
    
    [self setQuantity:quantity - 1];
}

- (IBAction)categoryButtonClicked:(id)sender {
    [self hideKeyboard];
    
    CategoryPickerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([CategoryPickerViewController class])];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)dateButtonClicked:(id)sender {
    [self hideKeyboard];
    
    [self showExpireDatePicker];
}

- (IBAction)scanButtonClicked:(id)sender {    
    ZBarReaderViewController *readerViewController = [ZBarReaderViewController new];
	readerViewController.readerDelegate = self;
    ZBarImageScanner *imageScanner = readerViewController.scanner;
	[imageScanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    [self.navigationController presentViewController:readerViewController animated:YES completion:nil];
}

#pragma mark - ZBarReaderDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([picker isKindOfClass:[ZBarReaderViewController class]] && [info objectForKey:ZBarReaderControllerResults]) {
        id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
                
        for (symbol in results) {
            self.barcodeValue = symbol.data;
            self.barcodeTextField.text = self.barcodeValue;
            
            ProductDescription *productDescription = [[FKDataManager sharedInstance] getProductDescriptionsWithKeyword:self.barcodeValue searchType:SearchTypeBarcode];
            
            if (productDescription) {
                self.barcodeValue = productDescription.barcode;
                self.barcodeTextField.text = productDescription.barcode;
                self.nameTextField.text = productDescription.name;
                [self setCategoryName:productDescription.category];
            }
            
            break;
        }
    }
    
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)readerControllerDidFailToRead:(ZBarReaderController *)reader withRetry:(BOOL) retry {
	if (!retry) {
		// Dismiss scanner popup
		[reader dismissViewControllerAnimated:YES completion:^{
            // Notify user that his barcode was not recognized
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:@"The bar-code was not recognized. Please, try again."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)reader {
    // Dismiss scanner popup
    [reader dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - ExpireDatePickerViewController

- (void)showExpireDatePicker {
    
    if (!self.expireDatePickerController) {
        self.expireDatePickerController = [self.storyboard instantiateViewControllerWithIdentifier:
                                     NSStringFromClass([ExpireDatePickerViewController class])];
        self.expireDatePickerController.delegate = self;
        self.expireDatePickerController.expireDate = self.expireDate;
        
        [self.navigationController.view addSubview:self.expireDatePickerController.view];
        
        self.expireDatePickerController.view.alpha = 0.0;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.expireDatePickerController.view.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                         }];
        
        [self hideKeyboard];
    }
}

#pragma mark - ExpireDatePickerViewControllerDelegate

- (void)dismissExpireDatePicker:(ExpireDatePickerViewController *)expireDatePickerController expireDate:(NSDate *)expireDate {
    self.expireDate = expireDate;
    self.expireDatePickerController.view.alpha = 1.0;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.expireDatePickerController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self.expireDatePickerController.view removeFromSuperview];
                         self.expireDatePickerController = nil;
                     }];
}

#pragma mark - CategoryPickerViewControllerDelegate

- (void)dismissCategoryPicker:(CategoryPickerViewController *)categoryPickerViewController categoryName:(NSString *)categoryName {
    
    [self setCategoryName:categoryName];
}

#pragma mark - UITextFieldDelegate

- (BOOL)isAllDigits:(NSString *)text {
    NSCharacterSet *nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [text rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isEqual:self.barcodeTextField] &&
        ![self isAllDigits:string]) {
        return NO;
    }
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    SearchType searchType = ([textField isEqual:self.barcodeTextField]) ? SearchTypeBarcode : SearchTypeName;
    [self showSearchAutoCompleteViewWithSearchKey:text searchType:searchType];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.barcodeTextField]) {
        self.barcodeValue = self.barcodeTextField.text;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.firstResponder = textField;
    
    if ([self.firstResponder isEqual:self.nameTextField]) {
        [self scrollContentScrollViewTo:5];
    } else if ([self.firstResponder isEqual:self.barcodeTextField]) {
        [self scrollContentScrollViewTo:55];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchAutoCompleteViewController) {
        [self hideSearchAutoCompleteView];
    }
}

#pragma mark - SearchAutoCompleteViewController

- (void)showSearchAutoCompleteViewWithSearchKey:(NSString *)searchKey searchType:(SearchType)searchType {
    
    if (!self.searchAutoCompleteViewController) {
        self.searchAutoCompleteViewController = [self.storyboard instantiateViewControllerWithIdentifier:
                                                  NSStringFromClass([SearchAutoCompleteViewController class])];
        self.searchAutoCompleteViewController.delegate = self;
        self.searchAutoCompleteViewController.searchKey = [searchKey lowercaseString];
        self.searchAutoCompleteViewController.searchType = searchType;
        
        CGFloat viewHeight = self.view.frame.size.height;
        CGRect frame = CGRectMake(20, 64 + 40, 280, viewHeight - 216 - 64 - 41);
        
        if ([self.firstResponder isEqual:self.barcodeTextField]) {
            frame = CGRectMake(20, 64 + 55, 280, viewHeight - 216 - 64 - 56);
        }
        
        [self.navigationController.view addSubview:self.searchAutoCompleteViewController.view];
        
        self.searchAutoCompleteViewController.view.alpha = 1.0;
        self.searchAutoCompleteViewController.view.frame = frame;
    } else {
        [self.searchAutoCompleteViewController reloadContentWithSearchKey:[searchKey lowercaseString]];
    }
    
    if (searchKey.length == 0) {
        [self hideSearchAutoCompleteView];
    }
}

- (void)hideSearchAutoCompleteView {
    
    self.searchAutoCompleteViewController.view.alpha = 1.0;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.searchAutoCompleteViewController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self.searchAutoCompleteViewController.view removeFromSuperview];
                         self.searchAutoCompleteViewController = nil;
                     }];
}

#pragma mark - SearchAutoCompleteViewControllerDelegate

- (void)searchAutoCompleteViewControllerDidSelectedProductDescription:(SearchAutoCompleteViewController *)searchAutoCompleteViewController productDescription:(ProductDescription *)productDescription {
    [self hideSearchAutoCompleteView];
    [self hideKeyboard];
    
    self.barcodeValue = productDescription.barcode;
    self.barcodeTextField.text = productDescription.barcode;
    self.nameTextField.text = productDescription.name;
    [self setCategoryName:productDescription.category];
}

@end

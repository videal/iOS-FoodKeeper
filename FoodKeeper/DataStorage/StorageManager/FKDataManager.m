//
//  FKDataManager.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "FKDataManager.h"
#import "FKLocalNotificationManager.h"

@implementation FKDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Singleton

+ (FKDataManager *)sharedInstance{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedInstance = [self new]; });
    
    return _sharedInstance;
}

#pragma mark Init

- (id)init {
    self = [super init];
    if (self) {
        [self managedObjectContext];
        
    }
    return self;
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Error saving context %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Fetch Product In Cart

- (NSArray *)allProductsInCartWithKeyword:(NSString *)keyword {
    return [Storage allProductsInCartWithKeyword:keyword context:self.managedObjectContext];
}

#pragma mark - Fetch Product In Storage

- (NSArray *)productsInStorage:(NSString *)storageType keyword:(NSString *)keyword {
    [self checkProductsExpireDate];
    
    return [Storage productsInStorage:storageType keyword:keyword context:self.managedObjectContext];
}

#pragma mark - Managing Product

- (Product *)insertProductWithName:(NSString *)name
                          quantity:(NSNumber *)quantity
                        expireDate:(NSDate *)expireDate
                       storageName:(NSString *)storageName
                          category:(NSString *)category
                     barcodeString:(NSString *)barcode
                   optimalQuantity:(NSNumber *)optimalQuantity{
    
    Storage *storage = [Storage initWithName:storageName context:self.managedObjectContext];
    ProductStorageType storageType = 0;
    
    if ([storageName isEqualToString:FRIDGE]) {
        storageType = ProductStorageTypeFridge;
    } else if([storageName isEqualToString:CUPBOARD]) {
        storageType = ProductStorageTypeCupboard;
    }
    
    ProductDescription *pDesc = [ProductDescription initWithCategory:category
                                                         storageType:storageType
                                                                name:name
                                                       barcodeString:barcode
                                                             context:self.managedObjectContext];
    
    Product *product = [Product initWithExpireDate:expireDate
                                          quantity:quantity
                                           storage:storage
                                       description:pDesc
                                           context:self.managedObjectContext];
    
    [storage addStoredProductsObject:product];
    [pDesc addProductObject:product];
    
    [self saveContext];
    [[FKLocalNotificationManager sharedInstance] updateNotifications];
    
    return product;
}

- (void)changeProductQuantity:(Product *)product quantity:(NSNumber *)quantity {
    [product changeQuantity:quantity context:self.managedObjectContext];
    [self saveContext];
    [[FKLocalNotificationManager sharedInstance] updateNotifications];
}

- (void)deleteProduct:(Product *)product {
    [product deleteProduct:self.managedObjectContext];
    [self saveContext];
    [[FKLocalNotificationManager sharedInstance] updateNotifications];
}

- (void)checkProductsExpireDate {
    BOOL hasExpiryProducts = [Product checkProductsExpireDate:self.managedObjectContext];
    
    if (hasExpiryProducts) {
        [self saveContext];
        [[FKLocalNotificationManager sharedInstance] updateNotifications];
    }
}

- (NSArray *)allProductsWithBestBeforeDay:(NSInteger)notificationCount {
    NSMutableArray *results = [NSMutableArray array];
    
    NSDate *tomorrow = [[NSDate date] addedDays:1];
    NSDate *date = [tomorrow endOfDay];
    
    while (results.count < notificationCount) {
        NSArray *products = [Product allProductsWithBestBeforeDayFromDate:date context:self.managedObjectContext];
        
        if (products.count > 0) {
            Product *product = [products firstObject];
            date = [product.expireDate endOfDay];
            [results addObject:products];
        } else {
            break;
        }
    }
    
    return results;
}

#pragma mark - Fetch ProductDescription

- (ProductDescription *)getProductDescriptionsWithKeyword:(NSString *)keyword searchType:(SearchType)searchType {
    return [ProductDescription getProductDescriptionsWithKeyword:keyword searchType:searchType context:self.managedObjectContext];
}

- (NSArray *)allProductDescriptionsWithKeyword:(NSString *)keyword searchType:(SearchType)searchType {
    return [ProductDescription allProductDescriptionsWithKeyword:keyword searchType:searchType context:self.managedObjectContext];
}

#pragma mark - Settign Up Data Base

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FKDataBase.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        
        NSLog(@"Error setting up Data Base %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
//
//  FKDataManager.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Product.h"
#import "Storage.h"
#import "ProductDescription.h"

#define FRIDGE @"Fridge"
#define CUPBOARD @"Cupboard"

@interface FKDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (FKDataManager *)sharedInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

// Use storage macro as parameter
- (NSArray *)productsInStorage:(NSString*)storageType keyword:(NSString *)keyword;

- (NSArray *)allProductDescriptionsWithKeyword:(NSString *)keyword searchType:(SearchType)searchType;
- (ProductDescription *)getProductDescriptionsWithKeyword:(NSString *)keyword searchType:(SearchType)searchType;
- (NSArray *)allProductsInCartWithKeyword:(NSString *)keyword;

- (void)changeProductQuantity:(Product *)product quantity:(NSNumber *)quantity;
- (void)deleteProduct:(Product *)product;

- (NSArray *)allProductsWithBestBeforeDay:(NSInteger)notificationCount;

- (Product *)insertProductWithName:(NSString*)name
                     quantity:(NSNumber*)quantity
                   expireDate:(NSDate*)expireDate
                  storageName:(NSString*)storageName
                     category:(NSString *)category
                barcodeString:(NSString*)barcode
              optimalQuantity:(NSNumber *)optimalQuantity;


@end

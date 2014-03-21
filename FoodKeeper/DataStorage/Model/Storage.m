//
//  Storage.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "Storage.h"
#import "Product.h"
#import "ProductDescription.h"

@implementation Storage

@dynamic name;
@dynamic storedProducts;

#pragma mark -

+ (Storage *)initWithName:(NSString *)name context:(NSManagedObjectContext *)ctx {
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Storage class])];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", name];
    [fr setPredicate:pred];
    
    NSError *error;
    Storage *storage;
    NSArray *storages = [ctx executeFetchRequest:fr error:&error];
    
    if (error) {
        NSLog(@"error retrieving storages in init is: %@", [error localizedDescription]);
    } else {
        // we suppose that there is only one fridge or cupboard
        storage = [storages lastObject];
    }
    
    if (!storage) {
        storage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Storage class]) inManagedObjectContext:ctx];
        storage.name = name;
    }
    
    return storage;
}

+ (NSArray *)productsInStorage:(NSString *)storageType
                       keyword:(NSString *)keyword
                       context:(NSManagedObjectContext *)ctx {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Storage class])];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", storageType];
    [fetchRequest setPredicate:pred];
    
    NSError *error;
    NSArray *storages = [ctx executeFetchRequest:fetchRequest error:&error];
    NSArray *result;
    
    if (error) {
        NSLog(@"error retreiving storages: %@", [error localizedDescription]);
    } else {
        Storage *storage = [storages lastObject];
        NSSet *products = storage.storedProducts;
        result = [self filteringProducts:[products allObjects] keyword:keyword];
        result = [self sortByDateExpire:result ascending:YES];
    }
    
    return result;
}

+ (NSArray *)allProductsInCartWithKeyword:(NSString *)keyword
                                  context:(NSManagedObjectContext *)ctx {
    NSDate *dateAfterThreeDay = [[NSDate date] addedDays:3];
    NSDate *endOfDay = [dateAfterThreeDay endOfDay];
    
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Product class])];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"storage == nil OR expireDate <= %@", endOfDay];
    [fetchReq setPredicate:pred];
    
    NSError *error;
    NSArray *result = [ctx executeFetchRequest:fetchReq error:&error];
    
    if (error) {
        NSLog(@"error retreiving product: %@", [error localizedDescription]);
    }
    
    result = [self filteringProducts:result keyword:keyword];
    result = [self sortProductInCart:result];
    
    return result;
}

#pragma mark - Filtering

+ (NSArray *)filteringProducts:(NSArray *)products keyword:(NSString *)keyword {
    if (keyword.length == 0) {
        return products;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    
    for (Product *product in products) {
        // by name
        NSRange range = [[product.productDescription.name lowercaseString] rangeOfString:keyword];
        
        if (range.location != NSNotFound) {
            [results addObject:product];
            continue;
        }
        
        // by barcode
        range = [[product.productDescription.barcode lowercaseString] rangeOfString:keyword];
        
        if (range.location != NSNotFound) {
            [results addObject:product];
            continue;
        }
        
        // by category
        range = [[product.productDescription.category lowercaseString] rangeOfString:keyword];
        
        if (range.location != NSNotFound) {
            [results addObject:product];
            continue;
        }
    }
    
    return results;
}

#pragma mark - Sorting

+ (NSArray *)sortByDateExpire:(NSArray *)items ascending:(BOOL)value {
    NSMutableArray *objects = [NSMutableArray arrayWithArray:items];
    [objects sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"expireDate" ascending:value]]];
    return objects;
}

+ (NSArray *)sortProductInCart:(NSArray *)items {
    
    NSArray *sortedArray;
    sortedArray = [items sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(Product *product1, Product *product2) {
        
        if (product1.storage == nil && product2.storage != nil) {
            return NSOrderedAscending;
        } else if (product1.storage != nil && product2.storage == nil) {
            return NSOrderedDescending;
        } else {
            NSTimeInterval interval = [product1.expireDate timeIntervalSinceDate:product2.expireDate];
            
            if (interval < 0) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }
        
        return NSOrderedSame;
    }];
    
    return sortedArray;
}

@end

//
//  ProductDescription.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "ProductDescription.h"
#import "Product.h"

@implementation ProductDescription

@dynamic category;
@dynamic name;
@dynamic storageType;
@dynamic barcode;
@dynamic product;

#pragma mark -

+ (ProductDescription *)initWithCategory:(NSString *)category
                             storageType:(ProductStorageType)storageType
                                    name:(NSString *)name
                           barcodeString:(NSString*)barcodeString
                                 context:(NSManagedObjectContext *)ctx {
    
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([ProductDescription class])];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"barcode = %@", barcodeString];
    [fr setPredicate:pred];
    
    NSError *error;
    ProductDescription *productDescription;
    NSArray *productDescriptions = [ctx executeFetchRequest:fr error:&error];
    
    if (error) {
        NSLog(@"error retrieving storages in init is: %@", [error localizedDescription]);
    } else {
        productDescription = [productDescriptions lastObject];
    }
    
    if (!productDescription) {
        productDescription = [NSEntityDescription insertNewObjectForEntityForName:@"ProductDescription" inManagedObjectContext:ctx];
        productDescription.category = category;
        productDescription.storageType = storageType;
        productDescription.name = name;
        productDescription.barcode = barcodeString;
    }
    
    return productDescription;
}

#pragma mark -

+ (ProductDescription *)getProductDescriptionsWithKeyword:(NSString *)keyword
                                               searchType:(SearchType)searchType
                                                  context:(NSManagedObjectContext *)ctx {
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([ProductDescription class])];
    NSPredicate *pred = nil;
    
    switch (searchType) {
        case SearchTypeName:
            pred = [NSPredicate predicateWithFormat:@"name = %@", keyword];
            break;
            
        case SearchTypeBarcode:
            pred = [NSPredicate predicateWithFormat:@"barcode = %@", keyword];
            break;
    }
    
    [fetchReq setPredicate:pred];
    
    NSError *error;
    NSArray *result = [ctx executeFetchRequest:fetchReq error:&error];
    ProductDescription *productDescription = nil;
    
    if (error) {
        NSLog(@"error retreiving product description: %@", [error localizedDescription]);
    } else {
        productDescription = [result lastObject];
    }
    
    return productDescription;
}

+ (NSArray *)allProductDescriptionsWithKeyword:(NSString *)keyword
                                    searchType:(SearchType)searchType
                                       context:(NSManagedObjectContext *)ctx {
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([ProductDescription class])];
    NSSortDescriptor *sortDesc = nil;
    NSPredicate *pred = nil;
    
    switch (searchType) {
        case SearchTypeName:
            sortDesc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            break;
            
        case SearchTypeBarcode:
            sortDesc = [[NSSortDescriptor alloc] initWithKey:@"barcode" ascending:YES];
            break;
    }
    
    switch (searchType) {
        case SearchTypeName:
            pred = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", keyword];
            break;
            
        case SearchTypeBarcode:
            pred = [NSPredicate predicateWithFormat:@"barcode CONTAINS[cd] %@", keyword];
            break;
    }
    
    [fetchReq setSortDescriptors:@[sortDesc]];
    [fetchReq setPredicate:pred];
    
    NSError *error;
    NSArray *result = [ctx executeFetchRequest:fetchReq error:&error];
    
    if (error) {
        NSLog(@"error retreiving product description: %@", [error localizedDescription]);
    }
    
    return result;
}

@end

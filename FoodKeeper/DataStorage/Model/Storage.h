//
//  Storage.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Storage : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *storedProducts;

// use macros values to init storages
+ (Storage *)initWithName:(NSString *)name context:(NSManagedObjectContext *)ctx;

@end

@interface Storage (CoreDataGeneratedAccessors)

+ (NSArray *)productsInStorage:(NSString *)storageType
                       keyword:(NSString *)keyword
                       context:(NSManagedObjectContext *)ctx;

+ (NSArray *)allProductsInCartWithKeyword:(NSString *)keyword
                                  context:(NSManagedObjectContext *)ctx;

- (void)addStoredProductsObject:(Product *)value;
- (void)removeStoredProductsObject:(Product *)value;
- (void)addStoredProducts:(NSSet *)values;
- (void)removeStoredProducts:(NSSet *)values;

@end

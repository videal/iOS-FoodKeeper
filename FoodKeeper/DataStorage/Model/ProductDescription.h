//
//  ProductDescription.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product, ProductOptimalQuantity;

typedef enum {
    ProductStorageTypeFridge = 1,
    ProductStorageTypeCupboard,
} ProductStorageType;

typedef enum {
    SearchTypeName = 0,
    SearchTypeBarcode
} SearchType;

@interface ProductDescription : NSManagedObject

@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) ProductStorageType storageType;
@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) Product *product;

+ (ProductDescription *)initWithCategory:(NSString *)category
                             storageType:(ProductStorageType)storageType
                                    name:(NSString *)name
                           barcodeString:(NSString *)barcodeString
                                 context:(NSManagedObjectContext *)ctx;

+ (ProductDescription *)getProductDescriptionsWithKeyword:(NSString *)keyword
                                               searchType:(SearchType)searchType
                                                  context:(NSManagedObjectContext *)ctx;

+ (NSArray *)allProductDescriptionsWithKeyword:(NSString *)keyword
                                    searchType:(SearchType)searchType
                                       context:(NSManagedObjectContext *)ctx;

@end

@interface ProductDescription (CoreDataGeneratedAccessors)

- (void)addProductObject:(Product *)value;
- (void)removeProductObject:(Product *)value;
- (void)addProduct:(NSSet *)values;
- (void)removeProduct:(NSSet *)values;

@end

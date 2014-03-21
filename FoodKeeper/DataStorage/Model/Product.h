//
//  Product.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProductDescription, Storage;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSDate * expireDate;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) ProductDescription *productDescription;
@property (nonatomic, retain) Storage *storage;
@property (nonatomic, retain) NSDateFormatter * dateFormatter;

// format is @"MM-dd-yyyy"
@property (nonatomic,retain, readonly) NSString * formattedExpireDateString;

+ (Product *)initWithExpireDate:(NSDate *)expireDate
                       quantity:(NSNumber *)quantity
                        storage:(Storage *)storage
                    description:(ProductDescription *)productDescription
                        context:(NSManagedObjectContext *)ctx;

+ (Product *)getProductFromCart:(ProductDescription *)productDescription
                        context:(NSManagedObjectContext *)ctx;

+ (NSArray *)allProductsWithBestBeforeDayFromDate:(NSDate *)date
                                          context:(NSManagedObjectContext *)ctx;

+ (BOOL)checkProductsExpireDate:(NSManagedObjectContext *)ctx;

- (void)changeQuantity:(NSNumber *)quantity
               context:(NSManagedObjectContext *)ctx;
- (void)deleteProduct:(NSManagedObjectContext *)ctx;

@end

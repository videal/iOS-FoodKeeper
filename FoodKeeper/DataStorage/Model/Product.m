//
//  Product.m
//  FoodKeeper
//
//  Created by Alexander Voityuk on 3/18/14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "Product.h"
#import "ProductDescription.h"
#import "Storage.h"

@implementation Product

@dynamic expireDate;
@dynamic quantity;
@dynamic productDescription;
@dynamic storage;
@dynamic dateFormatter;
@synthesize formattedExpireDateString =_formattedExpireDateString;

#pragma mark -

+ (Product *)initWithExpireDate:(NSDate *)expireDate
                       quantity:(NSNumber *)quantity
                        storage:(Storage *)storage
                    description:(ProductDescription *)productDescription
                        context:(NSManagedObjectContext *)ctx {
    Product *product = [self getProductFromStorage:storage
                                       description:productDescription
                                        expireDate:expireDate
                                           context:ctx];
    
    if (!product) {
        product = [self getProductFromCart:productDescription context:ctx];
        product.quantity = quantity;
    } else {
        product.quantity = @([product.quantity intValue] + [quantity intValue]);
    }
    
    if (!product) {
        product = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Product class]) inManagedObjectContext:ctx];
        product.quantity = quantity;
    }
    
    product.expireDate = expireDate;
    product.storage = storage;
    product.productDescription = productDescription;
    
    return product;
}

#pragma mark -

+ (Product *)getProductFromStorage:(Storage *)storage
                       description:(ProductDescription *)productDescription
                        expireDate:(NSDate *)expireDate
                           context:(NSManagedObjectContext *)ctx {
    
    NSDate *start = [expireDate beginningOfDay];
    NSDate *end = [expireDate endOfDay];
    
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Product class])];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"expireDate BETWEEN {%@,%@} AND productDescription.barcode = %@ AND storage.name = %@", start, end, productDescription.barcode, storage.name];
    [fr setPredicate:pred];
    
    NSError *error;
    Product *product;
    NSArray *products = [ctx executeFetchRequest:fr error:&error];
    
    if (error) {
        NSLog(@"error retreiving product in init is: %@", [error localizedDescription]);
    } else {
        product = [products lastObject];
    }
    
    return product;
}

+ (Product *)getProductFromCart:(ProductDescription *)productDescription
                        context:(NSManagedObjectContext *)ctx {
    
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Product class])];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"storage == nil AND productDescription.barcode = %@", productDescription.barcode];
    [fetchReq setPredicate:pred];
    
    NSError *error;
    NSArray *result = [ctx executeFetchRequest:fetchReq error:&error];
    
    if (error) {
        NSLog(@"error retreiving product: %@", [error localizedDescription]);
        return NO;
    } else {
        return [result lastObject];
    }
}

+ (NSArray *)allProductsWithBestBeforeDayFromDate:(NSDate *)date
                                          context:(NSManagedObjectContext *)ctx {
    NSDate *expireDate = nil;
    
    {
        NSExpression *amountKeyPath = [NSExpression expressionForKeyPath:@"expireDate"];
        NSExpression *expireDateExpression = [NSExpression expressionForFunction:@"min:" arguments:@[amountKeyPath]];
        
        // Create the expression description for that expression.
        NSExpressionDescription *description = [[NSExpressionDescription alloc] init];
        [description setName:@"min"];
        [description setExpression:expireDateExpression];
        [description setExpressionResultType:NSDateAttributeType];
        
        // Create the sum amount fetch request,
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Product"];
        fetchRequest.resultType = NSDictionaryResultType;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"storage != nil AND expireDate > %@", date];
        fetchRequest.propertiesToFetch = @[@"expireDate", description];
        fetchRequest.propertiesToGroupBy = @[@"expireDate"];
        
        NSError *error = nil;
        NSArray *results = [ctx executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            NSLog(@"error retreiving product: %@", [error localizedDescription]);
            return NO;
        } else {
            NSDictionary *result = [results firstObject];
            expireDate = result[@"min"];
        }
    }
    
    // get all products
    if (expireDate) {
        NSDate *start = [expireDate beginningOfDay];
        NSDate *end = [expireDate endOfDay];
        
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Product class])];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"expireDate BETWEEN {%@,%@} AND storage != nil", start, end];
        [fr setPredicate:pred];
        
        NSError *error;
        NSArray *products = [ctx executeFetchRequest:fr error:&error];
        
        if (error) {
            NSLog(@"error retreiving product in init is: %@", [error localizedDescription]);
        } else {
            return products;
        }
    }
    
    return @[];
}

#pragma mark -

+ (BOOL)checkProductsExpireDate:(NSManagedObjectContext *)ctx {
    NSDate *endOfDay = [[NSDate date] endOfDay];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Product class])];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"storage != nil AND expireDate <= %@", endOfDay];
    [fetchRequest setPredicate:pred];
    
    NSError *error;
    NSArray *products = [ctx executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"error retreiving products: %@", [error localizedDescription]);
    } else {
        for (Product *product in products) {
            BOOL isProductAlreadyInCart = [Product getProductFromCart:product.productDescription context:ctx] != nil;
            
            if (isProductAlreadyInCart) {
                product.productDescription = nil;
                product.storage = nil;
                
                [ctx deleteObject:product];
            } else {
                product.storage = nil;
            }
        }
    }
    
    return (products.count > 0);
}

#pragma mark -

- (void)changeQuantity:(NSNumber *)quantity
               context:(NSManagedObjectContext *)ctx {
    NSInteger newQuantity = [self.quantity intValue] + [quantity intValue];
    self.quantity = @(newQuantity);
    
    if (newQuantity <= 0) {
        BOOL isProductAlreadyInCart = [Product getProductFromCart:self.productDescription context:self.managedObjectContext] != nil;
        
        if (isProductAlreadyInCart) {
            [self deleteProduct:ctx];
        } else {
            self.storage = nil;
        }
    }
}

- (void)deleteProduct:(NSManagedObjectContext *)ctx {
    
    self.productDescription = nil;
    self.storage = nil;
    
    [self.managedObjectContext deleteObject:self];
}

#pragma mark -

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter * _dateFormatter = nil;
    
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM-dd-yyyy"];
    }
    
    return _dateFormatter;
}

- (NSString *)formattedExpireDateString {
    _formattedExpireDateString = [self.dateFormatter stringFromDate:self.expireDate];
    return _formattedExpireDateString;
}

@end

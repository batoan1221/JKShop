//
//  JKProductManager.m
//  JKShop
//
//  Created by admin on 12/1/13.
//  Copyright (c) 2013 Nguyễn Bá Toàn. All rights reserved.
//

#import "JKProductManager.h"

static NSString * const STORE_PRODUCT_BOOKMARK      =   @"store_product_bookmark";
static NSString * const STORE_PRODUCT_ID            =   @"store_product_id";
static NSString * const STORE_PRODUCT_NUMBER        =   @"store_product_number";

@implementation JKProductManager

SINGLETON_MACRO

#pragma mark - Get product details from server

- (void)getProductsWithCategoryID:(NSInteger)category_id
                        onSuccess:(JKJSONRequestSuccessBlock)successBlock
                          failure:(JKJSONRequestFailureBlock)failureBlock
{
    NSDictionary *params = @{
                             @"category_id"     : [NSNumber numberWithInteger:category_id]
                             };
    
    [[JKHTTPClient sharedClient] getPath:[NSString stringWithFormat:@"%@%@",API_SERVER_HOST,API_GET_PRODUCT_BY_CATEGORY_ID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [[JKProductManager sharedInstance] productsFromReponseObject:responseObject[@"products"]];
        NSMutableArray *arrProduct = [[NSMutableArray alloc] init];
        for (int i = 0; i < [responseObject[@"products"] count]; i++) {
            JKProduct *product = [JKProduct productWithDictionary:[responseObject[@"products"] objectAtIndex:i]
                                              category:[[JKCategory MR_findByAttribute:@"category_id" withValue:@(category_id)] firstObject]];
            [arrProduct addObject:product];
        }
          successBlock(operation.response.statusCode, arrProduct);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSArray *arr = [self getStoredProductsWithCategoryId:category_id];
        if (arr.count > 0) {
            successBlock(operation.response.statusCode, arr);
            return;
        }
        
        if (failureBlock) {
            failureBlock(operation.response.statusCode, error);
        }
    }];
    
    
}

- (NSArray *)getStoredProductsWithCategoryId:(NSInteger)category_id
{
    NSNumber *catID = @(category_id);
    NSArray *arrProducts = [[NSArray alloc] init];
    
    // if new arrived
    if (category_id == 21) {
        arrProducts = [JKProduct MR_findAllSortedBy:@"public_date" ascending:NO];
        return arrProducts;
    }
    
    JKCategory * category = [[JKCategory MR_findByAttribute:@"category_id" withValue:catID] firstObject];
    arrProducts = [category.product allObjects];
    if (arrProducts.count) {
        [SVProgressHUD dismiss];
    }
    return arrProducts;
}


#pragma mark - Helpers

- (void)productsFromReponseObject:(NSArray *)productDictionaryArray
{
    NSMutableArray *arrProduct = [[NSMutableArray alloc] init];
    
    NSBlockOperation *saveInBackground = [NSBlockOperation blockOperationWithBlock:^{
        [productDictionaryArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            JKProduct *product;
            product = [JKProduct productWithDictionary:obj];
            [arrProduct addObject:product];
        }];
    }];
    
    [saveInBackground setCompletionBlock:^{
        NSManagedObjectContext *mainContext  = [NSManagedObjectContext MR_defaultContext];
        [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            DLog(@"Finish save to magical record");
        }];
    }];
    
    [saveInBackground start];
}

- (void)saveBookmarkProductWithArray:(NSArray *)array
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:array forKey:STORE_PRODUCT_BOOKMARK];
    [userDefault synchronize];
}

- (void)saveBookmarkProductWithMutableArray:(NSMutableArray *)array
{
    [self saveBookmarkProductWithArray:array];
}

- (NSMutableArray *)getBookmarkProducts
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [[userDefault objectForKey:STORE_PRODUCT_BOOKMARK] mutableCopy];
    
    if (arr) {
        return arr;
    }
    
    return [[NSMutableArray alloc] init];
}

- (void)removeBookmarkProductWithProductID:(NSNumber *)productID
{
    NSMutableArray *bookmarkedProducts = [self getBookmarkProducts];
    
    for (NSDictionary *data in bookmarkedProducts) {
        NSNumber *product = data[STORE_PRODUCT_ID];
        if ([productID integerValue] == [product integerValue]) {
            [bookmarkedProducts removeObject:data];
        }
    }
    
    [self saveBookmarkProductWithArray:bookmarkedProducts];
}

- (void)bookmarkProductWithProduct:(JKProduct *)product
{
    NSNumber *productID = product.product_id;
    [self bookmarkProductWithProductID:productID withNumber:1];
}

- (void)bookmarkProductWithProductID:(NSNumber *)productID
{
    [self bookmarkProductWithProductID:productID withNumber:1];
}

- (BOOL)isBookmarkedAlreadyWithProductID:(NSNumber *)productID
{
    NSMutableArray *bookmarkProducts = [self getBookmarkProducts];
    
    for (NSDictionary *data in bookmarkProducts) {
        NSNumber *product = data[STORE_PRODUCT_ID];
        if ([productID integerValue] == [product integerValue]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)bookmarkProductWithProductID:(NSNumber *)productID withNumber:(NSInteger)number
{
    NSDictionary *data = @{STORE_PRODUCT_ID: productID,
                           STORE_PRODUCT_NUMBER : @(number)};
    
    NSMutableArray *bookmarkProducts = [self getBookmarkProducts];
    
    if ([self isBookmarkedAlreadyWithProductID:productID])
        return;
    
    [bookmarkProducts addObject:data];
    [self saveBookmarkProductWithMutableArray:bookmarkProducts];
}

- (void)updateProductWithProductID:(NSNumber *)productID withNumber:(NSInteger)number
{
    NSMutableArray *bookmarkedProducts = [self getBookmarkProducts];
    int index = 0;
    for (NSDictionary *data in bookmarkedProducts) {
        NSNumber *product = data[STORE_PRODUCT_ID];
        if ([productID integerValue] == [product integerValue]) {
            break;
        }
        index++;
    }
    
    NSDictionary *data = [bookmarkedProducts objectAtIndex:index];
    NSDictionary *newData = @{STORE_PRODUCT_ID : data[STORE_PRODUCT_ID],
                              STORE_PRODUCT_NUMBER : @(number)};
    [bookmarkedProducts replaceObjectAtIndex:index withObject:newData];
    
    [self saveBookmarkProductWithArray:bookmarkedProducts];
}


@end

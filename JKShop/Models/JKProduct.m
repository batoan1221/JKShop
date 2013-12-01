//
//  JKProduct.m
//  JKShop
//
//  Created by admin on 12/1/13.
//  Copyright (c) 2013 Nguyễn Bá Toàn. All rights reserved.
//

#import "JKProduct.h"

@implementation JKProduct

+ (JKProduct *)productWithDictionary:(NSDictionary *)dictionary
{
    // look for the core data first
    JKProduct *product = [[JKProduct MR_findByAttribute:@"product_id" withValue:dictionary[@"MaSanPham"]] lastObject];
    
    if (product)
        return product;
    
    if (!product && ![dictionary[@"name"] isKindOfClass:[NSNull class]]) {
        product = [JKProduct MR_createEntity];
        product.product_id = [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
        product.color = dictionary[@"color"];
        product.product_code = dictionary[@"sku"];
        product.detail = dictionary[@"description"];
        product.category_id = dictionary[@"category_id"];
        product.name = dictionary[@"name"];
        product.price = dictionary[@"price"];
        product.sale_price = dictionary[@"sale_price"];
        product.size = dictionary[@"size"];
        product.stock = dictionary[@"stock"];
        product.stock_status = dictionary[@"stock_status"];
    }
    return product;
}

@end
//
//  JKBookmarkTableViewCell.h
//  JKShop
//
//  Created by admin on 12/9/13.
//  Copyright (c) 2013 Nguyễn Bá Toàn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKBookmarkTableViewCell : SWTableViewCell

- (void)configWithDictionary:(NSDictionary *)dictionaryProduct;
+ (CGFloat)getHeight;


@end

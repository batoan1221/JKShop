//
//  JKSidebarMenuTableViewCell.h
//  JKShop
//
//  Created by admin on 11/30/13.
//  Copyright (c) 2013 Nguyễn Bá Toàn. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MENU_TITLE                      @"name"
#define CATEGORY_ID                     @"term_id"

@interface JKSidebarMenuTableViewCell : UITableViewCell

- (void)customCategoryCellWithCategory:(JKCategory *)category;
- (void)configWithData:(id)data;
+ (CGFloat)getHeight;

@end

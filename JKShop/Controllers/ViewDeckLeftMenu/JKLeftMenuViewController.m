//
//  JKLeftMenuViewController.m
//  JKShop
//
//  Created by admin on 11/30/13.
//  Copyright (c) 2013 Nguyễn Bá Toàn. All rights reserved.
//

#import "JKLeftMenuViewController.h"
#import "JKSidebarMenuTableViewCell.h"
#import "JKLeftMenuSectionHeader.h"
#import "JKAppDelegate.h"
#import "JKNavigationViewController.h"
#import "JKLeftMenuFooter.h"
#import "JKCategory.h"
#import "JKHomeViewController.h"
#import "JKSearchProductCell.h"
#import "JKProductDetailViewController.h"

@interface JKLeftMenuViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UISearchDisplayDelegate,
UISearchBarDelegate
>

@property (strong, nonatomic) NSMutableArray        * arrMenu;
@property (strong, nonatomic) NSArray               * arrSection;
@property (strong, nonatomic) NSArray               * arrIconSection;
@property (strong, nonatomic) NSArray               * arrSubMenuSectionOne;
@property (assign, nonatomic) BOOL                  isSearching;
@property (strong, nonatomic) NSMutableArray        * filteredList;
@property (weak, nonatomic) IBOutlet UITableView    *menuTableView;

@end

@implementation JKLeftMenuViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.arrMenu = [[NSMutableArray alloc] init];
    
    self.arrSubMenuSectionOne = @[@"JK Shop", @"Hàng mới về", @"Liên hệ"];
    self.arrSection = @[@"Nổi Bật", @"Danh Mục", @"Tuỳ Chỉnh", @"Thông Tin"];
    self.arrIconSection = @[@"star.png",@"category.png",@"setting.png",@"info.png"];
    
    [self.menuTableView registerNib:[UINib nibWithNibName:NSStringFromClass([JKSidebarMenuTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([JKSidebarMenuTableViewCell class])];
    [self.menuTableView registerNib:[UINib nibWithNibName:NSStringFromClass([JKLeftMenuSectionHeader class]) bundle:nil] forHeaderFooterViewReuseIdentifier:NSStringFromClass([JKLeftMenuSectionHeader class])];
    
    self.arrMenu = [[JKCategory MR_findAll] mutableCopy];
    self.menuTableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
    [[JKCategoryManager sharedInstance] getMenuListOnComplete:^(NSArray *menu) {
        self.arrMenu = [menu mutableCopy];
        [self.menuTableView reloadData];
    } orFailure:^(NSError *error) {
        DLog(@"Error when load menu");
    }];
}

#pragma mark - Tableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.isSearching) {
        return 1;
    }
    return [self.arrSection count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.isSearching){
        return self.filteredList.count;
    }

    if (section == 0) {
        return self.arrSubMenuSectionOne.count;
    }
    
    if (section == 1) {
        return self.arrMenu.count;
    }
    
    if (section == 2) {
        return 1;
    }

    if (section == 3) {
        return 1;
    }
    
    return self.arrMenu.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [JKLeftMenuSectionHeader getHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isSearching) {
        return 128;
    }
    return [JKSidebarMenuTableViewCell getHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    JKLeftMenuSectionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([JKLeftMenuSectionHeader class])];
    
    if (!header) {
        header = [[JKLeftMenuSectionHeader alloc] init];
    }
    
    if (self.isSearching) {
        [header configTitleNameWithString:@"Kết quả tìm kiếm"];
        [header configIconWithImageURL:@"search"];
    }
    else{
        if ([[self.arrSection objectAtIndex:section] isKindOfClass:[NSString class]]) {
            [header configTitleNameWithString:[self.arrSection objectAtIndex:section]];
            [header configIconWithImageURL:[self.arrIconSection objectAtIndex:section]];
        }
    }
    return header;

}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    JKLeftMenuFooter *footer;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([JKLeftMenuFooter class])];
    }else{
        footer = [[JKLeftMenuFooter alloc] init];
    }
    if (!footer) {
        footer = [[JKLeftMenuFooter alloc] init];
    }
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == 3)
        return 65;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIndentifier =  NSStringFromClass([JKSidebarMenuTableViewCell class]);
    JKSidebarMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    if (self.isSearching && [self.filteredList count]) {
        if ([[self.filteredList objectAtIndex:indexPath.row] isKindOfClass:[JKProduct class]]) {
            JKSearchProductCell * cell2 = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:@"JKSearchProductCell"];
            [cell2 customCellWithProduct:[self.filteredList objectAtIndex:indexPath.row]];
            return cell2;
        }
    }
    else{
        if (indexPath.section == 0) {
            NSString *title = [self.arrSubMenuSectionOne objectAtIndex:indexPath.row];
            NSDictionary *data = @{MENU_TITLE : title};
            [cell configWithData:data];
            return cell;
        }
    
        if (indexPath.section == 2) {
            NSDictionary *data = @{MENU_TITLE : @"Cấu hình"};
            [cell configWithData:data];
            return cell;
        }
    
        if (indexPath.section == 3) {
            NSDictionary *data = @{MENU_TITLE : @"Bản đồ"};
            [cell configWithData:data];
            return cell;
        }
    
        if (indexPath.row < self.arrMenu.count)
        {
            JKCategory *category = [self.arrMenu objectAtIndex:indexPath.row];
            [cell customCategoryCellWithCategory:category];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    IIViewDeckController *deckViewController = (IIViewDeckController*)[[(JKAppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
    JKNavigationViewController *centralNavVC = (JKNavigationViewController *) deckViewController.centerController;
    if (self.isSearching) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        IIViewDeckController *deckViewController = (IIViewDeckController*)[[(JKAppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
        JKNavigationViewController *centralNavVC = (JKNavigationViewController *) deckViewController.centerController;
        JKProductDetailViewController *productDetailVC = [[JKProductDetailViewController alloc] init];
        
        productDetailVC.product = [self.filteredList objectAtIndex:indexPath.item];
        [self.view endEditing:YES];
        [deckViewController toggleLeftView];
        [centralNavVC pushViewController:productDetailVC animated:YES];
        [SVProgressHUD showWithStatus:@"Đang tải chi tiết sản phẩm" maskType:SVProgressHUDMaskTypeGradient];

    }
    else{
        if (indexPath.section == 0) {
        
            // Back to master menu
            if (indexPath.row == 0) {
                [centralNavVC setViewControllers:[NSArray arrayWithObject:[[JKHomeViewController alloc] init]] animated:YES];
                [deckViewController toggleLeftViewAnimated:YES];
                return;
            }
        
            // New products
        
            if (indexPath.row == 1) {
//              OFProductsViewController *productsVC = [[OFProductsViewController alloc] init];
//              productsVC.category_id = 21;
//              productsVC.lblTitle = [self.arrSubMenuSectionOne objectAtIndex:indexPath.row];
//            
//              [centralNavVC pushViewController:productsVC animated:YES];
//              [deckViewController toggleLeftView];
                return;
            }
        
            // Contact screen
            if (indexPath.row == 2) {
                BaseViewController *menu3 = [[BaseViewController alloc] init];
                CGRect frame = self.view.frame;
            
                UIWebView *web = [[UIWebView alloc] initWithFrame:frame];
                [menu3.view addSubview:web];
            
                NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"thong-tin-thanh-toan.html"];
                NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [web loadRequest:request];
            
                menu3.title = @"Hướng dẫn đặt hàng";
            
                [centralNavVC setViewControllers:[NSArray arrayWithObject:menu3] animated:YES];
                [deckViewController toggleLeftViewAnimated:YES];
                [menu3 addNavigationItems];
                return;
            }
        }
    
        if (indexPath.section == 3) {
            [centralNavVC setViewControllers:[NSArray arrayWithObject:[[JKMapViewController alloc]init]] animated:YES];
            [deckViewController toggleLeftViewAnimated:YES];
            return;
        }
    
        if (indexPath.section == 2) {
            [SVProgressHUD showErrorWithStatus:@"Chức năng hiện đang trong quá trình phát triển"];
            return;
        }
    
        JKProductsViewController *productsVC = [[JKProductsViewController alloc] init];
        productsVC.category_id = [[self.arrMenu objectAtIndex:indexPath.row] getCategoryId];
        productsVC.lblTitle = [[self.arrMenu objectAtIndex:indexPath.row] getCategoryName];
        [centralNavVC setViewControllers:[NSArray arrayWithObject:productsVC] animated:YES];
        [deckViewController toggleLeftViewAnimated:YES];
    }
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    self.isSearching = YES;
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:NSStringFromClass([JKSearchProductCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([JKSearchProductCell class])];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    self.isSearching = NO;
    [self.menuTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self filterListForSearchText:searchString];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect frame = self.searchDisplayController.searchResultsTableView.frame;
        frame.origin.y = -20;
        self.searchDisplayController.searchResultsTableView.frame = frame;
    }
    return YES;
}

- (void)filterListForSearchText:(NSString *)searchText
{
    [self.filteredList removeAllObjects];
    self.filteredList = [self arrProductsForSearchText:searchText];
}

- (NSMutableArray *)arrProductsForSearchText:(NSString *)searchText
{
    NSMutableArray *arrResultProduct = [[NSMutableArray alloc] init];
    NSArray *arrProduct = [JKProduct MR_findAll];
    
    for (JKProduct *product in arrProduct) {
        NSRange nameRange = [product.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (nameRange.location != NSNotFound) {
            [arrResultProduct addObject:product];
        }
    }
    
    if (arrResultProduct.count == 0) {
        for (JKProduct *product in arrProduct) {
            NSRange nameRange = [product.product_code rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound) {
                [arrResultProduct addObject:product];
            }
        }
    }
    
    return arrResultProduct;
}

@end

 //
//  JKProductDetailViewController.m
//  JKShop
//
//  Created by Toan Slan on 12/3/13.
//  Copyright (c) 2013 Nguyễn Bá Toàn. All rights reserved.
//

#import "JKProductDetailViewController.h"
#import "JKProductsDetailCollectionCell.h"
#import "JKPopup.h"

@interface JKProductDetailViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate,
UAModalPanelDelegate
>

@property (strong, nonatomic) NSArray                               * productImageArray;
@property (strong, nonatomic) NSMutableArray                        * productsArr;

@property (weak, nonatomic) IBOutlet UILabel                        * labelProductName;
@property (weak, nonatomic) IBOutlet UILabel                        * labelProductPrice;
@property (weak, nonatomic) IBOutlet UILabel                        * labelProductDetail;
@property (weak, nonatomic) IBOutlet UILabel                        * labelProductSKU;
@property (weak, nonatomic) IBOutlet UILabel                        * labelRelatedProduct;
@property (weak, nonatomic) IBOutlet UIScrollView                   * contentScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl                  * imagePageControl;
@property (weak, nonatomic) IBOutlet UICollectionView               * productCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView               * relatedProductCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView        * activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel                        * labelSizeTitle;
@property (weak, nonatomic) IBOutlet UILabel                        * labelColorTitle;
@property (weak, nonatomic) IBOutlet UILabel                        * labelSize;
@property (weak, nonatomic) IBOutlet UILabel                        * labelColor;
@property (weak, nonatomic) IBOutlet UIView                         * separatorView;
@property (strong, nonatomic) IBOutlet UIView                       * separatorBreakView;

@end

@implementation JKProductDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SVProgressHUD showWithStatus:@"Đang tải chi tiết sản phẩm" maskType:SVProgressHUDMaskTypeGradient];
    self.title = [self.product getProductName];
    [self.productCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([JKProductsDetailCollectionCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([JKProductsDetailCollectionCell class])];
    [self.relatedProductCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([JKProductsCollectionCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([JKProductsCollectionCell class])];
    
    [self fillUpCollectionRelatedProductWithCategoryID:[[self.product.category anyObject] getCategoryId]];
    
    [self loadProductDetail];
    
    [self getImageFromProduct];
    
    
}

- (void)getImageFromProduct{
    [JKProductImages getImagesForProduct:[self.product getProductId] successBlock:^(NSInteger statusCode, NSSet *productImageSet) {
        self.productImageArray = [productImageSet allObjects];
        [self.imagePageControl setNumberOfPages:[self.productImageArray count]];
        
        [self.contentScrollView setScrollEnabled:YES];
        [self.productCollectionView reloadData];
        
        [SVProgressHUD dismiss];
    } failureBlock:^(NSInteger statusCode, id obj) {
        [SVProgressHUD showErrorWithStatus:@"Xin vui lòng kiểm tra kết nối mạng và thử lại"];
    }];;
}

- (void)loadProductDetail{
    self.labelProductName.text = [self.product getProductName];
    
    self.labelProductPrice.text = [NSString getVNCurrencyFormatterWithNumber:@([[self.product getProductPrice] intValue]) ];
    
    self.labelProductDetail.text = [NSString stringWithFormat:@"Chi tiết sản phẩm: %@",[self.product getProductDetail]];
    [self.labelProductDetail sizeToFitKeepWidth];
    
    self.labelProductSKU.text = [NSString stringWithFormat:@"Mã sản phẩm: %@",[self.product getProductSKU]];
    
    [self.labelSizeTitle alignBelowView:self.labelProductDetail offsetY:50 sameWidth:NO];
    self.labelSize.text = [self.product.size  isEqual: @""] ? @"Updating..." : self.product.size;
    [self.labelSize alignVerticallyCenterToView:self.labelSizeTitle];

    [self.separatorView alignBelowView:self.labelSizeTitle offsetY:10 sameWidth:NO];

    self.labelColor.text = [self.product.color isEqual: @""] ? @"Updating..." : self.product.color;
    [self.labelColorTitle alignBelowView:self.separatorView offsetY:10 sameWidth:NO];
    [self.labelColor alignVerticallyCenterToView:self.labelColorTitle];
    
    [self.separatorBreakView alignBelowView:self.labelColorTitle offsetY:50 sameWidth:NO];

    [self.labelRelatedProduct alignBelowView:self.separatorBreakView offsetY:10 sameWidth:NO];
    [self.relatedProductCollectionView alignBelowView:self.labelRelatedProduct offsetY:10 sameWidth:NO];
    
    [self.activityIndicator alignBelowView:self.labelRelatedProduct offsetY:40 sameWidth:NO];
    self.contentScrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width,CGRectGetMaxY([self.relatedProductCollectionView frame]));
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
#warning clean this code
    CGFloat pageWidth = self.productCollectionView.frame.size.width;
    
    int page = floor((self.productCollectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.imagePageControl.currentPage = page;
}

- (void)fillUpCollectionRelatedProductWithCategoryID:(NSInteger)categoryID
{
    self.productsArr = [[[JKProductManager alloc] getStoredProductsWithCategoryId:[[self.product.category anyObject] getCategoryId]] mutableCopy];
    [self showCollectionView];
}

- (void)showCollectionView
{
    if (self.productsArr.count) {
        [self.relatedProductCollectionView reloadData];
        [self.relatedProductCollectionView setHidden:NO];
        [self.activityIndicator stopAnimating];
        [SVProgressHUD dismiss];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.relatedProductCollectionView) {
        IIViewDeckController *deckViewController = (IIViewDeckController*)[JKAppDelegate getRootViewController];
        JKNavigationViewController *centralNavVC = (JKNavigationViewController *) deckViewController.centerController;
        
        JKProductDetailViewController *productDetailVC = [[JKProductDetailViewController alloc] init];
        productDetailVC.product = [self.productsArr objectAtIndex:indexPath.item];
        
        [centralNavVC pushViewController:productDetailVC animated:YES];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (collectionView == self.productCollectionView) {
        return [self.productImageArray count];
    }
    
    return self.productsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == self.productCollectionView) {
        JKProductsDetailCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([JKProductsDetailCollectionCell class]) forIndexPath:indexPath];
        [cell customProductsDetailCellWithProductImage:[self.productImageArray objectAtIndex:indexPath.item]];
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        [imageView setImageWithURL:[NSURL URLWithString:[[self.productImageArray objectAtIndex:indexPath.item] getMediumImageURL]]];
        [imageView setupImageViewerWithDatasource:self initialIndex:indexPath.row onOpen:nil onClose:nil];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = NO;
        
        return cell;
    }
    
    JKProductsCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([JKProductsCollectionCell class]) forIndexPath:indexPath];
    [cell customProductCellWithProduct:[self.productsArr objectAtIndex:indexPath.item]];
    return cell;
    
}

#pragma mark - Helper methods
- (IBAction)addToCartButton:(id)sender {
    
    JKPopup *modalPanel = [[JKPopup alloc] initWithFrame:self.view.bounds];
    [modalPanel loadDetailWithProduct:self.product];
    [self.navigationController.view addSubview:modalPanel];
    [modalPanel showFromPoint:[self.view center]];
}

- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer *)imageViewer {
    return self.productImageArray.count;
}

-  (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer {
    return [NSURL URLWithString:[[self.productImageArray objectAtIndex:index] getMediumImageURL]];
}

- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer{
    return nil;
}
@end

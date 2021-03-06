//
//  JKPopupBookmark.m
//  JKShop
//
//  Created by Toan Slan on 12/11/13.
//  Copyright (c) 2013 Nguyễn Bá Toàn. All rights reserved.
//

#import "JKPopupBookmark.h"

@interface JKPopupBookmark()

@property (strong, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UILabel *labelQuantity;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *labelProductName;
@property (weak, nonatomic) IBOutlet UILabel *labelProductSku;
@property (weak, nonatomic) IBOutlet UILabel *labelProductPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelProductDetail;
@property (weak, nonatomic) IBOutlet UIImageView *productImageWrapper;
@property (weak, nonatomic) IBOutlet UIView *popupContentView;

@end

@implementation JKPopupBookmark

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self.contentView addSubview:self.popupView];
        self.contentColor = [UIColor whiteColor];
        self.borderColor = [UIColor titleColor];
        
        float contentWidth = 245;
        float contentHeight = 350;
        
        float xCenter = (frame.size.width / 2);
        float yCenter = (frame.size.height / 2);
        
        float topEdge = frame.size.height - (yCenter + (contentHeight / 2));
        float bottomEdge = (yCenter - (contentHeight / 2));
        float leftEdge = (xCenter - (contentWidth / 2));
        float rightEdge = frame.size.width - (xCenter + (contentWidth / 2));
        
        self.margin = UIEdgeInsetsMake(topEdge, leftEdge, bottomEdge, rightEdge);
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self.popupView setFrame:self.contentView.bounds];
//    [self.popupContentView alignVerticallyCenterToView:self];
}

- (void)loadDetailWithProduct:(JKProduct *)product{
    self.product = product;
    self.labelProductName.text = product.name;
    [self.labelProductName setFont:[UIFont fontWithName:@"Lato" size:17]];
    [self.labelProductName setTextColor:[UIColor titleColor]];
    self.labelProductSku.text = [NSString stringWithFormat:@"Product code: %@",product.product_code];
    self.labelProductPrice.text = [NSString getVNCurrencyFormatterWithNumber:@([product.price intValue])];
    self.labelProductDetail.text = product.detail;
    [self.productImage sd_setImageWithURL:[NSURL URLWithString:[[product.images anyObject] getSmallImageURL]]];
    self.productImageWrapper.layer.borderWidth = 1;
    self.productImageWrapper.layer.borderColor = [UIColor titleColor].CGColor;
    [self.labelQuantity setText:[NSString stringWithFormat:@"%d",(int)[self.stepper value]]];
}

- (IBAction)stepperValueChanged:(id)sender {
    double value = [(UIStepper *)sender value];
    [self.labelQuantity setText:[NSString stringWithFormat:@"%d", (int)value]];

}

- (IBAction)confirmButtonPress:(id)sender {
    if([self.JKDelegate respondsToSelector:@selector(didPressConfirmButton:)])
    {
        [self.JKDelegate performSelector:@selector(didPressConfirmButton:) withObject:self];
    }
    
    [self hide];

}

@end

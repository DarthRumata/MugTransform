//
//  YALEllipseTransformView.m
//  BCMeshTransformViewDemo
//
//  Created by Stanislav on 11/13/15.
//  Copyright © 2015 Bartosz Ciechanowski. All rights reserved.
//

#import "YALEllipseTransformView.h"
#import "UIImage+Crop.h"
#import "BCMeshTransformView.h"

const CGFloat tiltLevel = 0.08;

@interface YALEllipseTransformView ()

@property (nonatomic, strong) UIView *frontSide;
@property (nonatomic, strong) UIView *backSide;

@property (nonatomic, assign) CGSize productSize;
@property (nonatomic, strong) UIImage *productImage;
@property (nonatomic, assign) CGFloat ratio;

@end

@implementation YALEllipseTransformView

- (instancetype)initWithFrame: (CGRect)frame productImage: (UIImage *)productImage productRealSize: (CGSize)productSize {
    self = [super initWithFrame:frame];
    if (self) {
        self.productImage = productImage;
        self.productSize = productSize;
        [self commonInit];
        return self;
    }
    
    return nil;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.ratio = self.productSize.height / self.productSize.width;
}

- (void)renderWithImage: (UIImage *)coverImage doubleSided: (BOOL)doubleSided insets: (UIEdgeInsets)insets {
    if (self.frontSide) {
        [self.frontSide removeFromSuperview];
    }
    if (self.backSide) {
        [self.backSide removeFromSuperview];
    }
    
    self.frontSide = [[UIView alloc] initWithFrame: self.bounds];
    [self addSubview: self.frontSide];
    if (doubleSided) {
        self.backSide = [[UIView alloc] initWithFrame: self.bounds];
        [self addSubview: self.backSide];
    }
    
    CGFloat croppedWidth = coverImage.size.width / (doubleSided ? 2 : 1);
    CGFloat croppedHeight = croppedWidth * self.ratio;
    UIImage *firstImage = [coverImage cropRectImage: CGRectMake(0, 0, croppedWidth, croppedHeight)];
    [self createFrontSide: firstImage insets: insets];
    if (doubleSided) {
        UIImage *secondImage = [coverImage cropRectImage: CGRectMake(croppedWidth, 0, croppedWidth, croppedHeight)];
        [self createBackSide: secondImage insets: insets];
        self.backSide.hidden = TRUE;
    }
}

#pragma mark - Create sides

- (void)createSide: (UIView *)sideView coverImage: (UIImage *)cover insets: (UIEdgeInsets)insets {
    CGSize size = CGSizeMake(190, 180);
    CGFloat x = self.center.x - size.width / 2;
    CGFloat y = self.center.y - size.height / 2;
    UIImageView *productView = [[UIImageView alloc] initWithImage: self.productImage];
    productView.frame = CGRectMake(x, y, size.width, size.height);
    if (sideView == self.backSide) {
        productView.transform = CGAffineTransformMakeScale(-1, 1);
    }
    [sideView addSubview: productView];
    
    BCMeshTransformView *transformerView = [[BCMeshTransformView alloc] initWithFrame:CGRectMake(x + insets.left,
                                                                                                 y + insets.top,
                                                                                                 size.width - insets.right - insets.left,
                                                                                                 (size.height - insets.bottom) * (1 + tiltLevel)
                                                                                                 )];
    transformerView.backgroundColor = [UIColor clearColor];
    [sideView addSubview:transformerView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: cover];
    imageView.frame = CGRectMake(
                                 0,
                                 0,
                                 transformerView.bounds.size.width,
                                 transformerView.bounds.size.height * (1 - tiltLevel)
                                 );
    [transformerView.contentView addSubview: imageView];
    
    transformerView.meshTransform = [self ellipseMeshTransform: tiltLevel];
}

- (void)createFrontSide: (UIImage *)cover insets: (UIEdgeInsets)insets {
    [self createSide:self.frontSide coverImage: cover insets: insets];
}

- (void)createBackSide: (UIImage *)cover insets: (UIEdgeInsets)insets {
    [self createSide: self.backSide coverImage: cover insets: UIEdgeInsetsMake(insets.top, insets.right, insets.bottom, insets.left)];
}

- (BCMeshTransform *)ellipseMeshTransform: (CGFloat)part {
    NSUInteger meshSize = 40;
    CGFloat step = 1 / (CGFloat)meshSize;
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows: meshSize numberOfColumns: meshSize];
    
    for (int i = 0; i < transform.vertexCount; i++) {
        BCMeshVertex v = [transform vertexAtIndex:i];
        //Ellipse transform
        v.to.y += sqrt((0.25 - pow(v.from.x - 0.5, 2))) * part;
        //Scale vertically
        NSUInteger row = v.from.y / step;
        v.to.y -= step * row * part;
        [transform replaceVertexAtIndex:i withVertex:v];
    }
    
    return transform;
}

- (void)flip {
    self.backSide.hidden = FALSE;
    UIView *fromView = self.frontSide.superview ? self.frontSide : self.backSide;
    UIView *toView = self.frontSide.superview ? self.backSide : self.frontSide;
    [UIView transitionFromView:fromView toView:toView duration:0.6 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
}

@end

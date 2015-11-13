//
//  BCMugController.m
//  BCMeshTransformViewDemo
//
//  Created by Stas Kirichok on 05.11.15.
//  Copyright © 2015 Bartosz Ciechanowski. All rights reserved.
//

#import "BCMugController.h"
#import "BCMeshTransformView.h"
#import "UIImage+Crop.h"
#import "YALEllipseTransformView.h"

@interface BCMugController ()

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIView *frontSide;
@property (nonatomic, strong) UIView *backSide;

@end



NSUInteger ppi = 200;
CGSize mugSize;
CGFloat cmInInch = 2.54;
CGFloat ratio;
UIImage *firstImage;
UIImage *secondImage;

@implementation BCMugController

- (void)viewDidLoad {
    [super viewDidLoad];
    mugSize = CGSizeMake(20, 8.8);
    
    YALEllipseTransformView *mug = [[YALEllipseTransformView alloc] initWithFrame:self.view.bounds productImage:[UIImage imageNamed: @"Coffee_Cup.png"] productRealSize:mugSize];
    [self.view addSubview: mug];
    [mug renderWithImage: [UIImage imageNamed:@"sample.jpg"] doubleSided:TRUE insets:UIEdgeInsetsMake(20, 1, 20, 61)];
    
    UIButton *rotateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    rotateButton.frame = CGRectMake(20, 400, 100, 40);
    [self.view addSubview:rotateButton];
    [rotateButton setTitle:@"Rotate" forState:UIControlStateNormal];
    [rotateButton addTarget:mug action:@selector(flip) forControlEvents:UIControlEventTouchUpInside];

}

- (CGSize)calculateMinSizeOfImage {
    CGFloat diagonalCm = sqrtf(pow(mugSize.width, 2) + pow(mugSize.height, 2));
    CGFloat diagonalInches = diagonalCm / cmInInch;
    CGFloat diagonalPoints = diagonalInches * ppi;
    CGFloat width = sqrtf(pow(diagonalPoints, 2) / (1 + ratio));
    CGFloat height = width * ratio;
    return CGSizeMake(width, height);
}

@end

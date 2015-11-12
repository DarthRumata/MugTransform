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

@interface BCMugController ()

@property (nonatomic, strong) BCMeshTransformView *transformViewer;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *frontSide;
@property (nonatomic, strong) UIView *backSide;

@end

CGFloat partOfImage = 0.08;

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
    ratio = mugSize.height / mugSize.width;
    
    UIView *rotatedView = [[UIView alloc]initWithFrame:self.view.bounds];
    rotatedView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:rotatedView];
    
    self.frontSide = [[UIView alloc]initWithFrame:self.view.bounds];
     [rotatedView addSubview:self.frontSide];
    self.backSide = [[UIView alloc]initWithFrame:self.view.bounds];
    [rotatedView addSubview:self.backSide];
    
    UIImage *image = [UIImage imageNamed:@"sample.jpg"];
    CGSize minSize = [self calculateMinSizeOfImage];
    if (image.size.width < minSize.width || image.size.height < minSize.height) {
        NSLog(@"too small image");
    }
    CGFloat croppedWidth = image.size.width / 2;
    CGFloat croppedHeight = croppedWidth * ratio;
    firstImage = [image cropRectImage: CGRectMake(0, 0, croppedWidth, croppedHeight)];
    secondImage = [image cropRectImage: CGRectMake(croppedWidth, 0, croppedWidth, croppedHeight)];
    
    // Do any additional setup after loading the view.
    [self createFrontSide];
    [self createBackSide];

    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 350, 300, 30)];
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 1;
    self.slider.value = partOfImage;
    [self.slider addTarget:self action:@selector(updateTransform) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.slider];
    
    UIButton *rotateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    rotateButton.frame = CGRectMake(20, 400, 100, 40);
    [self.view addSubview:rotateButton];
    [rotateButton setTitle:@"Rotate" forState:UIControlStateNormal];
    [rotateButton addTarget:self action:@selector(rotate) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateTransform];
}

- (void)createFrontSide {
    CGSize size = CGSizeMake(190, 180);
    CGFloat x = self.view.center.x - size.width / 2;
    UIImageView *cupView = [[UIImageView alloc]initWithImage:[UIImage imageNamed: @"Coffee_Cup.png"]];
    
    
    cupView.frame = CGRectMake(x, 100, size.width, size.height);
    [self.frontSide addSubview:cupView];
    
    self.transformViewer = [[BCMeshTransformView alloc] initWithFrame:CGRectMake(x + 1,
                                                                                 cupView.frame.origin.y + 20,
                                                                                 size.width - 62,
                                                                                 size.height + 40
                                                                                 )];
    self.transformViewer.backgroundColor = [UIColor clearColor];
    // self.transformViewer.diffuseLightFactor = 0;
    [self.frontSide addSubview:self.transformViewer];
    
    self.imageView = [[UIImageView alloc] initWithImage: firstImage];
    self.imageView.frame = CGRectMake(
                                      0,
                                      0,
                                      self.transformViewer.bounds.size.width,
                                      self.transformViewer.bounds.size.height - 65
                                      );
    [self.transformViewer.contentView addSubview: self.imageView];
}

- (void)createBackSide {
    self.backSide = [[UIView alloc]initWithFrame:self.view.bounds];
    CGSize size = CGSizeMake(190, 180);
    CGFloat x = self.view.center.x - size.width / 2;
    UIImageView *cupView = [[UIImageView alloc]initWithImage:[UIImage imageNamed: @"Coffee_Cup.png"]];
    cupView.transform = CGAffineTransformMakeScale(-1, 1);
    cupView.frame = CGRectMake(x, 100, size.width, size.height);
    [self.backSide addSubview:cupView];
    
    BCMeshTransformView *transformerView = [[BCMeshTransformView alloc] initWithFrame:CGRectMake(x + 62,
                                                                                 cupView.frame.origin.y + 20,
                                                                                 size.width - 1,
                                                                                 size.height + 40
                                                                                 )];
    transformerView.backgroundColor = [UIColor clearColor];
    // self.transformViewer.diffuseLightFactor = 0;
    [self.backSide addSubview:transformerView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: secondImage];
    imageView.frame = CGRectMake(
                                      0,
                                      0,
                                      transformerView.bounds.size.width,
                                     transformerView.bounds.size.height - 65
                                      );
    [transformerView.contentView addSubview: imageView];
    
    CGFloat newValue = self.slider.value;
    transformerView.meshTransform = [self simpleMeshTransform: newValue];
}

- (void)rotate {
    UIView *fromView = self.frontSide.superview ? self.frontSide : self.backSide;
    UIView *toView = self.frontSide.superview ? self.backSide : self.frontSide;
    [UIView transitionFromView:fromView toView:toView duration:0.6 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
}

- (void)updateTransform {
    CGFloat newValue = self.slider.value;
    self.transformViewer.meshTransform = [self simpleMeshTransform: newValue];
    
    NSLog(@"%f %@", newValue, self.imageView);
}

- (BCMeshTransform *)simpleMeshTransform: (CGFloat)part {
    NSUInteger meshSize = 40;
    CGFloat step = 1 / (CGFloat)meshSize;
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:meshSize numberOfColumns:meshSize];
    
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

- (CGSize)calculateMinSizeOfImage {
    CGFloat diagonalCm = sqrtf(pow(mugSize.width, 2) + pow(mugSize.height, 2));
    CGFloat diagonalInches = diagonalCm / cmInInch;
    CGFloat diagonalPoints = diagonalInches * ppi;
    CGFloat width = sqrtf(pow(diagonalPoints, 2) / (1 + ratio));
    CGFloat height = width * ratio;
    return CGSizeMake(width, height);
}

@end
